#!/bin/bash

dir_root="./terraform-infra"

FILE=$dir_root/user-data/metadata_template.yaml.template
if [ ! -f "$FILE" ]; then
   echo "$FILE does not exist."
   exit 1
fi

metadata_template="$dir_root/user-data/metadata_template.yaml.template"

adcm_metadata="$dir_root/user-data/adcm_metadata.yaml"
adcm_ssh_pub_key="$dir_root/ssh/adcm_cluster.pub"

adb_metadata="$dir_root/user-data/adb_metadata.yaml"
adb_ssh_pub_key="$dir_root/ssh/adb_cluster.pub"

nginx_metadata="$dir_root/user-data/nginx_metadata.yaml"
nginx_ssh_pub_key="$dir_root/ssh/nginx_host.pub"

# Compile metadata function
function comp_meta {
    cat $metadata_template > "$1"
    ssh_pub=$(cat "$2")

    printf "
    ssh-authorized-keys:
    - $ssh_pub" >> "$1"
}

comp_meta $adcm_metadata $adcm_ssh_pub_key

comp_meta $adb_metadata $adb_ssh_pub_key

comp_meta $nginx_metadata $nginx_ssh_pub_key