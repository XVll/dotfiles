#!/bin/bash

# Window manager domain: Hyprland, hypridle, hyprlock, hyprsunset, uwsm

pkg-add hyprland hypridle hyprlock hyprsunset uwsm \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  hyprland-preview-share-picker hyprland-guiutils \
  polkit-gnome swaybg grim slurp hyprpicker satty \
  brightnessctl wl-clipboard gpu-screen-recorder

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" wm
