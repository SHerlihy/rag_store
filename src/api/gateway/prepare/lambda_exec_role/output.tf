output "lambda_role_arn" {
    description = "lambda execution from api role arn"
    value = aws_iam_role.lambda_exec.arn
}
