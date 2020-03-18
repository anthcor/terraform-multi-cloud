#!/usr/bin/env bash
set -e

echo "--> Creating lb template file"
sudo mkdir -p /etc/consul-template.d
sudo tee /etc/consul-template.d/config.hcl > /dev/null <<"EOF"
log_level = "debug"

template {
  destination = "/etc/nginx/sites-enabled/default"
  command     = "sudo systemctl reload nginx"

  contents = <<EOH
upstream web {
  zone upstream-web 64k;
  {{range service "web"}}server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;
  {{else}}server 127.0.0.1:65535; # force a 502{{end}}
}

server {
  listen 80 default_server;

  location / {
    proxy_pass http://web;
  }
}
EOH
}
EOF
