#!/bin/bash

# Window manager domain: Hyprland + portals + screenshot annotation + clipboard.
# DMS (see 15-login.sh) owns bar, notifs, lock, idle, OSD, wallpaper, polkit,
# night mode, screenshots, color picking, brightness, media keys — so no
# hypridle/hyprlock/hyprsunset/polkit-gnome/swaybg/swayosd, no grim/slurp/
# hyprpicker, no brightnessctl/playerctl.

pkg-add hyprland \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  satty wl-clipboard

cd "$DOTFILES" && stow -d stow -t "$HOME" wm
