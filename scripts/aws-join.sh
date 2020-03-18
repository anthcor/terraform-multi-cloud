#!/usr/bin/env bash
set -e

echo "--> Setting up AWS join"
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config-aws.json > /dev/null <<"EOF"
{
  "datacenter": "aws-${region}",
  "retry_join_ec2": {
    "tag_key": "Consul-Join",
    "tag_value": "consul-is-awesome"
  }
}
EOF
