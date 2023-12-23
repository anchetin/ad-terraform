#!/bin/bash

cd ./terraform-infra || exit 1

rm -rf ./.terraform
rm -rf ./terraform.tfstate*
rm -rf ./.terraform.lock*
