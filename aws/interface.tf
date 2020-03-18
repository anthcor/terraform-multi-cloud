variable "namespace" {}

variable "region" {
  type = "string"
}

variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}

variable "cidr_blocks" {
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "num_servers" {
  default = "3"
}

variable "num_nodes" {
  default = "3"
}

output "cidr" {
  value = "${var.vpc_cidr_block}"
}

output "region" {
  value = "${var.region}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpn_gateway" {
  value = "${aws_vpn_gateway.aws.id}"
}

output "nomad_servers_sg" {
  value = "${aws_security_group.nodes.id}"
}

output "route_table_id" {
  value = "${aws_vpc.vpc.main_route_table_id}"
}

output "server_ips" {
  value = ["${aws_instance.server.*.private_ip}"]
}

output "lb_addr" {
  value = "${aws_instance.lb.public_ip}"
}
