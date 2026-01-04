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

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = var.rest_api_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  rest_api_id = var.rest_api_id
  deployment_id = aws_api_gateway_deployment.main.id
  stage_name    = "main"
}

output "api_path" {
    value = aws_api_gateway_stage.main.invoke_url
}
