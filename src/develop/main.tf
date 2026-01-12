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

variable "deploy_id" {
  type = string
}

variable "rest_api_id" {
  type = string
}

resource "aws_api_gateway_stage" "main" {
  rest_api_id = var.rest_api_id
  deployment_id = var.deploy_id
  stage_name    = "DEV"
}

output "api_path" {
    value = aws_api_gateway_stage.main.invoke_url
}
