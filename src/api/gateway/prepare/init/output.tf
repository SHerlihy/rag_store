output "rest_api_id" {
  value = aws_api_gateway_rest_api.storage.id
}

output "resource_id" {
  value = aws_api_gateway_resource.bucket.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.storage.root_resource_id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.storage.execution_arn
}
