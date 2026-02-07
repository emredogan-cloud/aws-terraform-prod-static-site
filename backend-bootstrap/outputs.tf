output "state_bucket_name" {
  description = "backend bootstrap S3 Bucket Name"
  value       = aws_s3_bucket.state-bucket.id
}

output "lock_table_name" {
  description = "backend bootstrap DynamoDB table name"
  value       = aws_dynamodb_table.state_table.name
}

