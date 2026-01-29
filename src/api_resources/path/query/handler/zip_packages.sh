#!/bin/bash

rm -f ./my_deployment_package.zip
rm -rf ./package

mkdir package

pip install --target ./package boto3
pip install --target ./package ./query_utils

cd package
zip -r ../my_deployment_package.zip .
