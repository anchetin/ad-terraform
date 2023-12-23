### ADCM
resource "yandex_compute_instance" "adcm-host" {
  name = "adcm-host"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.centos7_image_id
      name     = "adcm-root-disk"
      size     = 50
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.adcm-subnet.id
    nat            = true
    nat_ip_address = yandex_vpc_address.adcm_external_ip.external_ipv4_address[0].address
    dns_record {
      fqdn        = "adcm.${var.local_dns_zone}"
      dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [
      yandex_vpc_security_group.adcm-external-sg.id,
      yandex_vpc_security_group.adcm-internal-sg.id,
      yandex_vpc_security_group.icmp-internal.id,
      yandex_vpc_security_group.monitoring-cluster-sg.id
    ]
  }

  metadata = {
    user-data = "${file(var.adcm_metadata_path)}"
    ssh-keys  = "${var.adcm_ssh_username}:${file(var.adcm_ssh_public_key)}"
  }

  allow_stopping_for_update = true
}
