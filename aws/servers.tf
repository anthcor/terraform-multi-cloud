data "template_file" "server" {
  count = "${var.num_servers}"

  template = <<EOF
${file("${path.module}/../scripts/aws-network.sh")}
${file("${path.module}/../scripts/aws-join.sh")}
${file("${path.module}/../scripts/server.sh")}
${file("${path.module}/../scripts/provision.sh")}
${file("${path.module}/../scripts/cleanup.sh")}
EOF

  vars {
    hostname = "aws-server-${count.index}"
    servers  = "${var.num_servers}"
    region   = "${var.region}"
  }
}

resource "aws_instance" "server" {
  count = "${var.num_servers}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "t2.small"
  key_name      = "${aws_key_pair.key.id}"

  subnet_id              = "${element(aws_subnet.private.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]

  tags {
    "Name"        = "aws-server-${count.index}"
    "Consul-Join" = "consul-is-awesome"
  }

  user_data = "${element(data.template_file.server.*.rendered, count.index)}"
}
