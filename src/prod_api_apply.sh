#!/bin/bash

AUTH_KEY=$1
STAGE_UID="prod"

terraform -chdir=./api init

./refreshers/create_dist.sh

cat ./variables/production/bucket.txt > ./api/bucket.auto.tfvars

cat ./variables/shared/root.txt > ./api/terraform.tfvars
cat ./variables/shared/shared.txt >> ./api/terraform.tfvars
cat ./variables/production/api.txt >> ./api/terraform.tfvars

echo "auth_key = \"${AUTH_KEY}\"" >> ./api/terraform.tfvars
echo "stage_uid = \"${STAGE_UID}\"" >> ./api/terraform.tfvars

terraform -chdir=./api apply
