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

data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "storage" {
  name        = "storage"
}

resource "aws_api_gateway_account" "storage" {
  cloudwatch_role_arn = aws_iam_role.gateway.arn
}

data "aws_iam_policy_document" "gateway_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "gateway" {
  assume_role_policy = data.aws_iam_policy_document.gateway_assume.json
}

resource "aws_iam_role_policy_attachment" "gateway_log" {
  role       = aws_iam_role.gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_resource" "mock" {
  rest_api_id = aws_api_gateway_rest_api.storage.id
  parent_id   = aws_api_gateway_rest_api.storage.root_resource_id
  path_part   = "mock"
}

resource "aws_api_gateway_resource" "bucket" {
  rest_api_id = aws_api_gateway_rest_api.storage.id
  parent_id   = aws_api_gateway_rest_api.storage.root_resource_id
  path_part   = "bucket"
}
