#!/bin/bash

ROOT_URL="$(terraform output -raw api_path)"

echo ${ROOT_URL}
curl -s -o /dev/null -w "%{http_code}" GET ${ROOT_URL}
echo -e "\n"

LIST_URL="${ROOT_URL}/bucket/list"
echo ${LIST_URL}
curl -s -o /dev/null -w "%{http_code}" GET ${LIST_URL}
