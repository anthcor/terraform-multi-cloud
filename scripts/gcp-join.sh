#!/usr/bin/env bash
set -e

echo "--> Setting up GCP join"
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config-gcp.json > /dev/null <<"EOF"
{
  "datacenter": "gcp-${region}",
  "retry_join_gce": {
    "tag_value": "consul-is-awesome",
    "zone_pattern": "${region}-.*"
  }
}
EOF
