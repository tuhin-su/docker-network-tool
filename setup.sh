#!/bin/bash
sudo cp -p NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
sudo cp -p upstream.conf /etc/NetworkManager/dnsmasq.d/upstream.conf
sudo cp -p docker-dnsmasq-sync.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-dnsmasq-sync.sh
sudo cp -p docker-dnsmasq-sync.service  /etc/systemd/system/docker-dnsmasq-sync.service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable docker-dnsmasq-sync.service
sudo systemctl start docker-dnsmasq-sync.service
sudo systemctl restart NetworkManager
