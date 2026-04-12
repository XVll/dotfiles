#!/usr/bin/env bash
# monitoring.sh — System monitoring and info tools

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# btop = resource monitor — CPU/RAM/disk/network with a clean visual interface
# fastfetch = system info on login — shows OS, CPU, RAM, etc. (replaces neofetch)
# inxi = detailed hardware report — very useful when diagnosing hardware issues
# usage = terminal system usage overview — alternative top-level system view
info "Monitoring"
paru -S --needed --noconfirm \
  btop \
  fastfetch \
  inxi \
  usage
ok "Monitoring installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" btop fastfetch
