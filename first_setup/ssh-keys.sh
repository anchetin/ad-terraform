#!/bin/bash

cd ./terraform-infra/ssh || exit 1

ssh-keygen -t ed25519 -C admin@adb -f ./adb_cluster
ssh-keygen -t ed25519 -C admin@adcm -f ./adcm_cluster
ssh-keygen -t ed25519 -C admin@nginx -f ./nginx_host