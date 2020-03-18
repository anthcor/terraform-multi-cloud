data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    "Name" = "${var.namespace}"
  }
}

resource "aws_internet_gateway" "aws" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    "Name" = "${var.namespace}"
  }
}

resource "aws_subnet" "private" {
  count             = "${length(var.cidr_blocks)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.cidr_blocks[count.index]}"

  // TMP
  map_public_ip_on_launch = true

  tags {
    "Name" = "${var.namespace}-private-${count.index}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "10.1.5.0/24"
  map_public_ip_on_launch = true

  tags {
    "Name" = "${var.namespace}-public"
  }
}

resource "aws_vpn_gateway" "aws" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.aws.id}"
}

resource "aws_security_group" "nodes" {
  name_prefix = "${var.namespace}"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// resource "aws_security_group_rule" "server_egress" {
//   type              = "egress"
//   from_port         = 0
//   to_port           = 0
//   protocol          = "-1"
//   cidr_blocks       = ["0.0.0.0/0"]
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_tcp_ports_in" {
//   type      = "ingress"
//   from_port = 8300
//   to_port   = 8302
//   protocol  = "tcp"
//   self      = true
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_udp_ports_in" {
//   type      = "ingress"
//   from_port = 8301
//   to_port   = 8302
//   protocol  = "udp"
//   self      = true
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_http_api_in" {
//   type      = "ingress"
//   from_port = 8500
//   to_port   = 8500
//   protocol  = "tcp"
//   self      = true
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_dns_tcp_in" {
//   type      = "ingress"
//   from_port = 8600
//   to_port   = 8600
//   protocol  = "tcp"
//   self      = true
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_dns_udp_in" {
//   type      = "ingress"
//   from_port = 8600
//   to_port   = 8600
//   protocol  = "udp"
//   self      = true
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_tcp_ports_nodes" {
//   type                     = "ingress"
//   from_port                = 8300
//   to_port                  = 8301
//   protocol                 = "tcp"
//   source_security_group_id = "${aws_security_group.nomad_nodes.id}"
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_udp_ports_nodes" {
//   type                     = "ingress"
//   from_port                = 8301
//   to_port                  = 8301
//   protocol                 = "udp"
//   source_security_group_id = "${aws_security_group.nomad_nodes.id}"
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_http_api_nodes" {
//   type                     = "ingress"
//   from_port                = 8500
//   to_port                  = 8500
//   protocol                 = "tcp"
//   source_security_group_id = "${aws_security_group.nomad_nodes.id}"
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_dns_tcp_nodes" {
//   type                     = "ingress"
//   from_port                = 8600
//   to_port                  = 8600
//   protocol                 = "tcp"
//   source_security_group_id = "${aws_security_group.nomad_nodes.id}"
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }
//
// resource "aws_security_group_rule" "consul_server_dns_udp_nodes" {
//   type                     = "ingress"
//   from_port                = 8600
//   to_port                  = 8600
//   protocol                 = "udp"
//   source_security_group_id = "${aws_security_group.nomad_nodes.id}"
//
//   security_group_id = "${aws_security_group.nomad_servers.id}"
// }

