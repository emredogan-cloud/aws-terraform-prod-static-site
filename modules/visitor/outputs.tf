output "api_endpoint" {
  value = aws_lambda_function_url.funk_url.function_url
}