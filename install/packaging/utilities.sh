#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Utilities"

# polkit-gnome = GUI popup for privilege escalation (sudo dialogs in GUI apps)
# grim = Wayland screenshot tool (captures screen or region)
# slurp = region selector — used together with grim for area screenshots
# wl-clipboard = copy/paste on Wayland (replaces xclip/xsel)
# brightnessctl = control screen brightness via keybinds
# playerctl = control media playback (play/pause/next) via keybinds
# networkmanager = manages wifi and ethernet connections
# network-manager-applet = tray icon for NetworkManager (nm-applet)
# swaybg = simple wallpaper setter — used as placeholder until hyprpaper config is ready
paru -S --needed --noconfirm \
  polkit-gnome \
  grim \
  slurp \
  wl-clipboard \
  brightnessctl \
  playerctl \
  networkmanager \
  network-manager-applet \
  swaybg

ok "Utilities installed"
