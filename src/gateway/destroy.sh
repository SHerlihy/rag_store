#!/bin/bash

terraform -chdir=./deploy destroy --auto-approve
terraform -chdir=./prepare destroy --auto-approve
