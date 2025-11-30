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

module "exec_role" {
    source = "./lambda_exec_role"
}

module "auth_lambda" {
    source = "./auth_lambda"

    lambda_exec_role = module.exec_role.role_arn
}

module "api" {
    source = "./api"
    
    auth_invoke_arn = module.auth_lambda.invoke_arn
    auth_lambda_arn = module.auth_lambda.lambda_arn
    auth_lambda_name = module.auth_lambda.lambda_name
    lambda_exec_role = module.exec_role.role_arn
}

output "api_path" {
    value = module.api.api_path
}
