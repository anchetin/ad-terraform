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


variable "resources_zone" {}

variable "centos7_image_id" {}
variable "debian12_image_id" {}

variable "adcm_metadata_path" {}
variable "adcm_ssh_public_key" {}
variable "adcm_ssh_username" {}

variable "adb_metadata_path" {}
variable "adb_ssh_public_key" {}
variable "adb_ssh_username" {}

variable "nginx_metadata_path" {}
variable "nginx_ssh_public_key" {}
variable "nginx_ssh_username" {}
variable "public_dns_adcm_nginx" {}

variable "public_dns_zone_name" {}
variable "public_dns_zone" {}
variable "public_dns_adcm" {}
variable "public_dns_grafana" {}
variable "public_dns_graphite" {}

variable "local_dns_zone" {}

variable "allowed_external_cidr" { type = list(any) }