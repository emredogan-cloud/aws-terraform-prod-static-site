data "aws_iam_policy_document" "iam_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    actions = [ "s3:GetObject" ]

    principals {
      type = "service"
      identifiers = [ "cloudfront.amazonaws.com" ]
    }

    resources = [ "arn:aws:s3:::${var.bucket_name}/*" ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [ var.Distribution_arn ]
    }
  }
}
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.iam_policy.json
}