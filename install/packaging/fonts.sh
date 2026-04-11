#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Fonts"

# ttf-jetbrains-mono-nerd = primary coding font — ligatures + Nerd Font icons for waybar/starship
# noto-fonts = broad unicode coverage — fallback for anything JetBrainsMono doesn't cover
# noto-fonts-emoji = emoji support
paru -S --needed --noconfirm \
  ttf-jetbrains-mono-nerd \
  noto-fonts \
  noto-fonts-emoji

ok "Fonts installed"
