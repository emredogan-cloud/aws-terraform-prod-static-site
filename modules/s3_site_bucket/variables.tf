variable "bucket_name" {
  description = "S3 Static Site Bucket"
  type        = string
  default     = "aws-terraform-prod-static-site"
}

variable "force_destroy" {
  type = bool
}

variable "tags" {
  type = map(string)
}