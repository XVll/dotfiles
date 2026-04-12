#!/usr/bin/env bash
# wayland.sh — Hyprland compositor, display manager, XDG portals, GPU drivers

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# hyprland = tiling Wayland compositor — the window manager
# uwsm = Universal Wayland Session Manager — sets up env variables properly,
#         replaces manual exec-once env hacks in hyprland.conf
# sddm = display manager — handles login screen and session launch
# xdg-desktop-portal-hyprland = screensharing + file picker via Hyprland protocols
# xdg-desktop-portal-gtk = fallback portal for GTK apps (file open/save dialogs)
# egl-wayland = EGL Wayland platform — lets OpenGL apps render natively (not via XWayland)
# gtk4-layer-shell = GTK4 wlr-layer-shell — needed by GTK4 surface apps (waybar, etc.)
# qt5-wayland + qt6-wayland = Qt native Wayland rendering instead of going through XWayland
# kvantum-qt5 = Qt5 theme engine — keeps Qt apps visually consistent with GTK
# gnome-keyring = secret storage — browser passwords, git tokens, etc.
# libsecret = library apps use to talk to gnome-keyring
# hyprland-guiutils = Hyprland GUI utilities (hyprpm, color tools, etc.)
info "Wayland session"
paru -S --needed --noconfirm \
  hyprland \
  uwsm \
  sddm \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  egl-wayland \
  gtk4-layer-shell \
  qt5-wayland \
  qt6-wayland \
  kvantum-qt5 \
  gnome-keyring \
  libsecret \
  hyprland-guiutils
ok "Wayland session installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" hypr uwsm xdg
