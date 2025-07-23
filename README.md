# 🐳 Dynamic Docker DNS with dnsmasq and .test Domains

This setup allows your host machine to access Docker containers using their name. It updates dynamically as containers start and stop—no need to manually update `/etc/hosts`.

---

## ✨ Features

- Access containers via `<container>` from host
- Auto-updates on container start/stop/remove
- No manual edits to `/etc/hosts`
- Starts with Docker automatically

---

## 🛠 Requirements

- Linux (Tested on Kali, Ubuntu, Arch)
- Docker installed
- Root privileges

---
## INSTALL 
```bash
sudo bash setup.sh"
```

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

