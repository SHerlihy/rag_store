module "lambda" {
  source = "./lambda"

  rest_api_id = aws_api_gateway_rest_api.storage.id
  parent_id   = aws_api_gateway_rest_api.storage.root_resource_id
  gateway_execution_arn = aws_api_gateway_rest_api.storage.execution_arn 
}
