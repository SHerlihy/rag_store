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

resource "aws_api_gateway_rest_api" "kbaas" {
  name        = "kbaas"
  
  binary_media_types = [
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/msword"
  ]
}

output "api_id" {
  value = aws_api_gateway_rest_api.kbaas.id
}

output "root_id" {
  value   = aws_api_gateway_rest_api.kbaas.root_resource_id
}

output "execution_arn" {
  value   = aws_api_gateway_rest_api.kbaas.execution_arn
}
