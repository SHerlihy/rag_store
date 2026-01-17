#!/bin/bash

AUTH_KEY=$1
STAGE_UID="dev"

terraform -chdir=./dev_fakes init
terraform -chdir=./api init

./refreshers/create_dist.sh

terraform -chdir=./dev_fakes apply --auto-approve

terraform -chdir=./dev_fakes output > ./api/bucket.auto.tfvars

cat ./variables/shared/root.txt > ./api/terraform.tfvars
cat ./variables/shared/shared.txt >> ./api/terraform.tfvars
cat ./variables/develop/api.txt >> ./api/terraform.tfvars

echo "auth_key = \"${AUTH_KEY}\"" >> ./api/terraform.tfvars
echo "stage_uid = \"${STAGE_UID}\"" >> ./api/terraform.tfvars

#terraform -chdir=./api plan
terraform -chdir=./api apply
