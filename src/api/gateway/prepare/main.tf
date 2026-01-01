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

variable "auth_key" {
    type = string
    sensitive = true
    ephemeral = true
}

variable "bucket_name" {
    type = string
}

variable "bucket_access_role" {
    type = string
}

variable "query_invoke_arn" {
    type = string
}

module "init" {
  source = "./init"
}

module "exec_role" {
    source = "./lambda_exec_role"
}

module "paths" {
  source = "./path"

  rest_api_id = module.init.rest_api_id
  resource_id = module.init.resource_id
  root_resource_id = module.init.root_resource_id

  lambda_role_arn = module.exec_role.lambda_role_arn
  auth_key = var.auth_key

  bucket_name = var.bucket_name
  bucket_access_role = var.bucket_access_role

  query_invoke_arn = var.query_invoke_arn
}

output "rest_api_id" {
  value = module.init.rest_api_id
}

output "bucket_name" {
  value = module.bucket_calls.bucket_name
}
