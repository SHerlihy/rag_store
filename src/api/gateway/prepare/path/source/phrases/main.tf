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

variable "bucket_name" {
  type = string
}

variable "bucket_access_role" {
  type = string
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

variable "authorizer_id" {
  type = string
}

resource "aws_api_gateway_resource" "phrases" {
  rest_api_id   = var.rest_api_id
  parent_id   = var.resource_id
  path_part   = "phrases"
}

locals {
  resource_id = aws_api_gateway_resource.phrases.id
}

module "get" {
  source = "./get"

  bucket_name = var.bucket_name
  bucket_access_role = var.bucket_access_role
  
  rest_api_id = var.rest_api_id
  resource_id = local.resource_id
  root_resource_id = var.root_resource_id
  authorizer_id = var.authorizer_id
}

module "delete" {
  source = "./delete"

  bucket_name = var.bucket_name
  bucket_access_role = var.bucket_access_role
  
  rest_api_id = var.rest_api_id
  resource_id = local.resource_id
  root_resource_id = var.root_resource_id
  authorizer_id = var.authorizer_id
}

module "upload" {
  source = "./upload"

  bucket_name = var.bucket_name
  bucket_access_role = var.bucket_access_role

  rest_api_id = var.rest_api_id
  resource_id = local.resource_id
  root_resource_id = var.root_resource_id
  authorizer_id = var.authorizer_id
}
