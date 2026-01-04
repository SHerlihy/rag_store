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

variable "execution_arn" {
    type = string
}

variable "auth_key" {
    type = string
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

module "authorizer" {
    source = "./authorizer"
    
    rest_api_id = var.rest_api_id
    execution_arn = var.execution_arn
    auth_key = var.auth_key
}

module "preflight" {
    source = "./preflight"

    rest_api_id = var.rest_api_id
    resource_id = var.resource_id
}

module "source" {
    source = "./source"

    rest_api_id = var.rest_api_id
    resource_id = var.resource_id

    authorizer_id = module.authorizer.id

    bucket_name = var.bucket_name
    bucket_access_role = var.bucket_access_role
}

module "query" {
    source = "./query"
    
    rest_api_id = var.rest_api_id
    resource_id = var.resource_id

    invoke_arn = var.query_invoke_arn

    authorizer_id = module.authorizer.id
}
