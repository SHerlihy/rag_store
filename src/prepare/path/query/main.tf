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
  type = string
}

variable "resource_id" {
  type = string
}

variable "authorizer_id" {
  type = string
}

variable "invoke_arn" {
    type = string
}

resource "aws_api_gateway_resource" "query" {
  rest_api_id = var.rest_api_id
  parent_id   = var.resource_id
  path_part   = "query"
}

resource "aws_api_gateway_method" "query" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.query.id
  http_method   = "POST"

  authorization = "CUSTOM"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "query" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.query.id

  http_method          = aws_api_gateway_method.query.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"

  uri = var.invoke_arn
}

resource "aws_api_gateway_method_response" "query" {
  depends_on = [
aws_api_gateway_resource.query,
aws_api_gateway_method.query
  ]

  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.query.id

  http_method = aws_api_gateway_method.query.http_method
  status_code = 200
}

# resource "aws_api_gateway_method_response" "bucket_put" {
#   depends_on = [
#     aws_api_gateway_method.bucket_put,
#     aws_api_gateway_integration.bucket_put
#   ]
#
#   rest_api_id = var.rest_api_id
#   resource_id   = var.resource_id
#   http_method = aws_api_gateway_method.bucket_put.http_method
#   status_code = "200"
#
#   response_models = {
#     "application/xml" = "Empty"
#   }
#
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = true,
#     "method.response.header.Access-Control-Allow-Methods" = true,
#     "method.response.header.Access-Control-Allow-Origin" = true
#   }
# }
#
# resource "aws_api_gateway_integration_response" "bucket_put" {
#   depends_on = [
#     aws_api_gateway_method.bucket_put,
#     aws_api_gateway_integration.bucket_put
#   ]
#
#   rest_api_id = var.rest_api_id
#   resource_id   = var.resource_id
#   http_method = aws_api_gateway_method.bucket_put.http_method
#   status_code = aws_api_gateway_method_response.bucket_put.status_code
#
#   selection_pattern = ""
#
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
#     "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
#     "method.response.header.Access-Control-Allow-Origin" = "'*'"
#   }
# }
