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

resource "aws_api_gateway_method" "mock_get" {
  rest_api_id   = aws_api_gateway_rest_api.storage.id
  resource_id   = aws_api_gateway_resource.mock.id
  http_method   = "GET"
  authorization = "NONE"
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

output "api_path" {
  value = aws_api_gateway_stage.main.invoke_url
}
