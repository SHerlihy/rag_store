#!/bin/bash

terraform -chdir=./prepare init
terraform -chdir=./deploy init

terraform -chdir=./prepare apply --auto-approve
terraform -chdir=./prepare output > ./deploy/terraform.tfvars
terraform -chdir=./deploy apply --auto-approve
