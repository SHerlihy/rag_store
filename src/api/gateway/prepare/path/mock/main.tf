terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "kbaas"
}

variable "rest_api_id" {
  value = string
}

variable "resource_id" {
  value = string
}

resource "aws_api_gateway_method" "mock_get" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = "GET"

  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.storage.id

  api_key_required = false
  
  # Add method request parameters if needed
  request_parameters = {
    "method.request.querystring.authKey" = true
  }
}

resource "aws_api_gateway_integration" "mock_get" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.mock_get.http_method
  integration_http_method = aws_api_gateway_method.mock_get.http_method

  type        = "MOCK"
  passthrough_behavior    = "WHEN_NO_MATCH"
  
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration_response" "mock_get" {
  depends_on = [
    aws_api_gateway_method.mock_get,
    aws_api_gateway_integration.mock_get
  ]

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id

  http_method = aws_api_gateway_method.mock_get.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "{}"
  }

  # response_parameters = {
  #   "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
  #   "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
  #   "method.response.header.Access-Control-Allow-Origin" = "'*'"
  # }
}

resource "aws_api_gateway_method_response" "mock_get_200" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.mock_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  #  response_parameters = {
  #    "method.response.header.Access-Control-Allow-Headers" = true,
  #    "method.response.header.Access-Control-Allow-Methods" = true,
  #    "method.response.header.Access-Control-Allow-Origin" = true
  #  }
}
