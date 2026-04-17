#!/bin/bash

# Input domain: fonts, fontconfig, kanata

pkg-add fontconfig kanata \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd

cd "$DOTFILES" && stow -d stow -t "$HOME" input

# Install kanata service (substitute current user into the template)
sed "s|__USER__|$USER|g" "$DOTFILES/system/systemd/kanata.service" \
  | sudo tee /etc/systemd/system/kanata.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now kanata.service
