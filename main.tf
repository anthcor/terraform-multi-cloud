resource "random_id" "shared_secret" {
  byte_length = 12
}

module "vpn" {
  source = "./vpn"

  aws_cidr           = "${module.aws.cidr}"
  gcp_cidr           = "${module.gcp.cidr}"
  aws_region         = "${module.aws.region}"
  gcp_region         = "${module.gcp.region}"
  shared_secret      = "${random_id.shared_secret.hex}"
  aws_vpc            = "${module.aws.vpc_id}"
  aws_sg             = "${module.aws.nomad_servers_sg}"
  aws_route_table_id = "${module.aws.route_table_id}"
  aws_vpn_gateway    = "${module.aws.vpn_gateway}"
}

module "aws" {
  source = "./aws"

  region    = "${var.aws_region}"
  namespace = "${var.namespace}"
}

module "gcp" {
  source = "./gcp"

  region    = "${var.gcp_region}"
  namespace = "${var.namespace}"

  aws_servers = ["${module.aws.server_ips}"]
}

resource "cloudflare_record" "aws" {
  domain  = "hashicorp.rocks"
  name    = "terraform"
  value   = "${module.aws.lb_addr}"
  type    = "A"
  ttl     = "1"
  proxied = "1"
}

resource "cloudflare_record" "gcp" {
  domain  = "hashicorp.rocks"
  name    = "terraform"
  value   = "${module.gcp.lb_addr}"
  type    = "A"
  ttl     = "1"
  proxied = "1"
}
