#!/bin/bash

AUTH_KEY=$1

terraform -chdir=./prepare init
terraform -chdir=./deploy init

terraform -chdir=./prepare apply -var="auth_key=${AUTH_KEY}" --auto-approve
terraform -chdir=./prepare output > ./deploy/terraform.tfvars
terraform -chdir=./deploy apply --auto-approve
