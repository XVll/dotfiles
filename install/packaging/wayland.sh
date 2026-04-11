#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Wayland session"

# hyprland = tiling window manager (Wayland compositor)
# uwsm = Universal Wayland Session Manager — proper env setup, replaces exec-once hacks
# sddm = login/display manager
# xdg-desktop-portal-hyprland = screenshare + file picking through Hyprland
# xdg-desktop-portal-gtk = fallback portal for GTK apps
paru -S --needed --noconfirm \
  hyprland \
  uwsm \
  sddm \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk

ok "Wayland session installed"
