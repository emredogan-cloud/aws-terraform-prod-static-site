# 1. Origin Access Control (OAC) - Modern Erişim Yöntemi
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "oac-${var.origin_domain_name}" # Benzersiz isim
  description                       = "OAC for Static Site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true                # ZORUNLU: Dağıtımı aktif eder
  is_ipv6_enabled     = true                # Modern standart
  comment             = "Static Site Distribution"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  
  tags = var.tags

  # --- ORIGIN AYARLARI ---
  origin {
    domain_name              = var.origin_domain_name
    origin_id                = "S3-Origin" # Aşağıdaki target_origin_id ile aynı olmalı
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  # --- CACHE BEHAVIOR ---
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Origin"

    viewer_protocol_policy = "redirect-to-https" # HTTP geleni HTTPS'e zorla
    compress               = true                # Gzip/Brotli sıkıştırma

    # Basit ayarlar için Forwarded Values (Veya CachePolicyID kullanılabilir)
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    # İpucu: Managed-CachingOptimized policy kullanmak istersem forwarded_values yerine şunu açarım:
    # cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # --- GEO RESTRICTION (NONE) ---
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  # --- VIEWER CERTIFICATE ---
  viewer_certificate {
    cloudfront_default_certificate = true
    
    # NOT: 'cloudfront_default_certificate = true' iken minimum_protocol_version
    # genellikle 'TLSv1' olarak sabitlenir. Eğer custom domain (ACM) kullanırsam
    # aşağıdaki satır devreye girer. Şimdilik default cert ile bu satır uyarı verebilir,
    # gerekirse silebilirsim.
    # minimum_protocol_version = "TLSv1.2_2021" 
  }
}