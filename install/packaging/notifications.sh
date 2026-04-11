#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Notifications"

# mako = lightweight Wayland notification daemon (replaces dunst on Wayland)
paru -S --needed --noconfirm mako

ok "Notifications installed"
