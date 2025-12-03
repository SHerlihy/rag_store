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

variable "root_resource_id" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "execution_arn" {
  type = string
}

data "archive_file" "bucket_get" {
  type             = "zip"
  source_file      = "${path.module}/handler.py"
  output_path      = "${path.module}/handler.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "bucket_get" {
  filename          = "${path.module}/handler.zip"
  function_name     = "bucketGet"
  role              = var.lambda_role_arn
  handler           = "handler.handler"
  runtime           = "python3.14"
  
  source_code_hash = data.archive_file.bucket_get.output_base64sha256
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bucket_get.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${var.execution_arn}/*"
}

#resource "aws_lambda_permission" "allow_api_gateway" {
#  statement_id  = "AllowExecutionFromAPIGateway"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.bucket_get.arn
#  principal     = "apigateway.amazonaws.com"
#  
#  source_arn = "${var.execution_arn}/*"
#}

 # authorization = "CUSTOM"
 # authorizer_id = var.authorizer_id

 # api_key_required = false
 # 
 # # Add method request parameters if needed
 # request_parameters = {
 #   "method.request.querystring.authKey" = true
 # }

resource "aws_api_gateway_resource" "bucket_list" {
  rest_api_id   = var.rest_api_id
  parent_id   = var.resource_id
  path_part   = "list"
}

locals {
  resource_id = aws_api_gateway_resource.bucket_list.id
}

resource "aws_api_gateway_method" "bucket_get" {
  rest_api_id   = var.rest_api_id
  resource_id   = local.resource_id
  http_method   = "ANY"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "bucket_get" {
  rest_api_id = var.rest_api_id
  resource_id   = local.resource_id
  http_method = aws_api_gateway_method.bucket_get.http_method

  passthrough_behavior = "WHEN_NO_TEMPLATES"
  integration_http_method = "POST"
  type        = "AWS"
  uri = aws_lambda_function.bucket_get.invoke_arn
}

#response not in guide
#https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/guides/serverless-with-aws-lambda-and-api-gateway
##cors stuff is v2
##https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html
resource "aws_api_gateway_method_response" "bucket_get" {
  rest_api_id = var.rest_api_id
  resource_id   = local.resource_id
  http_method = aws_api_gateway_method.bucket_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "bucket_get" {
  depends_on = [
    aws_api_gateway_method.bucket_get,
    aws_api_gateway_integration.bucket_get
  ]

  rest_api_id = var.rest_api_id
  resource_id   = local.resource_id
  http_method = aws_api_gateway_method.bucket_get.http_method
  status_code = aws_api_gateway_method_response.bucket_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

output "lambda_arn" {
  value = aws_lambda_function.bucket_get.arn
}
