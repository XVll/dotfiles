#!/bin/bash

# Shell domain: fish, starship, git

pkg-add fish starship git \
  bat eza fd fzf less man-db ripgrep tealdeer unzip \
  zoxide jq github-cli gum

cd "$DOTFILES" && stow -d stow -t "$HOME" shell

# Set fish as default shell
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */fish ]]; then
  sudo chsh -s "$(command -v fish)" "$USER"
fi
