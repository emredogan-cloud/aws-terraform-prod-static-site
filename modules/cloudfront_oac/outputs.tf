output "Distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "Distribution_arn" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}
output "domain_name" {
  value = var.origin_domain_name
}