resource "aws_s3_bucket" "this" {
  bucket = "observation-logs-bucket${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
    bucket = aws_s3_bucket.this.id
  rule {
    id = "delete-old-logs-30-days"
    status = "Enabled"
    filter {}

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_control" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_acl" {
  bucket     = aws_s3_bucket.this.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucket_control]
}