### Security groups

resource "yandex_vpc_security_group" "icmp-internal" {
  name       = "icmp-internal"
  network_id = yandex_vpc_network.arenadata-network.id

  ingress {
    protocol          = "ICMP"
    predefined_target = "self_security_group"
  }
  egress {
    protocol          = "ICMP"
    predefined_target = "self_security_group"
  }

}

resource "yandex_vpc_security_group" "adcm-external-sg" {
  name       = "adcm-external-sg"
  network_id = yandex_vpc_network.arenadata-network.id

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

resource "yandex_vpc_security_group" "adcm-internal-sg" {
  name       = "adcm-internal-sg"
  network_id = yandex_vpc_network.arenadata-network.id

  #   ingress {
  #     protocol       = "TCP"
  #     description    = "allow ssh"
  #     v4_cidr_blocks = var.allowed_external_cidr
  #     port           = 22
  #   }
}
resource "yandex_vpc_security_group_rule" "adcm-internal-sg-r1" {
  security_group_binding = yandex_vpc_security_group.adcm-internal-sg.id
  direction              = "ingress"
  description            = "allow adcm 8000 from adb"
  security_group_id      = yandex_vpc_security_group.adb-hosts-sg.id
  port                   = 8000
  protocol               = "TCP"
}


resource "yandex_vpc_security_group" "adb-hosts-sg" {
  name        = "adb-hosts-sg"
  description = "for ADB hosts"
  network_id  = yandex_vpc_network.arenadata-network.id

  ingress {
    protocol       = "TCP"
    description    = "allow ssh"
    v4_cidr_blocks = ["10.0.0.0/8"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "allow SQL connects"
    v4_cidr_blocks = ["10.0.0.0/8"]
    port           = 5432
  }
  ingress {
    protocol          = "TCP"
    description       = "ssh between hosts"
    predefined_target = "self_security_group"
    port              = 22
  }
  ingress {
    protocol          = "UDP"
    description       = "allow NTP between hosts"
    predefined_target = "self_security_group"
    port              = 123
  }
  ingress {
    protocol          = "UDP"
    description       = "Interconnect"
    predefined_target = "self_security_group"
    from_port         = 10000
    to_port           = 12000
  }
  ingress {
    protocol          = "TCP"
    description       = "Gpperfmon agents"
    predefined_target = "self_security_group"
    port              = 8888
  }
  ingress {
    protocol          = "TCP"
    description       = "PXF"
    predefined_target = "self_security_group"
    port              = 5888
  }
  ingress {
    protocol          = "TCP"
    description       = "gpbackup1"
    predefined_target = "self_security_group"
    port              = 25
  }
  ingress {
    protocol          = "TCP"
    description       = "gpbackup2"
    predefined_target = "self_security_group"
    port              = 587
  }
  ingress {
    protocol          = "TCP"
    description       = "gpfdist"
    predefined_target = "self_security_group"
    port              = 8080
  }
  ingress {
    protocol          = "TCP"
    description       = "gpload"
    predefined_target = "self_security_group"
    from_port         = 8000
    to_port           = 9000
  }

  egress {
    protocol          = "TCP"
    description       = "to ADCM"
    security_group_id = yandex_vpc_security_group.adcm-internal-sg.id
    port              = 8000
  }
  egress {
    protocol          = "UDP"
    description       = "allow NTP between hosts"
    predefined_target = "self_security_group"
    port              = 123
  }
  egress {
    protocol       = "ANY"
    description    = "allow internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "monitoring-cluster-sg" {
  name       = "monitoring-cluster-sg"
  network_id = yandex_vpc_network.arenadata-network.id
  ingress {
    protocol          = "TCP"
    description       = "allow metrics from adb"
    security_group_id = yandex_vpc_security_group.adb-hosts-sg.id
    port              = 2015
  }
  ingress {
    protocol          = "UDP"
    description       = "allow metrics from adb"
    security_group_id = yandex_vpc_security_group.adb-hosts-sg.id
    port              = 2016
  }
  ingress {
    protocol       = "TCP"
    description    = "allow graphana from external"
    v4_cidr_blocks = var.allowed_external_cidr
    port           = 3000
  }
  ingress {
    protocol       = "TCP"
    description    = "allow graphite from external"
    v4_cidr_blocks = var.allowed_external_cidr
    port           = 80
  }

}

resource "yandex_vpc_security_group" "master-slave-adb" {
  name       = "master-slave-adb"
  network_id = yandex_vpc_network.arenadata-network.id
  ingress {
    protocol          = "TCP"
    description       = "Standby master replicator"
    predefined_target = "self_security_group"
    from_port         = 1025
    to_port           = 65535
  }

}