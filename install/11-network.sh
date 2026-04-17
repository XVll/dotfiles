#!/bin/bash

# Network domain: iwd, bluetooth, firewall, DNS

pkg-add iwd wireless-regdb ufw ufw-docker bolt bluetui

# DNS resolver
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# SSH MTU probing fix
grep -q "tcp_mtu_probing" /etc/sysctl.d/99-sysctl.conf 2>/dev/null || \
  echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null

# Networking
# TODO: Rework for CachyOS — use NetworkManager with iwd backend
sudo systemctl enable iwd.service
sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null
sudo systemctl mask systemd-networkd-wait-online.service 2>/dev/null

# Wireless regulatory domain
if [[ -f "/etc/conf.d/wireless-regdom" ]]; then
  unset WIRELESS_REGDOM
  . /etc/conf.d/wireless-regdom
fi
if [[ ! -n ${WIRELESS_REGDOM} ]]; then
  if [[ -e "/etc/localtime" ]]; then
    TIMEZONE=$(readlink -f /etc/localtime)
    TIMEZONE=${TIMEZONE#/usr/share/zoneinfo/}
    COUNTRY="${TIMEZONE%%/*}"
    if [[ ! $COUNTRY =~ ^[A-Z]{2}$ ]] && [[ -f /usr/share/zoneinfo/zone.tab ]]; then
      COUNTRY=$(awk -v tz="$TIMEZONE" '$3 == tz {print $1; exit}' /usr/share/zoneinfo/zone.tab)
    fi
    if [[ $COUNTRY =~ ^[A-Z]{2}$ ]]; then
      echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee -a /etc/conf.d/wireless-regdom >/dev/null
      if command -v iw &>/dev/null; then
        sudo iw reg set ${COUNTRY}
      fi
    fi
  fi
fi

# Bluetooth
sudo systemctl enable --now bluetooth.service

# Firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp  # LocalSend
sudo ufw allow 53317/tcp  # LocalSend
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw --force enable
sudo systemctl enable ufw
sudo ufw-docker install
sudo ufw reload

# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --accept-routes
omarchy-webapp-install "Tailscale" "https://login.tailscale.com/admin/machines" https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/tailscale-light.png

# NordVPN
pkg-add nordvpn-bin
sudo systemctl enable --now nordvpnd
sudo usermod -aG nordvpn "$USER"
