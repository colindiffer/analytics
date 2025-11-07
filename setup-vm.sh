#!/bin/bash
set -e

echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installing Nginx..."
sudo apt-get install -y nginx

echo "Configuring Docker authentication for GCR..."
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

echo "Setting up Plausible..."
sudo mkdir -p /opt/plausible
sudo cp /tmp/compose.yml /opt/plausible/docker-compose.yml
cd /opt/plausible

echo "Pulling Docker images..."
sudo docker compose pull

echo "Starting services..."
sudo docker compose up -d

echo "Configuring Nginx..."
sudo cp /tmp/nginx-plausible.conf /etc/nginx/sites-available/plausible
sudo ln -sf /etc/nginx/sites-available/plausible /etc/nginx/sites-enabled/plausible
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

echo "Setup complete! Plausible is running."
echo "Access at: http://34.171.136.250"
echo "After DNS is set up, run: sudo certbot --nginx -d analytics.propellernet.co.uk"
