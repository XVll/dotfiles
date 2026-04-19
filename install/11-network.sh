#!/bin/bash

# Network domain: DNS, firewall, bluetooth, tailscale

pkg-add networkmanager ufw ufw-docker bluetui tailscale

sudo systemctl enable --now NetworkManager

# DNS via systemd-resolved (caching, per-interface, Tailscale MagicDNS friendly)
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl enable --now systemd-resolved

# TCP MTU probing: fall back to smaller segments when ICMP Frag-Needed is
# blocked (common with VPNs, hotel wifi). Prevents "SSH login works, ls hangs".
grep -q "tcp_mtu_probing" /etc/sysctl.d/99-sysctl.conf 2>/dev/null || \
  echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null

# Bluetooth
sudo systemctl enable --now bluetooth.service

# Firewall (+ LocalSend ports, Docker DNS)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 1714:1764/udp comment 'KDE Connect'
sudo ufw allow 1714:1764/tcp comment 'KDE Connect'
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw --force enable
sudo systemctl enable ufw
sudo ufw-docker install
sudo ufw reload

# Tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up --accept-routes
webapp-install "Tailscale" "https://login.tailscale.com/admin/machines" \
  "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/tailscale-light.png"
