output "rest_api_id" {
  value = aws_api_gateway_rest_api.kbaas.id
}

output "resource_id" {
  value = aws_api_gateway_resource.kbaas.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.kbaas.root_resource_id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.kbaas.execution_arn
}
