#!/bin/bash

# Input domain: fonts, fontconfig

pkg-add fontconfig kanata \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd ttf-ia-writer woff2-font-awesome

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" input

# Enable kanata key remapping service
sudo systemctl enable --now kanata.service
