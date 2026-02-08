variable "origin_domain_name" {
  description = "S3 Bucket Regional Domain Name"
  type        = string
}

variable "default_root_object" {
  description = "Deafult UserInterface"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront PriceClass (PriceClass_100 , PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "added to resources tickets"
  type        = map(string)
  default     = {}
}

variable "logging_bucket_domain_name" {
  description = "S3 bucket domain name where CloudFront logs will be written"
  type = string
  default = ""
}

variable "waf_acl_id" {
  description = "for cloudfront waf"
  type = string
  default = null
}