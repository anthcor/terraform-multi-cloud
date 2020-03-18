data "template_file" "lb" {
  template = <<EOF
${file("${path.module}/../scripts/aws-network.sh")}
${file("${path.module}/../scripts/aws-join.sh")}
${file("${path.module}/../scripts/provision.sh")}
${file("${path.module}/../scripts/lb.sh")}
${file("${path.module}/../scripts/cleanup.sh")}
EOF

  vars {
    hostname = "aws-lb"
    region   = "${var.region}"
  }
}

resource "aws_instance" "lb" {
  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "t2.small"
  key_name      = "${aws_key_pair.key.id}"

  subnet_id              = "${element(aws_subnet.public.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]

  tags {
    "Name"        = "aws-lb"
    "Consul-Join" = "consul-is-awesome"
  }

  user_data = "${data.template_file.lb.rendered}"
}
