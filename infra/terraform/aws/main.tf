locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = "Governed AI Commerce Analyst on Hybrid Cloud"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# -----------------------------
# S3 Raw Landing Bucket
# -----------------------------
resource "aws_s3_bucket" "raw" {
  bucket        = "${local.name_prefix}-raw-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Layer = "raw"
  })
}

resource "aws_s3_bucket_public_access_block" "raw" {
  bucket = aws_s3_bucket.raw.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------
# S3 Curated Bucket
# -----------------------------
resource "aws_s3_bucket" "curated" {
  bucket        = "${local.name_prefix}-curated-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Layer = "curated"
  })
}

resource "aws_s3_bucket_public_access_block" "curated" {
  bucket = aws_s3_bucket.curated.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "curated" {
  bucket = aws_s3_bucket.curated.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated" {
  bucket = aws_s3_bucket.curated.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------
# SNS Topic
# -----------------------------
resource "aws_sns_topic" "raw_file_events" {
  name = "${local.name_prefix}-raw-file-events"

  tags = local.common_tags
}

# Allow S3 to publish object-created events to SNS
data "aws_iam_policy_document" "sns_allow_s3_publish" {
  statement {
    sid    = "AllowS3Publish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.raw_file_events.arn
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.raw.arn]
    }
  }
}

resource "aws_sns_topic_policy" "raw_file_events" {
  arn    = aws_sns_topic.raw_file_events.arn
  policy = data.aws_iam_policy_document.sns_allow_s3_publish.json
}

# -----------------------------
# SQS Dead Letter Queue
# -----------------------------
resource "aws_sqs_queue" "raw_file_events_dlq" {
  name = "${local.name_prefix}-raw-file-events-dlq"

  message_retention_seconds = 1209600

  tags = merge(local.common_tags, {
    QueueType = "dead-letter"
  })
}

# -----------------------------
# SQS Main Queue
# -----------------------------
resource "aws_sqs_queue" "raw_file_events" {
  name = "${local.name_prefix}-raw-file-events"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.raw_file_events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = merge(local.common_tags, {
    QueueType = "main"
  })
}

# Allow SNS to send messages to SQS
data "aws_iam_policy_document" "sqs_allow_sns_send" {
  statement {
    sid    = "AllowSNSToSendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "SQS:SendMessage"
    ]

    resources = [
      aws_sqs_queue.raw_file_events.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.raw_file_events.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "raw_file_events" {
  queue_url = aws_sqs_queue.raw_file_events.id
  policy    = data.aws_iam_policy_document.sqs_allow_sns_send.json
}

# Subscribe SQS queue to SNS topic
resource "aws_sns_topic_subscription" "raw_file_events_to_sqs" {
  topic_arn = aws_sns_topic.raw_file_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.raw_file_events.arn

  depends_on = [
    aws_sqs_queue_policy.raw_file_events
  ]
}

# Send S3 object-created events to SNS
resource "aws_s3_bucket_notification" "raw_bucket_notifications" {
  bucket = aws_s3_bucket.raw.id

  topic {
    topic_arn = aws_sns_topic.raw_file_events.arn
    events    = ["s3:ObjectCreated:*"]

    filter_prefix = "incoming/"
    filter_suffix = ".csv"
  }

  depends_on = [
    aws_sns_topic_policy.raw_file_events
  ]
}