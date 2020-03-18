#!/usr/bin/env bash
set -e

echo "--> Registering service"
sudo tee /etc/consul.d/web.json > /dev/null <<EOF
{
  "service": {
    "name": "web",
    "port": 80,
    "check": {
      "http": "http://127.0.0.1:80",
      "interval": "5s",
      "timeout": "2s"
    }
  }
}
EOF
