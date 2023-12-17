#!/bin/bash

YC_TOKEN="$(yc iam create-token)"
export YC_TOKEN

YC_CLOUD_ID="$(yc config get cloud-id)"
export YC_CLOUD_ID

YC_FOLDER_ID="$(yc config get folder-id)"
export YC_FOLDER_ID

variables_file="variables.tfvars"

metadata_template="./user-data/metadata_template.yaml"
adcm_metadata="./user-data/adcm_metadata.yaml"
adcm_ssh_pub_key="./ssh/adcm_cluster.pub"
adb_metadata="./user-data/adb_metadata.yaml"
adb_ssh_pub_key="./ssh/adb_cluster.pub"

# Check if init done
FILE="./.terraform"
if ! test -d "$FILE"; then
   echo "Run ./init-terraform.sh first"
   exit 1
fi

# Check if no arguments were passed
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please use -p/--plan, -v/--validate or -a/--apply flag."
    exit 1
fi

# Compile metadata
cat $metadata_template > $adcm_metadata
ssh_pub=$(cat $adcm_ssh_pub_key)

printf "
    ssh-authorized-keys:
      - $ssh_pub" >> $adcm_metadata

cat $metadata_template > $adb_metadata
ssh_pub=$(cat $adb_ssh_pub_key)

printf "
    ssh-authorized-keys:
      - $ssh_pub" >> $adb_metadata


# Function for terraform validate
function validate {
    echo "Running terraform validate..."
    if ! terraform validate ; then
        echo "Validation failed. Exiting..."
        exit 1
    else
        echo "Validation succeeded."
    fi
}

# Check for validate flag
if [ "$1" == "-v" ] || [ "$1" == "--validate" ]; then
    validate
fi

# Check for plan flag
if [ "$1" == "-p" ] || [ "$1" == "--plan" ]; then
    validate
    echo "Running terraform plan..."
    terraform plan -var-file="$variables_file"
fi

# Check for apply flag
if [ "$1" == "-a" ] || [ "$1" == "--apply" ]; then
    validate
    echo "Running terraform apply..."
    terraform apply -var-file="$variables_file"
fi

# Check for destroy flag
if [ "$1" == "-d" ] || [ "$1" == "--destroy" ]; then
    echo "Running terraform destroy..."
    terraform destroy -var-file="$variables_file"
fi