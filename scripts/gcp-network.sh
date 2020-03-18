#!/usr/bin/env bash
set -e

export PRIVATE_IP=$(curl --header "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
