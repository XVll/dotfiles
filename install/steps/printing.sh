#!/usr/bin/env bash
# printing.sh — CUPS printing stack with network printer discovery

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# cups = UNIX print server — manages printers and print jobs
# cups-browsed = auto-discovers network printers via mDNS
# cups-filters = print filters and backends — processing pipeline for jobs
# cups-pdf = virtual PDF printer — "print to PDF" from any app
# system-config-printer = printer configuration GUI
info "Printing"
paru -S --needed --noconfirm \
  cups \
  cups-browsed \
  cups-filters \
  cups-pdf \
  system-config-printer
ok "Printing installed"

# ── Configure ─────────────────────────────────────────────────────────────────

info "Configuring printing"

# CUPS print server
sudo systemctl enable cups.service

# Avahi for mDNS printer discovery (Bonjour/AirPrint compatible)
# Disable systemd-resolved's mDNS first — Avahi owns it
sudo mkdir -p /etc/systemd/resolved.conf.d
printf '[Resolve]\nMulticastDNS=no\n' \
  | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf >/dev/null
sudo systemctl enable avahi-daemon.service

# Add mDNS resolution for .local hostnames
sudo sed -i \
  's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns/' \
  /etc/nsswitch.conf

# Auto-add network printers found via mDNS
if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf 2>/dev/null; then
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf >/dev/null
fi
sudo systemctl enable cups-browsed.service

ok "Printing configured"
