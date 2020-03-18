resource "google_compute_http_health_check" "default" {
  name                = "${var.namespace}-check"
  request_path        = "/"
  check_interval_sec  = 5
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 3
}

resource "google_compute_target_pool" "default" {
  name          = "${var.namespace}-target-pool"
  instances     = ["${google_compute_instance.node.*.self_link}"]
  health_checks = ["${google_compute_http_health_check.default.name}"]
}

resource "google_compute_forwarding_rule" "default" {
  name       = "${var.namespace}-forwarding-rule"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = "80"
}
