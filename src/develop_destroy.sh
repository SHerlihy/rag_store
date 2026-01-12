#!/bin/bash

terraform -chdir=./api destroy --auto-approve
terraform -chdir=./develop destroy --auto-approve
