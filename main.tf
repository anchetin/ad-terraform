terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.resources_zone
}


### variables
variable "resources_zone" {}

variable "centos7_image_id" {}
variable "metadata_path" {}
variable "ssh_public_key" {}
variable "adcm_ssh_username" {}

variable "public_dns_zone_name" {}
variable "public_dns_zone" {}
variable "public_dns_adcm" {}

variable "local_dns_zone" {}

variable "allowed_external_cidr" {type = list}


### Network and subnets
resource "yandex_vpc_network" "arenadata-network" {
  name = "arenadata-network"
}

resource "yandex_dns_zone" "cluster_zone" {
  name = var.public_dns_zone_name
  zone = var.public_dns_zone
}

resource "yandex_dns_zone" "cluster_local_zone" {
  name   = "cluster-local"
  zone   = var.local_dns_zone
  public = false
  private_networks = [yandex_vpc_network.arenadata-network.id]
}


resource "yandex_vpc_subnet" "adcm-subnet" {
  v4_cidr_blocks = ["10.152.0.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.arenadata-network.id
}

resource "yandex_vpc_subnet" "adb-subnet" {
  v4_cidr_blocks = ["10.152.1.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.arenadata-network.id
}

resource "yandex_vpc_subnet" "adqm-subnet" {
  v4_cidr_blocks = ["10.152.2.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.arenadata-network.id
}


resource "yandex_vpc_address" "adcm_external_ip" {
  name = "adcm_external_ip"

  external_ipv4_address {
    zone_id = var.resources_zone
  }
}
resource "yandex_dns_recordset" "dns_adcm_host" {
  zone_id = yandex_dns_zone.cluster_zone.id
  name    = var.public_dns_adcm
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.adcm_external_ip.external_ipv4_address[0].address]
}

### Security groups
resource "yandex_vpc_security_group" "adcm-sg" {
  name        = "adcm-sg"
  description = "for ADCM host"
  network_id  = yandex_vpc_network.arenadata-network.id

  ingress {
    protocol       = "TCP"
    description    = "allow ssh"
    v4_cidr_blocks = var.allowed_external_cidr
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "allow https"
    v4_cidr_blocks = var.allowed_external_cidr
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "allow http"
    v4_cidr_blocks = var.allowed_external_cidr
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "allow adcm 8000"
    v4_cidr_blocks = var.allowed_external_cidr
    port           = 8000
  }

  egress {
    protocol       = "ANY"
    description    = "egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

### ADCM
resource "yandex_compute_instance" "adcm-host" {
  name = "adcm-host"

  resources {
    cores  = 4
    memory = 16
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
    subnet_id   = yandex_vpc_subnet.adcm-subnet.id
    nat         = true
    nat_ip_address = yandex_vpc_address.adcm_external_ip.external_ipv4_address[0].address
    dns_record {
        fqdn = "adcm.${var.local_dns_zone}"
        dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [yandex_vpc_security_group.adcm-sg.id]
  }

  metadata = {
    user-data = "${file(var.metadata_path)}"
    ssh-keys  = "${var.adcm_ssh_username}:${file(var.ssh_public_key)}"
  }
}
