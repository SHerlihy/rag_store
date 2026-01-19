#!/bin/bash

AUTH_KEY=$1
STAGE_UID="dev"

terraform -chdir=./create_objects init
terraform -chdir=./dev_fakes init
terraform -chdir=./api init

#./refreshers/create_dist.sh

# CREATE FAKE BUCKET
terraform -chdir=./dev_fakes apply --auto-approve

# CREATE RESOURCES
terraform -chdir=./dev_fakes output bucket_access_policy > ./api_resources/terraform.tfvars

echo "auth_key = \"${AUTH_KEY}\"" >> ./api_resources/terraform.tfvars
echo "stage_uid = \"${STAGE_UID}\"" >> ./api_resources/terraform.tfvars

cat ./variables/shared/api_id.txt >> ./api_resources/terraform.tfvars
cat ./variables/shared/root_id.txt >> ./api_resources/terraform.tfvars
cat ./variables/shared/execution_arn.txt >> ./api_resources/terraform.tfvars

cat ./variables/shared/shared.txt >> ./api_resources/terraform.tfvars

cat ./variables/develop/api.txt >> ./api_resources/terraform.tfvars

terraform -chdir=./api_resources apply

# CREATE API BIND
cat ./variables/shared/api_id.txt >> ./create_objects/terraform.tfvars
cat ./variables/shared/root_id.txt >> ./create_objects/terraform.tfvars

terraform -chdir=./create_objects apply --auto-approve

# CREATE API ROUTES
terraform -chdir=./create_objects output > ./api_routes/objects.auto.tfvars

terraform -chdir=./dev_fakes output > ./api/bucket.auto.tfvars

terraform -chdir=./api_resources output > ./api/resources.auto.tfvars

terraform -chdir=./api apply
