#!/bin/bash

# Input domain: fcitx5, xcompose, fontconfig

pkg-add fcitx5 fcitx5-gtk fcitx5-qt fontconfig \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd ttf-ia-writer woff2-font-awesome

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" input

# Detect keyboard layout from vconsole and apply to Hyprland
conf="/etc/vconsole.conf"
hyprconf="$HOME/.config/hypr/input.conf"

if grep -q '^XKBLAYOUT=' "$conf"; then
  layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i "/^[[:space:]]*kb_options *=/i\  kb_layout = $layout" "$hyprconf"
fi

if grep -q '^XKBVARIANT=' "$conf"; then
  variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i "/^[[:space:]]*kb_options *=/i\  kb_variant = $variant" "$hyprconf"
fi

# XCompose defaults (CapsLock as compose key)
tee ~/.XCompose >/dev/null <<'EOF'
# Run omarchy-restart-xcompose to apply changes

# Identification
<Multi_key> <space> <n> : "TODO_YOUR_NAME"
<Multi_key> <space> <e> : "TODO_YOUR_EMAIL"
EOF
