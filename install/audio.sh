#!/bin/bash

# Audio domain: pipewire, wireplumber, swayosd

pkg-add pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
  swayosd wiremix alsa-utils pamixer playerctl bluetui

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" audio
