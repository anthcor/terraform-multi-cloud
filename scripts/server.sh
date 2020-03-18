#!/usr/bin/env bash
set -e

echo "--> Writing configuration"
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config-server.json > /dev/null <<"EOF"
{
  "bootstrap_expect": ${servers},
  "server": true
}
EOF
