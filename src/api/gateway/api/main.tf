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

resource "aws_lambda_permission" "gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.out_ip.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.gateway_execution_arn}/*/*"
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

  #authorizer_uri         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.auth_lambda_arn}/invocations"
  authorizer_uri         = var.auth_invoke_arn
  authorizer_credentials = var.lambda_exec_role

  identity_source = "method.request.querystring.authKey"
}

resource "aws_api_gateway_method" "mock_get" {
  rest_api_id   = aws_api_gateway_rest_api.storage.id
  resource_id   = aws_api_gateway_resource.mock.id
  http_method   = "GET"

  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.storage.id

  request_parameters = {
    "method.request.querystring.authKey" = true
  }
}

resource "aws_api_gateway_integration" "mock_get" {
  rest_api_id = aws_api_gateway_rest_api.storage.id
  resource_id = aws_api_gateway_resource.mock.id
  http_method = aws_api_gateway_method.mock_get.http_method
  type        = "MOCK"
# overloaded to also be mock response
    request_templates = {
    "application/json" = <<TEMPLATE
{
  "statusCode": 200
}
TEMPLATE
  }
}

resource "aws_api_gateway_method_response" "mock_get_200" {
  rest_api_id = aws_api_gateway_rest_api.storage.id
  resource_id = aws_api_gateway_resource.mock.id
  http_method = aws_api_gateway_method.mock_get.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "mock_get" {
  depends_on = [
    aws_api_gateway_integration.mock_get
  ]

  rest_api_id = aws_api_gateway_rest_api.storage.id
  resource_id = aws_api_gateway_resource.mock.id

  http_method = aws_api_gateway_method.mock_get.http_method
  status_code = aws_api_gateway_method_response.mock_get_200.status_code

  response_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200,
  "message": "This response is mocking you"
}
EOF
  }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.storage.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.mock.id,
      aws_api_gateway_method.mock_get.id,
      aws_api_gateway_integration.mock_get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.storage.id
  stage_name    = "main"
}
