#!/usr/bin/env bash
set -e

echo "--> Setting up GCP join"
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config-gcp-wan.json > /dev/null <<"EOF"
{
  "retry_join_wan": ${aws_servers}
}
EOF
