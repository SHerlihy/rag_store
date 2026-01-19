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

module "api_role" {
  source = "./api_role"

  stage_uid = var.stage_uid

  bucket_access_policy = var.bucket_access_policy
}

module "paths" {
  source = "./path"

  stage_uid = var.stage_uid

  api_bind = {
    api_id = var.api_id
    resource_id = var.root_id
  }

  execution_arn = var.execution_arn

  auth_key = var.auth_key

  kb_id = var.kb_id

  source_id = var.source_id
}

output "gateway_role_arn" {
  value = module.api_role.gateway_role_arn
}

output "authorizer_id" {
  value = module.authorizer.id
}

output "query_invoke_arn" {
  value = module.query.invoke_arn
}

output "sync_invoke_arn" {
  value = module.sync.invoke_arn
}
