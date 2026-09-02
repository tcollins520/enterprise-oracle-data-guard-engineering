#!/bin/bash
set -euxo pipefail

# Update packages
dnf -y update

# Install SSM Agent if it is not already installed
if ! rpm -q amazon-ssm-agent >/dev/null 2>&1; then
    dnf install -y amazon-ssm-agent
fi

# Enable and start SSM Agent
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent