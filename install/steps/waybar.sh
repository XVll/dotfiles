#!/usr/bin/env bash
# waybar.sh — Status bar for Hyprland

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# waybar = most popular Hyprland-compatible status bar — highly configurable via
#          JSON config and CSS, supports workspaces, clock, volume, network, etc.
info "Status bar"
paru -S --needed --noconfirm \
  waybar
ok "Status bar installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" waybar bin
