output "lambda_arn" {
  value = aws_lambda_function.authorizer.arn
}

output "lambda_arn" {
  value = aws_lambda_function.authorizer.name
}

output "invoke_arn" {
  value = aws_lambda_function.authorizer.invoke_arn
}
