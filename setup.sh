#!/bin/bash
set -e

echo "🔧 Setting up Docker Resolver for .test domains..."

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "❌ Cannot determine Linux distribution"
    exit 1
fi

echo "📦 Installing required packages..."
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" || "$DISTRO" == "kali" ]]; then
    sudo apt-get update
    sudo apt-get install -y dnsmasq
elif [[ "$DISTRO" == "arch" || "$DISTRO" == "manjaro" ]]; then
    sudo pacman -Sy --noconfirm dnsmasq
else
    echo "❌ Unsupported distro: $DISTRO"
    exit 1
fi

# Disable systemd-resolved to free port 53
if systemctl is-active --quiet systemd-resolved; then
    echo "⚠️  Disabling systemd-resolved..."
    sudo systemctl disable --now systemd-resolved
    sudo rm -f /etc/resolv.conf
    echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
    echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null
fi

# Setup NetworkManager config (if present)
if [ -f ./NetworkManager.conf ]; then
    echo "📄 Installing NetworkManager.conf"
    sudo cp -p ./NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
    sudo systemctl restart NetworkManager
fi

# Setup dnsmasq config
echo "📄 Configuring dnsmasq..."
sudo cp -p ./dnsmasq.conf /etc/dnsmasq.conf
sudo mkdir -p /etc/dnsmasq.d
sudo touch /etc/docker-dnsmasq-hosts

# Copy sync script
echo "🔁 Installing docker-dnsmasq-sync.sh"
sudo cp -p ./docker-dnsmasq-sync.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-dnsmasq-sync.sh

# Setup systemd service
echo "🔧 Installing docker-dnsmasq-sync.service"
sudo cp -p ./docker-dnsmasq-sync.service /etc/systemd/system/docker-dnsmasq-sync.service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now docker-dnsmasq-sync.service

# Start dnsmasq
echo "🚀 Starting dnsmasq..."
sudo systemctl restart dnsmasq

echo "✅ Installation complete. You can now resolve *.test domains to your Docker containers."
