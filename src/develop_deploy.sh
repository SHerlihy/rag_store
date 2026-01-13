#!/bin/bash

AUTH_KEY=$1
DEPLOY_ID="htj8yt"

terraform -chdir=./dev_fakes init
terraform -chdir=./api init
terraform -chdir=./develop init

./refreshers/create_dist.sh

terraform -chdir=./dev_fakes apply --auto-approve

cat ./variables/shared.txt > ./api/terraform.tfvars
terraform -chdir=./dev_fakes output >> ./develop/terraform.tfvars

terraform -chdir=./api apply -var="auth_key=${AUTH_KEY}" --auto-approve

terraform -chdir=./api output > ./develop/terraform.tfvars
echo "deploy_id=${DEPLOY_ID}" >> ./develop/terraform.tfvars

terraform -chdir=./develop apply --auto-approve
