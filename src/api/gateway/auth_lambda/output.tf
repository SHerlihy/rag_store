output "lambda_arn" {
  value = aws_lambda_function.authorizer.arn
}

output "lambda_name" {
  value = aws_lambda_function.authorizer.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.authorizer.invoke_arn
}
