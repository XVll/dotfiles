#!/bin/bash

# Audio domain: pipewire stack, CLI helpers

pkg-add pipewire pipewire-alsa pipewire-pulse wireplumber \
  alsa-utils

cd "$DOTFILES" && stow -d stow -t "$HOME" audio
