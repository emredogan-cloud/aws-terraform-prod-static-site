resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "oac-${split(".", var.origin_domain_name)[0]}" # Benzersiz isim
  description                       = "OAC for Static Site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static Site Distribution"
  default_root_object = var.default_root_object
  price_class         = var.price_class

  tags = var.tags

  origin {
    domain_name              = var.origin_domain_name
    origin_id                = "S3-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Origin"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # İpucu: Managed-CachingOptimized policy kullanmak istersem forwarded_values yerine şunu açarım:
    # cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  logging_config {
    include_cookies = false
    bucket = var.logging_bucket_domain_name
    prefix = "cf-logs/"
  }

  viewer_certificate {
    cloudfront_default_certificate = true

    # NOT: 'cloudfront_default_certificate = true' iken minimum_protocol_version
    # genellikle 'TLSv1' olarak sabitlenir. Eğer custom domain (ACM) kullanırsam
    # aşağıdaki satır devreye girer. Şimdilik default cert ile bu satır uyarı verebilir,
    # gerekirse silebilirim.
    # minimum_protocol_version = "TLSv1.2_2021" 
  }
}


resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "SecurityHeadersPolicy-${var.price_class}"
  comment = "Security headers for static site"

  security_headers_config {
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    content_type_options {
      override = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }
}