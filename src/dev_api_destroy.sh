#!/bin/bash

terraform -chdir=./api destroy --auto-approve
terraform -chdir=./dev_fakes destroy --auto-approve
