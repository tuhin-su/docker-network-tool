#!/bin/bash
set -e

BIN_DIR="/usr/local/bin"

sudo systemctl disable docker.socket --now
sudo systemctl disable docker --now

echo "[+] Copying docker-up..."
sudo cp docker-up $BIN_DIR/docker-up

echo "[+] Copying docker-down..."
sudo cp docker-down $BIN_DIR/docker-down

echo "[+] Making scripts executable..."
sudo chmod +x $BIN_DIR/docker-up $BIN_DIR/docker-down

echo "[+] Disabling Docker auto-start at boot..."
sudo systemctl disable docker docker.socket

echo "[+] Installing Network tool..."
sudo ./setup.sh

echo "[+] Installation complete!"
echo "    Use: docker-up   → to start Docker"
echo "         docker-down → to stop Docker & remove everything"
