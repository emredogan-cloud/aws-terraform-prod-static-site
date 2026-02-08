output "bucket_name" {
  description = "Static Site Bucket Name"
  value       = aws_s3_bucket.prod_bucket.id
}

output "bucket_arn" {
  description = "Static Site Bucket ARN"
  value       = aws_s3_bucket.prod_bucket.arn
}

output "domain_name" {
  description = "Static Site Bucket Regional Domain Name"
  value       = aws_s3_bucket.prod_bucket.bucket_regional_domain_name
}