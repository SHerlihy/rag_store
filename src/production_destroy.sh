#!/bin/bash

terraform -chdir=./api destroy --auto-approve
terraform -chdir=./production destroy --auto-approve
