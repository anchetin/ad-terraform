#!/bin/bash

hosts=("adb-master.cluster.local" "adb-segment-1.cluster.local" "adb-segment-2.cluster.local")
adcm_host_external="adcm.cluster.yctesting.eu.org"
adcm_host_internal="adcm.cluster.local"
adcm_ssh_privkey="ssh/adcm_cluster"
adb_ssh_privkey="ssh/adb_cluster"
username="admin"

# Loop over the hosts
for host in "${hosts[@]}"; do
 # Connect to the host and change the hostname
 ssh -J $username@$adcm_host_external -i $adcm_ssh_privkey -i $adb_ssh_privkey $username@$host "sudo hostnamectl set-hostname $host && sudo reboot"
done

ssh -i $adcm_ssh_privkey $username@$adcm_host_external "sudo hostnamectl set-hostname $adcm_host_internal && sudo reboot"
