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

module "authorizer" {
  source = "./authorizer"

  rest_api_id = var.rest_api_id
  lambda_role_arn = var.lambda_role_arn
  execution_arn = var.execution_arn
}

module "s3" {
  source = "./s3"
}

resource "aws_iam_role" "api_gateway_s3_role" {
  name = "APIGatewayS3Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_s3_attachment" {
  role       = aws_iam_role.api_gateway_s3_role.name
  policy_arn = module.s3.policy_arn
}

module "list" {
    source = "./endpoints/list"

    bucket_name = module.s3.bucket_name
    bucket_access_role = aws_iam_role.api_gateway_s3_role.arn
    
    rest_api_id = var.rest_api_id
    resource_id = var.resource_id
    root_resource_id = var.root_resource_id
    authorizer_id = module.authorizer.id
}
