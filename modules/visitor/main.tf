resource "aws_dynamodb_table" "table" {
  name         = "visitor-count-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "serverless_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" { 
  name        = "dynamodb_access_policy"
  description = "IAM policy for Lambda to access DynamoDB and Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:PutItem",
          "synamodb:DescribeTable"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.table.arn 
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = "${path.module}/lambda"
  output_path = "${path.module}/lambda/counter.zip"
}

resource "aws_lambda_function" "counter" {
  function_name = "lambda_visitor_func"
  role = aws_iam_role.lambda_role.arn

  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lamdba_zip.output_base64sha256

  handler = "counter.lambda_handler"
  runtime = "python3.9"
  timeout = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.table.name
    }
  }
}

resource "aws_lambda_function_url" "funk_url" {
  function_name = aws_lambda_function.counter.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"] 
    allow_methods     = ["GET"]
    allow_headers     = ["date", "keep-alive"]
    max_age           = 86400
  }
}

output "aws_func_url" {
  description = "aws lambda function URL"
  value = aws_lambda_function_url.funk_url.function_url
}

resource "aws_lambda_permission" "allow_public" {
  statement_id  = "AllowPublicFunctionUrlInvocation"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.counter.function_name
  principal     = "*" 
  function_url_auth_type = "NONE"
}