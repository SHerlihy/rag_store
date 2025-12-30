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

variable "bucket_name" {
  type = string
}

variable "bucket_access_role" {
  type = string
}

variable "rest_api_id" {
  type = string
}

variable "resource_id" {
  type = string
}

variable "root_resource_id" {
  type = string
}

variable "authorizer_id" {
  type = string
}

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.region
}

resource "aws_api_gateway_method" "bucket_options" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = "OPTIONS"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "bucket_options" {
  rest_api_id = var.rest_api_id
  resource_id   = var.resource_id
  http_method = aws_api_gateway_method.bucket_options.http_method

  type        = "MOCK"

  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "bucket_options" {
  depends_on = [
    aws_api_gateway_method.bucket_options,
    aws_api_gateway_integration.bucket_options
  ]

  rest_api_id = var.rest_api_id
  resource_id   = var.resource_id
  http_method = aws_api_gateway_method.bucket_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "bucket_options" {
  depends_on = [
    aws_api_gateway_method.bucket_options,
    aws_api_gateway_integration.bucket_options
  ]

  rest_api_id = var.rest_api_id
  resource_id   = var.resource_id
  http_method = aws_api_gateway_method.bucket_options.http_method
  status_code = aws_api_gateway_method_response.bucket_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PUT,POST,PATCH'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
