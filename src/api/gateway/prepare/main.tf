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

module "init" {
  source = "./init"
}

module "exec_role" {
    source = "./lambda_exec_role"
}

module "bucket_calls" {
  source = "./path/bucket"

  rest_api_id = module.init.rest_api_id
  resource_id = module.init.resource_id
  root_resource_id = module.init.root_resource_id
  lambda_role_arn = module.exec_role.lambda_role_arn
  execution_arn = module.init.execution_arn
}

output "rest_api_id" {
  value = module.init.rest_api_id
}
