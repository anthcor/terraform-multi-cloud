#!/usr/bin/env bash
set -e

export PRIVATE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
