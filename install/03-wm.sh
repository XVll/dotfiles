#!/bin/bash

# Window manager domain: Hyprland, hypridle, hyprlock, hyprsunset, uwsm

pkg-add hyprland hypridle hyprlock hyprsunset \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  hyprland-preview-share-picker hyprland-guiutils \
  polkit-gnome swaybg grim slurp hyprpicker satty \
  brightnessctl wl-clipboard gpu-screen-recorder swayosd \
  qt5-wayland

cd "$DOTFILES" && stow -d stow -t "$HOME" wm
