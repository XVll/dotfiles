#!/bin/bash

# Window manager domain: Hyprland + screenshot/recording/clipboard tooling.
# DMS (see 15-login.sh) owns bar, notifs, lock, idle, OSD, wallpaper, polkit,
# night mode — so no hypridle/hyprlock/hyprsunset/polkit-gnome/swaybg/swayosd.

pkg-add hyprland \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  hyprland-preview-share-picker \
  hyprpicker satty grim slurp \
  brightnessctl playerctl wl-clipboard \
  gpu-screen-recorder \
  qt5-wayland

cd "$DOTFILES" && stow -d stow -t "$HOME" wm
