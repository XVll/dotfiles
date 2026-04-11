#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Monitoring"

# btop = beautiful resource monitor (CPU/RAM/disk/network) — replaces htop
# fastfetch = system info display shown on terminal login — replaces neofetch
paru -S --needed --noconfirm \
  btop \
  fastfetch

ok "Monitoring installed"
