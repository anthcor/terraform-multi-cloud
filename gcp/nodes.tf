data "template_file" "node" {
  count = "${var.num_nodes}"

  template = <<EOF
${file("${path.module}/../scripts/gcp-network.sh")}
${file("${path.module}/../scripts/gcp-join.sh")}
${file("${path.module}/../scripts/provision.sh")}
${file("${path.module}/../scripts/service.sh")}
${file("${path.module}/../scripts/cleanup.sh")}
EOF

  vars {
    hostname = "gcp-node-${count.index}"
    region   = "${var.region}"
  }
}

resource "google_compute_instance" "node" {
  count        = "${var.num_nodes}"
  name         = "${var.namespace}-gcp-node-${count.index}"
  machine_type = "n1-standard-2"
  zone         = "${data.google_compute_zones.available.names[count.index]}"

  tags = ["consul-is-awesome", "www"]

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
    user-data = "${element(data.template_file.node.*.rendered, count.index)}"
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
