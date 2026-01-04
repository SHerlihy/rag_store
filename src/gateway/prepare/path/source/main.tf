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


variable "bucket_name" {
    type = string
}

variable "bucket_access_role" {
    type = string
}

module "source" {
  source = "./list"

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
    authorizer_id = var.authorizer_id

  bucket_name = var.bucket_name
    bucket_access_role = var.bucket_access_role
}

module "phrases" {
  source = "./phrases"

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
    authorizer_id = var.authorizer_id

  bucket_name = var.bucket_name
    bucket_access_role = var.bucket_access_role
}
