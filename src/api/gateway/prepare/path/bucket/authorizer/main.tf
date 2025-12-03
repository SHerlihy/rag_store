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

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_lambda_name
  principal     = "apigateway.amazonaws.com"
  
  # The /*/*/* part allows invocation from any stage, method and resource path
  # within the specified API
  source_arn = "${var.api_execution_arn}/*/*/*"
}

resource "aws_api_gateway_authorizer" "storage" {
  name                   = "storage"
  rest_api_id            = aws_api_gateway_rest_api.storage.id
  authorizer_uri         = var.auth_invoke_arn
  authorizer_credentials = var.lambda_exec_role

  type                   = "REQUEST"
  identity_source       = "method.request.querystring.authKey"
  
  # Optional: Cache the authorizer results for 5 minutes (300 seconds)
  authorizer_result_ttl_in_seconds = 300
}

