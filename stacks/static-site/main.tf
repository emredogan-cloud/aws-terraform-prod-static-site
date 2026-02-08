resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  site_bucket_name = "${var.project}-${var.env}-site-${random_id.suffix.hex}"
}

module "site_bucket" {
  source        = "../../modules/s3_site_bucket"
  bucket_name   = local.site_bucket_name
  tags          = var.tags
  force_destroy = var.env == "dev" ? true : false
}

module "cdn" {
  source = "../../modules/cloudfront_oac"

  origin_domain_name  = module.site_bucket.domain_name
  default_root_object = "index.html"
  price_class         = var.price_class
  tags                = var.tags
  waf_acl_id = module.waf.waf_arn

  logging_bucket_domain_name = aws_s3_bucket.this.bucket_domain_name
}

module "oac_policy" {
  source = "../../modules/s3_oac_policy"

  bucket_name      = module.site_bucket.bucket_name
  distribution_arn = module.cdn.Distribution_arn
}

module "waf" {
  source = "../../modules/waf_cloudfront"
}

module "visitor_counter" {
  source = "../../modules/visitor"
}