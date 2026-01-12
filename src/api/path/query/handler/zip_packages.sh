#!/bin/bash

rm -f ./my_deployment_package.zip
rm -rf ./package

mkdir package

pip install --target ./package boto3

cd package
zip -r ../my_deployment_package.zip .
