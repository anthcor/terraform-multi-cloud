provider "google" {}

variable "namespace" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "aws_servers" {
  type = "list"
}

variable "num_servers" {
  default = "3"
}

variable "num_nodes" {
  default = "3"
}

output "cidr" {
  value = "${data.google_compute_subnetwork.default.ip_cidr_range}"
}

output "region" {
  value = "${var.region}"
}

output "lb_addr" {
  value = "${google_compute_forwarding_rule.default.ip_address}"
}
