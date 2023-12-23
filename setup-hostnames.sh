#!/bin/bash

cd ./terraform-infra || exit 1

username="admin"

adcm_host_external="adcm.cluster.yctesting.eu.org"
adcm_host_internal="adcm.cluster.local"
adcm_ssh_privkey="ssh/adcm_cluster"

hosts=("adb-master.cluster.local" "adb-segment-1.cluster.local" "adb-segment-2.cluster.local")
adb_ssh_privkey="ssh/adb_cluster"

scp -i $adcm_ssh_privkey $adb_ssh_privkey $username@$adcm_host_external:~/.ssh/adb_cluster

echo "Trying to connect to $adcm_host_external"
cat > script.sh << EOF

    echo "Successfully connected to $adcm_host_external"

    username=$username
    hosts=(${hosts[@]})
    adcm_host_external=$adcm_host_external
    adcm_host_internal=$adcm_host_internal

    chmod 0600 ~/.ssh/adb_cluster

    for host in "\${hosts[@]}"; do
      ssh -o StrictHostKeyChecking=no -i ~/.ssh/adb_cluster $username@\$host "sudo hostnamectl set-hostname \$host && sudo reboot"
      sleep 3
      echo "Changed hostname for \$host and rebooted"
    done

    adcm_hostname_cmd=\$(hostname)
    if [ "\$adcm_hostname_cmd" == $adcm_host_internal ]; then
      echo "\$adcm_hostname_cmd is already correct. Nothing more to do."
      exit 0
    else
      echo "Changing hostname for $adcm_host_internal"
      sudo hostnamectl set-hostname $adcm_host_internal && sudo reboot
    fi

    exit 0
EOF

scp -i $adcm_ssh_privkey ./script.sh $username@$adcm_host_external:~/hostname-script.sh 
ssh -i $adcm_ssh_privkey $username@$adcm_host_external "bash ~/hostname-script.sh"

rm ./script.sh

exit 0