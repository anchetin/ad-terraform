### ADQM
resource "yandex_compute_instance" "adqm-host" {
  name = "adqm-host"

  resources {
    cores  = 4
    memory = 16
  }

  boot_disk {
    initialize_params {
      image_id = var.centos7_image_id
      name     = "adqm-root-disk"
      size     = 50
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.adqm-subnet.id
    nat       = false
    dns_record {
      fqdn        = "adqm.${var.local_dns_zone}"
      dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [
      yandex_vpc_security_group.adqm-internal-sg.id,
      yandex_vpc_security_group.icmp-internal.id
    ]
  }

  metadata = {
    user-data = "${file(var.adb_metadata_path)}"
    ssh-keys  = "${var.adb_ssh_username}:${file(var.adb_ssh_public_key)}"
  }

  allow_stopping_for_update = true
}
