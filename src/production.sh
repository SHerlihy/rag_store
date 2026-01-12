#!/bin/bash

AUTH_KEY=$1

terraform -chdir=./api init
terraform -chdir=./production init

./refreshers/create_dist.sh

terraform -chdir=./api apply -var="auth_key=${AUTH_KEY}" --auto-approve

terraform -chdir=./api output > ./production/terraform.tfvars

terraform -chdir=./production apply --auto-approve
