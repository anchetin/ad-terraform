resources_zone          = "ru-central1-b"

centos7_image_id        = "fd8c6njq7cqrlr96p4r3"
metadata_path           = "user-data/metadata.yaml"
ssh_public_key          = "ssh/adcm_cluster.pub"
adcm_ssh_username       = "admin"

public_dns_zone_name    = "cluster-yctesting"
public_dns_zone         = "cluster.yctesting.eu.org."
public_dns_adcm         = "adcm.cluster.yctesting.eu.org."

local_dns_zone          = "cluster.local."

allowed_external_cidr   = ["46.146.230.116/32"]