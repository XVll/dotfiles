#!/usr/bin/env bash
# hypr-ecosystem.sh — Hyprland companion utilities

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# hypridle = inactivity daemon — watches idle time, triggers actions (dim, lock, suspend)
# hyprlock = GPU-accelerated Wayland lock screen — configured in hyprlock.conf
# hyprpaper = wallpaper daemon — efficient, supports per-monitor images
# hyprpicker = color picker — click anywhere on screen to get the hex value
# hyprsunset = blue light filter — reduces screen color temperature in the evening
# swayosd = on-screen display for volume/brightness — popup when you press media keys
info "Hyprland ecosystem"
paru -S --needed --noconfirm \
  swayosd
# paru -S --needed --noconfirm \
#   hypridle \
#   hyprlock \
#   hyprpaper \
#   hyprpicker \
#   hyprsunset
ok "Hyprland ecosystem installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" swayosd
# bash "$DOTFILES_DIR/stow.sh" hypridle hyprlock hyprpaper
