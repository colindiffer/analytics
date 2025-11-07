#!/bin/bash
set -e

# Update system
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release git

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable Docker service
systemctl enable docker
systemctl start docker

# Install Nginx for reverse proxy
apt-get install -y nginx certbot python3-certbot-nginx

# Create directory for Plausible
mkdir -p /opt/plausible
cd /opt/plausible

# Clone the repository or copy files
# We'll do this manually after VM is created

echo "VM setup complete. Ready to deploy Plausible."
