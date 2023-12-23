### Network and subnets
resource "yandex_vpc_network" "arenadata-network" {
  name = "arenadata-network"
}

resource "yandex_dns_zone" "cluster_zone" {
  name = var.public_dns_zone_name
  zone = var.public_dns_zone
}

resource "yandex_dns_zone" "cluster_local_zone" {
  name             = "cluster-local"
  zone             = var.local_dns_zone
  public           = false
  private_networks = [yandex_vpc_network.arenadata-network.id]
}
# If monitoring on ACDM host
resource "yandex_dns_recordset" "monitoring-in-adcm" {
  zone_id = yandex_dns_zone.cluster_local_zone.id
  name    = "monitoring.cluster.local."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.adcm-host.network_interface.0.ip_address]
}

resource "yandex_vpc_subnet" "adcm-subnet" {
  name           = "adcm-subnet"
  v4_cidr_blocks = ["10.152.0.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.arenadata-network.id
}

resource "yandex_vpc_subnet" "adb-subnet" {
  name           = "adb-subnet"
  v4_cidr_blocks = ["10.152.1.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.arenadata-network.id
  route_table_id = yandex_vpc_route_table.egress-route-adb.id
}
resource "yandex_vpc_gateway" "egress-gateway-adb" {
  name = "egress-gateway-adb"
  shared_egress_gateway {}
}
resource "yandex_vpc_route_table" "egress-route-adb" {
  network_id = yandex_vpc_network.arenadata-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.egress-gateway-adb.id
  }
}



resource "yandex_vpc_subnet" "adqm-subnet" {
  name           = "adqm-subnet"
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

resource "yandex_vpc_subnet" "nginx-subnet" {
  name           = "nginx-subnet"
  v4_cidr_blocks = ["10.152.3.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.arenadata-network.id
}
resource "yandex_vpc_address" "nginx_external_ip" {
  name = "nginx_external_ip"

  external_ipv4_address {
    zone_id = var.resources_zone
  }
}
resource "yandex_dns_recordset" "dns_adcm_nginx" {
  zone_id = yandex_dns_zone.cluster_zone.id
  name    = var.public_dns_adcm
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.nginx_external_ip.external_ipv4_address[0].address]
}
resource "yandex_dns_recordset" "dns_grafana_nginx" {
  zone_id = yandex_dns_zone.cluster_zone.id
  name    = var.public_dns_grafana
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.nginx_external_ip.external_ipv4_address[0].address]
}
resource "yandex_dns_recordset" "dns_graphite_nginx" {
  zone_id = yandex_dns_zone.cluster_zone.id
  name    = var.public_dns_graphite
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.nginx_external_ip.external_ipv4_address[0].address]
}
