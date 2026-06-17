# -----------------------------
# AWS Glue IAM Role
# -----------------------------

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "${local.name_prefix}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Glue needs access to read raw files, read the script, and write curated Parquet files.
data "aws_iam_policy_document" "glue_s3_access" {
  statement {
    sid    = "AllowListProjectBuckets"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.raw.arn,
      aws_s3_bucket.curated.arn
    ]
  }

  statement {
    sid    = "AllowReadRawBucketObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.raw.arn}/*"
    ]
  }

  statement {
    sid    = "AllowWriteCuratedBucketObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.curated.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "glue_s3_access" {
  name   = "${local.name_prefix}-glue-s3-access"
  policy = data.aws_iam_policy_document.glue_s3_access.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# -----------------------------
# Upload Glue script to S3
# -----------------------------

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.raw.bucket
  key    = "scripts/olist_csv_to_parquet.py"
  source = "${path.module}/../../../src/glue/olist_csv_to_parquet.py"
  etag   = filemd5("${path.module}/../../../src/glue/olist_csv_to_parquet.py")
}

# -----------------------------
# AWS Glue Catalog Database
# -----------------------------

resource "aws_glue_catalog_database" "commerce" {
  name        = replace("${local.name_prefix}-commerce", "-", "_")
  description = "Glue catalog database for the Hybrid Cloud Governed AI Commerce Analyst project."
}

# -----------------------------
# AWS Glue Job
# -----------------------------

resource "aws_glue_job" "olist_csv_to_parquet" {
  name     = "${local.name_prefix}-olist-csv-to-parquet"
  role_arn = aws_iam_role.glue_role.arn

  glue_version      = "5.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 15
  max_retries       = 0

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--RAW_BUCKET"                       = aws_s3_bucket.raw.bucket
    "--CURATED_BUCKET"                   = aws_s3_bucket.curated.bucket
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.glue_service_role,
    aws_iam_role_policy_attachment.glue_s3_access,
    aws_s3_object.glue_script
  ]
}