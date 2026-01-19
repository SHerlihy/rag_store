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

locals {
  api_bind = {
    api_id = var.api_id
    resource_id = var.root_id
  }
}

module "preflight" {
    source = "./preflight"

    api_bind = local.api_bind
}

module "query" {
    source = "./query"

    api_bind = local.api_bind

    authorizer_id = var.authorizer_id

    invoke_arn = var.query_invoke_arn
}

module "sync" {
    source = "./sync"
    
    api_bind = local.api_bind

    authorizer_id = var.authorizer_id

    invoke_arn = var.sync_invoke_arn
}

module "source" {
    source = "./source"

    api_bind = local.api_bind

    authorizer_id = var.authorizer_id

    bucket = var.bucket
}
