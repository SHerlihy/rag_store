#!/bin/bash

TEST_KEY="allow"
ROOT_URL="$(terraform -chdir=./deploy output -raw api_path)"
BUCKET_NAME="$(terraform -chdir=./prepare output -raw bucket_name)"

BUCKET_URL=${ROOT_URL}/${BUCKET_NAME}
echo ${BUCKET_URL}

echo ${BUCKET_URL}
curl -s -o /dev/null -w "%{http_code}" -H "authorizationToken: something" -H "type: TOKEN" GET "${ROOT_URL}"
echo -e "\n"

LIST_URL="${BUCKET_URL}/list"
curl -s -o /dev/null -w "%{http_code}" -H 'Authorization: your-jwt-or-opaque-token-here' GET "${LIST_URL}"
echo -e "\n"

curl -X GET "${LIST_URL}" \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIwMDEiLCJpYXQiOjE2NzgwMDQ5MDAsImV4cCI6MTY3ODAwODUwMH0.S-gI7F3z-Y9C3hQp_B6X0n_V3O_4h_jT2f8B3N6r_gA'
echo -e "\n"

curl -X GET "${BUCKET_URL}/?authKey=deny"
echo -e "\n"

echo -e "Should succeed"
curl -X GET "${LIST_URL}/?authKey=${TEST_KEY}"
echo -e "\n"

# echo -e "\n"
# curl -X GET "${BUCKET_URL}/?authKey=${TEST_KEY}"
# echo -e "\n"

OBJECT_URL="${BUCKET_URL}/test"
echo -e ${OBJECT_URL}

curl -X GET "${OBJECT_URL}/?authKey=${TEST_KEY}"
echo -e "\n"

curl -X DELETE "${OBJECT_URL}/?authKey=${TEST_KEY}"
echo -e "\n"

curl -X GET "${LIST_URL}/?authKey=${TEST_KEY}"
echo -e "\n"
