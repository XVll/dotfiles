#!/bin/bash

# Audio domain: pipewire, wireplumber

pkg-add pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
  wiremix alsa-utils pamixer playerctl

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" audio
