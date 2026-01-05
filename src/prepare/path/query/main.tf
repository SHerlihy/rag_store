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

variable "authorizer_id" {
  type = string
}

variable "invoke_arn" {
    type = string
}

module "handler" {
  source = "./handler"
}

module "endpoint" {
  source = "./endpoint"

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id

  authorizer_id = var.authorizer_id

  invoke_arn = module.handler.invoke_arn
}
