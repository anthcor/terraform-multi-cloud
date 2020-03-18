data "template_file" "server" {
  count = "${var.num_servers}"

  template = <<EOF
${file("${path.module}/../scripts/gcp-network.sh")}
${file("${path.module}/../scripts/gcp-join.sh")}
${file("${path.module}/../scripts/gcp-join-wan.sh")}
${file("${path.module}/../scripts/server.sh")}
${file("${path.module}/../scripts/provision.sh")}
${file("${path.module}/../scripts/cleanup.sh")}
EOF

  vars {
    hostname    = "gcp-server-${count.index}"
    servers     = "${var.num_servers}"
    region      = "${var.region}"
    aws_servers = "[${join(", ", formatlist("\"%s\"", var.aws_servers))}]"
  }
}

resource "google_compute_instance" "server" {
  count        = "${var.num_servers}"
  name         = "${var.namespace}-gcp-server-${count.index}"
  machine_type = "n1-standard-2"
  zone         = "${data.google_compute_zones.available.names[count.index]}"

  tags = ["consul-is-awesome"]

  can_ip_forward = true

  disk {
    image = "ubuntu-1604-lts"
  }

  disk {
    type    = "local-ssd"
    scratch = true
  }

  metadata {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${element(data.template_file.server.*.rendered, count.index)}"
  }

  network_interface {
    network = "default"

    access_config {}
  }

  service_account {
    scopes = [
      "compute-ro",
      "storage-ro",
    ]
  }
}
