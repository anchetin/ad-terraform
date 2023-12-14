#!/bin/bash

YC_TOKEN="$(yc iam create-token)"
export YC_TOKEN

YC_CLOUD_ID="$(yc config get cloud-id)"
export YC_CLOUD_ID

YC_FOLDER_ID="$(yc config get folder-id)"
export YC_FOLDER_ID

public_dns_zone_name=$(grep "public_dns_zone_name" variables.tfvars | cut -d '"' -f2)
public_dns_zone_id=$(yc dns zone get --name "$public_dns_zone_name" | grep "^id:" | cut -f2 -d " ")

terraform init -var-file="variables.tfvars"
terraform import -var-file="variables.tfvars" yandex_dns_zone.cluster_zone "$public_dns_zone_id"