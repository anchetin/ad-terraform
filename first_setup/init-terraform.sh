#!/bin/bash

cd ./terraform-infra || exit 1

YC_TOKEN="$(yc iam create-token)"
export YC_TOKEN

YC_CLOUD_ID="$(yc config get cloud-id)"
export YC_CLOUD_ID

YC_FOLDER_ID="$(yc config get folder-id)"
export YC_FOLDER_ID

TF_CLI_CONFIG_FILE="./.terraformrc"
export TF_CLI_CONFIG_FILE

public_dns_zone_name=$(grep "public_dns_zone_name" variables.tfvars | cut -d '"' -f2)
yc_get_output=$(yc dns zone get --name "$public_dns_zone_name") || { printf "\nFailed to get DNS zone. Check the ERROR output.\n"; exit 1; }
public_dns_zone_id=$(echo "$yc_get_output" | grep "^id:" | cut -f2 -d " ")

terraform init -var-file="variables.tfvars"
terraform providers lock -net-mirror=https://terraform-mirror.yandexcloud.net -platform=linux_amd64 -platform=darwin_arm64 yandex-cloud/yandex
terraform import -var-file="variables.tfvars" yandex_dns_zone.cluster_zone "$public_dns_zone_id"