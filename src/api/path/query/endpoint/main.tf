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
