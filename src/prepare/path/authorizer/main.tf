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

variable "execution_arn" {
  type = string
}

variable "auth_key" {
  sensitive = true
  default = "allow"
  type = string
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_log" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "bucket_authorizer" {
  type             = "zip"
  source_file      = "${path.module}/handler.py"
  output_path      = "${path.module}/handler.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "bucket_authorizer" {
  filename          = "${path.module}/handler.zip"
  function_name     = "bucketAuthorizer"
  role              = aws_iam_role.lambda_exec.arn
  handler           = "handler.handler"
  runtime           = "python3.14"
  
  source_code_hash = data.archive_file.bucket_authorizer.output_base64sha256

  environment {
    variables = {
      AUTH_KEY = var.auth_key
    }
  }
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bucket_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${var.execution_arn}/*"
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "api_gateway_auth_invocation"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.bucket_authorizer.arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "bucketAuthorizer"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

locals {
  auth_uri = "${aws_lambda_function.bucket_authorizer.invoke_arn}"
}

resource "aws_api_gateway_authorizer" "bucket" {
  name                   = "bucket"
  rest_api_id            = var.rest_api_id
  authorizer_uri         = local.auth_uri
  type = "REQUEST"
  identity_source                  = "method.request.querystring.authKey"
  authorizer_credentials = aws_iam_role.invocation_role.arn
  authorizer_result_ttl_in_seconds = 0
}

output "id" {
  value = aws_api_gateway_authorizer.bucket.id
}
