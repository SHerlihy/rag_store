output "rest_api_id" {
  value = aws_api_gateway_rest_api.kbaas.id
}

output "resource_id" {
  value = aws_api_gateway_resource.kbaas.id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.kbaas.execution_arn
}

output "gateway_role_arn" {
  value = aws_iam_role.gateway.arn
}
