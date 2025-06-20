# 🐳 Dynamic Docker DNS with dnsmasq and .test Domains

This setup allows your host machine to access Docker containers using their names with a `.test` domain (e.g. `php.test`). It updates dynamically as containers start and stop—no need to manually update `/etc/hosts`.

---

## ✨ Features

- Access containers via `<container>.test` from host
- Auto-updates on container start/stop/remove
- No manual edits to `/etc/hosts`
- Starts with Docker automatically

---

## 🛠 Requirements

- Linux (Tested on Kali, Ubuntu, Arch)
- Docker installed
- NetworkManager with `dnsmasq` support
- Root privileges

---

## ⚙️ Step 1: Configure NetworkManager

Edit:

```ini
# /etc/NetworkManager/NetworkManager.conf
[main]
dns=dnsmasq
plugins=ifupdown,keyfile
```

Create dnsmasq config folder if missing:

```bash
sudo mkdir -p /etc/NetworkManager/dnsmasq.d/
```

Add fallback DNS:

```ini
# /etc/NetworkManager/dnsmasq.d/upstream.conf
server=1.1.1.1
server=1.0.0.1
```

Restart NetworkManager:

```bash
sudo systemctl restart NetworkManager
```

---

## 📜 Step 2: Add Docker-DNS Sync Script

Create the sync script:

```bash
sudo nano /usr/local/bin/docker-dnsmasq-sync.sh
```

Paste:

```bash
#!/bin/bash

DNSMASQ_CONF="/etc/NetworkManager/dnsmasq.d/docker-dynamic.conf"
DOMAIN_SUFFIX=".test"

generate_entries() {
    echo "# Auto-generated by docker-dnsmasq-sync.sh"
    for cid in $(docker ps -q); do
        name=$(docker inspect -f '{{.Name}}' "$cid" | sed 's|/||')
        ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$cid")
        if [[ -n "$ip" ]]; then
            echo "address=/$name$DOMAIN_SUFFIX/$ip"
        fi
    done
}

update_dnsmasq() {
    generate_entries > "$DNSMASQ_CONF"
    systemctl restart NetworkManager
}

# Initial run
update_dnsmasq

# Watch Docker events
docker events --filter 'event=start' --filter 'event=stop' --filter 'event=die' | while read -r event; do
    update_dnsmasq
done
```

Make it executable:

```bash
sudo chmod +x /usr/local/bin/docker-dnsmasq-sync.sh
```

---

## 🔧 Step 3: Create systemd Service

```bash
sudo nano /etc/systemd/system/docker-dnsmasq-sync.service
```

Paste:

```ini
[Unit]
Description=Auto-sync Docker containers to dnsmasq
Requires=docker.service
After=docker.service network.target

[Service]
ExecStart=/usr/local/bin/docker-dnsmasq-sync.sh
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=docker.service
```

Enable and start:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable docker-dnsmasq-sync.service
sudo systemctl start docker-dnsmasq-sync.service
```

---

## 🧪 Test

```bash
docker run -d --name php nginx
ping php.test
docker stop php
```

---

## 🔍 Debugging

- Check DNS entries:
  ```bash
  cat /etc/NetworkManager/dnsmasq.d/docker-dynamic.conf
  ```
- Live logs:
  ```bash
  journalctl -u docker-dnsmasq-sync.service -f
  ```

---

## 🧹 Uninstall

```bash
sudo systemctl disable --now docker-dnsmasq-sync.service
sudo rm /etc/systemd/system/docker-dnsmasq-sync.service
sudo rm /usr/local/bin/docker-dnsmasq-sync.sh
sudo rm /etc/NetworkManager/dnsmasq.d/docker-dynamic.conf
sudo systemctl restart NetworkManager
```

---

## 💡 Notes

- Modify `.test` in the script to use `.docker`, `.dev`, etc.
- Ensure `/etc/resolv.conf` is managed by `NetworkManager`.

---

