#!/bin/bash
set -e

echo "🔧 Setting up Docker Resolver for container domains..."


# Copy sync script
echo "🔁 Backup hosts file do not delete that /etc/hosts.bkp"
sudo cp -p /etc/hosts /etc/hosts.bkp
echo "🔁 Installing docker-sync.sh"
sudo cp -p docker-sync /usr/local/bin/docker-sync
sudo chmod +x /usr/local/bin/docker-sync

# Setup systemd service
echo "🔧 Installing docker-sync.service"
sudo cp -p ./docker-sync.service /etc/systemd/system/docker-sync.service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now docker-sync.service
echo "✅ Installation complete. You can now resolve all container name as domains to your Docker containers."
sudo rm -rf $PWD
