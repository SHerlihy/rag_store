#!/bin/bash

AUTH_KEY=$1
DEPLOY_ID=$2

terraform -chdir=./api init
terraform -chdir=./develop init

./refreshers/create_dist.sh

terraform -chdir=./api apply -var="auth_key=${AUTH_KEY}" --auto-approve

terraform -chdir=./api output > ./develop/terraform.tfvars
echo "deploy_id=${DEPLOY_ID}" >> ./develop/terraform.tfvars

terraform -chdir=./develop apply --auto-approve
