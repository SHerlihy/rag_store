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

module "list" {
    source = "./calls/list"

    rest_api_id = var.rest_api_id
    resource_id = var.resource_id
    root_resource_id = var.root_resource_id
    lambda_role_arn = var.lambda_role_arn
    execution_arn = var.execution_arn
}

output "get_lambda_arn" {
  value = module.list.lambda_arn
}
