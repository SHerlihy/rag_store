#!/bin/bash

STAGE_UID="dev"

cat ./variables/api_id.txt > ./stage/terraform.tfvars
echo "stage_uid = \"${STAGE_UID}\"" >> ./stage/terraform.tfvars

terraform -chdir=./stage apply
