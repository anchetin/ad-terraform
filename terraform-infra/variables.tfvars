resources_zone = "ru-central1-b"


centos7_image_id  = "fd8c6njq7cqrlr96p4r3"
debian12_image_id = "fd8aqo6nefi5b2dn1b4s"

adcm_metadata_path  = "user-data/adcm_metadata.yaml"
adcm_ssh_public_key = "ssh/adcm_cluster.pub"
adcm_ssh_username   = "admin"

adb_metadata_path  = "user-data/adb_metadata.yaml"
adb_ssh_public_key = "ssh/adb_cluster.pub"
adb_ssh_username   = "admin"

nginx_metadata_path   = "user-data/nginx_metadata.yaml"
nginx_ssh_public_key  = "ssh/nginx_host.pub"
nginx_ssh_username    = "admin"
public_dns_adcm_nginx = "adcm-temp.cluster.yctesting.eu.org."

public_dns_zone_name = "cluster-yctesting"
public_dns_zone      = "cluster.yctesting.eu.org."
public_dns_adcm      = "adcm.cluster.yctesting.eu.org."
public_dns_grafana   = "grafana.cluster.yctesting.eu.org."
public_dns_graphite  = "graphite.cluster.yctesting.eu.org."


local_dns_zone = "cluster.local."

allowed_external_cidr = ["46.146.230.116/32"]