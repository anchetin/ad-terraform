### ADB Master
resource "yandex_compute_instance" "adb-master-host" {
  name = "adb-master-host"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.centos7_image_id
      name     = "adb-master-root-disk"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.adb-subnet.id
    nat       = false
    dns_record {
      fqdn        = "adb-master.${var.local_dns_zone}"
      dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [
      yandex_vpc_security_group.icmp-internal.id,
      yandex_vpc_security_group.adb-hosts-sg.id,
      yandex_vpc_security_group.master-slave-adb.id
    ]
  }

  metadata = {
    user-data = "${file(var.adb_metadata_path)}"
    ssh-keys  = "${var.adb_ssh_username}:${file(var.adb_ssh_public_key)}"
  }
}

### ADB segment-1
resource "yandex_compute_instance" "adb-segment-1" {
  name = "adb-segment-1"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.centos7_image_id
      name     = "adb-segment-1-root-disk"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.adb-subnet.id
    nat       = false
    dns_record {
      fqdn        = "adb-segment-1.${var.local_dns_zone}"
      dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [
      yandex_vpc_security_group.icmp-internal.id,
      yandex_vpc_security_group.adb-hosts-sg.id
    ]
  }

  metadata = {
    user-data = "${file(var.adb_metadata_path)}"
    ssh-keys  = "${var.adb_ssh_username}:${file(var.adb_ssh_public_key)}"
  }
}

### ADB segment-2
resource "yandex_compute_instance" "adb-segment-2" {
  name = "adb-segment-2"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.centos7_image_id
      name     = "adb-segment-2-root-disk"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.adb-subnet.id
    nat       = false
    dns_record {
      fqdn        = "adb-segment-2.${var.local_dns_zone}"
      dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [
      yandex_vpc_security_group.icmp-internal.id,
      yandex_vpc_security_group.adb-hosts-sg.id
    ]
  }

  metadata = {
    user-data = "${file(var.adb_metadata_path)}"
    ssh-keys  = "${var.adb_ssh_username}:${file(var.adb_ssh_public_key)}"
  }
}
