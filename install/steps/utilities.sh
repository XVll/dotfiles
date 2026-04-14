#!/usr/bin/env bash
# utilities.sh — Wayland utilities, network, and system helpers

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# polkit-gnome = GUI privilege escalation — sudo dialogs in GUI apps
# grim = Wayland screenshot — captures full screen or a region to a file
# slurp = region selector — draw a selection box, used with grim/satty
# satty = screenshot annotation — draw arrows, text, boxes after capture
# wl-clipboard = copy/paste for Wayland (replaces xclip/xsel)
# brightnessctl = screen brightness via keybinds — works with backlight drivers
# playerctl = media keys — play/pause/next/prev via keybinds, MPRIS protocol
# imagemagick = image processing — used by wallpaper tools, thumbnails, scripts
# inetutils = basic network tools — ping, hostname (some missing from Arch base)
# ufw = uncomplicated firewall — simple rules-based firewall
# gnome-keyring = credential daemon — browsers, gh CLI, SSH agent store secrets here
# gnome-themes-extra = GTK themes including Adwaita Dark — GTK apps look wrong without
# libsecret = secret storage API — what apps use to talk to gnome-keyring
# avahi = mDNS daemon — makes hostname.local reachable on your LAN
# nss-mdns = mDNS resolver — pairs with avahi to resolve .local hostnames
# webp-pixbuf-loader = WebP image support for GTK apps — without this WebP shows broken
# swaybg = simple Wayland wallpaper setter — useful before hyprpaper is configured
# bolt = Thunderbolt device manager — only if you use Thunderbolt/USB4 peripherals
# gvfs-mtp = MTP filesystem — browse Android phones as a drive
# gvfs-nfs = NFS filesystem — mount NFS network shares
# gvfs-smb = SMB filesystem — mount Windows/Samba shares
# kvantum-qt5 = Qt5 theme engine — for custom Qt app theming
# exfatprogs = ExFAT tools — read/write ExFAT USB drives
info "Utilities"
paru -S --needed --noconfirm \
  polkit-gnome \
  grim \
  slurp \
  satty \
  wl-clipboard \
  brightnessctl \
  playerctl \
  imagemagick \
  inetutils \
  ufw \
  gnome-keyring \
  gnome-themes-extra \
  libsecret \
  avahi \
  nss-mdns \
  webp-pixbuf-loader \
  swaybg \
  bolt \
  gvfs-mtp \
  gvfs-nfs \
  gvfs-smb \
  kvantum-qt5 \
  exfatprogs
ok "Utilities installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" wofi

# ── Configure ─────────────────────────────────────────────────────────────────

