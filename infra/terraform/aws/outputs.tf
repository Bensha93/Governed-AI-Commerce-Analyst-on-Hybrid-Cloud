output "raw_bucket_name" {
  description = "S3 raw landing bucket name."
  value       = aws_s3_bucket.raw.bucket
}

output "curated_bucket_name" {
  description = "S3 curated bucket name."
  value       = aws_s3_bucket.curated.bucket
}

output "sns_topic_arn" {
  description = "SNS topic ARN for raw file events."
  value       = aws_sns_topic.raw_file_events.arn
}

output "sqs_queue_url" {
  description = "SQS queue URL for raw file events."
  value       = aws_sqs_queue.raw_file_events.id
}

output "sqs_queue_arn" {
  description = "SQS queue ARN for raw file events."
  value       = aws_sqs_queue.raw_file_events.arn
}

output "dlq_url" {
  description = "Dead-letter queue URL."
  value       = aws_sqs_queue.raw_file_events_dlq.id
}