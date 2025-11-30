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

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_lambda_name
  principal     = "apigateway.amazonaws.com"
  
  # The /*/*/* part allows invocation from any stage, method and resource path
  # within the specified API
  source_arn = "${aws_api_gateway_rest_api.storage.execution_arn}/*/*/*"
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

resource "aws_api_gateway_authorizer" "storage" {
  name                   = "storage"
  rest_api_id            = aws_api_gateway_rest_api.storage.id
  type = "REQUEST"

  authorizer_uri         = var.auth_invoke_arn
  authorizer_credentials = var.lambda_exec_role

  identity_source = "method.request.querystring.authKey"
}

resource "aws_api_gateway_method" "mock_get" {
  rest_api_id   = aws_api_gateway_rest_api.storage.id
  resource_id   = aws_api_gateway_resource.mock.id
  http_method   = "GET"

  authorization = "NONE"
  #  authorizer_id = aws_api_gateway_authorizer.storage.id
  #
  #  request_parameters = {
  #    "method.request.querystring.authKey" = true
  #  }
}

resource "aws_api_gateway_integration" "mock_get" {
  rest_api_id = aws_api_gateway_rest_api.storage.id
  resource_id = aws_api_gateway_resource.mock.id
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

  rest_api_id = aws_api_gateway_rest_api.storage.id
  resource_id = aws_api_gateway_resource.mock.id

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
  rest_api_id = aws_api_gateway_rest_api.storage.id
  resource_id = aws_api_gateway_resource.mock.id
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


resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.storage.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.mock_get
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.storage.id
  stage_name    = "main"
}
