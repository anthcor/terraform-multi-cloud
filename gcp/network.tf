data "google_compute_zones" "available" {}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = "${var.region}"
}

resource "google_compute_firewall" "default" {
  name    = "${var.namespace}-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["www"]
}
