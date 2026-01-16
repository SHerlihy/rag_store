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

module "authorizer" {
    source = "./authorizer"

    stage_uid = var.stage_uid
    
    api_id = var.api_bind.api_id
    execution_arn = var.execution_arn

    auth_key = var.auth_key
}

module "preflight" {
    source = "./preflight"

    api_bind = var.api_bind
}

# module "source" {
#     source = "./source"
#
#     api_bind = var.api_bind
#
#     authorizer_id = module.authorizer.id
#
#     bucket = var.bucket
# }
#
# module "query" {
#     source = "./query"
#
#     stage_uid = var.stage_uid
#     
#     api_bind = var.api_bind
#     execution_arn = var.execution_arn
#
#     authorizer_id = module.authorizer.id
#
#     kb_id = var.kb_id
# }
#
# module "sync" {
#     source = "./sync"
#     
#     stage_uid = var.stage_uid
#
#     api_bind = var.api_bind
#     execution_arn = var.execution_arn
#
#     authorizer_id = module.authorizer.id
#
#     kb_id = var.kb_id
#     source_id = var.source_id
# }
