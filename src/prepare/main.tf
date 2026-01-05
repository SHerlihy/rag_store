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

# not safe
variable "auth_key" {
    type = string
    sensitive = true
    default = "allow"
}

variable "bucket_name" {
    type = string
}

variable "bucket_access_policy" {
    type = string
}

variable "kb_id" {
    type = string
}

module "init" {
  source = "./init"

  bucket_access_policy = var.bucket_access_policy
}

module "paths" {
  source = "./path"

  rest_api_id = module.init.rest_api_id
  resource_id = module.init.resource_id

  execution_arn = module.init.execution_arn
  auth_key = var.auth_key

  bucket_name = var.bucket_name
  bucket_access_role = module.init.gateway_role_arn

  kb_id = var.kb_id
}

output "rest_api_id" {
  value = module.init.rest_api_id
}

output "bucket_name" {
  value = var.bucket_name
}
