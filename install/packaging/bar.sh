#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Status bar"

# waybar = most popular Hyprland-compatible status bar, highly configurable
paru -S --needed --noconfirm waybar

ok "Status bar installed"
