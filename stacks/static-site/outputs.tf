output "site_bucket_name" {
  description = "Module site_bucket Bucket Name"
  value       = module.site_bucket.bucket_name
}

output "cloudfront_domain_name" {
  description = "Module cdn Domain Name"
  value       = module.cdn.domain_name
}

output "distribution_id" {
  description = "Module cdn distribution Id"
  value       = module.cdn.distribution_id
}