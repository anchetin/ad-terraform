### Nginx
resource "yandex_compute_instance" "nginx-host" {
  name = "nginx"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.debian12_image_id
      name     = "nginx-root-disk"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.nginx-subnet.id
    nat            = true
    nat_ip_address = yandex_vpc_address.nginx_external_ip.external_ipv4_address[0].address
    dns_record {
      fqdn        = "nginx.${var.local_dns_zone}"
      dns_zone_id = yandex_dns_zone.cluster_local_zone.id
    }
    security_group_ids = [
      yandex_vpc_security_group.nginx-external-sg.id,
      yandex_vpc_security_group.icmp-internal.id
    ]
  }

  metadata = {
    user-data = "${file(var.nginx_metadata_path)}"
    ssh-keys  = "${var.nginx_ssh_username}:${file(var.nginx_ssh_public_key)}"
  }

  allow_stopping_for_update = true
}