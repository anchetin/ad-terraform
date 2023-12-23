#!/bin/bash

cd ./terraform-infra || exit 1

YC_TOKEN="$(yc iam create-token)"
export YC_TOKEN

YC_CLOUD_ID="$(yc config get cloud-id)"
export YC_CLOUD_ID

YC_FOLDER_ID="$(yc config get folder-id)"
export YC_FOLDER_ID

variables_file="variables.tfvars"


# Check if init done
if ! test -d "./.terraform"; then
   echo "Run ./first_setup/init-terraform.sh first"
   exit 1
fi

# Check if no arguments were passed
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please use -p/--plan, -v/--validate or -a/--apply flag."
    exit 1
fi


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