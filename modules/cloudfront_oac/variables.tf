variable "origin_domain_name" {
  description = "S3 Bucket'ın Regional Domain Adı (örn: bucket-name.s3.us-east-1.amazonaws.com)"
  type        = string
}

variable "default_root_object" {
  description = "Site açılınca varsayılan olarak yüklenecek dosya"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront Fiyat Sınıfı (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Kaynaklara eklenecek etiketler"
  type        = map(string)
  default     = {}
}