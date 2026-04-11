#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Hyprland ecosystem"

# hypridle = inactivity daemon — watches idle time and triggers actions (e.g. lock)
# hyprlock = GPU-accelerated lock screen
# hyprpaper = wallpaper daemon — efficient, supports per-monitor images
# hyprpicker = color picker — click anywhere on screen to get hex color
paru -S --needed --noconfirm \
  hypridle \
  hyprlock \
  hyprpaper \
  hyprpicker

ok "Hyprland ecosystem installed"
