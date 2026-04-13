#!/usr/bin/env bash
# stow.sh — symlink dotfile packages into $HOME
# Usage: ./stow.sh [pkg...]   (no args = stow everything)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"

PACKAGES=(
  bin
  zsh starship
  nvim mise
  hypr hyprlock hypridle hyprpaper uwsm xdg
  waybar
  walker
  ghostty
  mako
  git lazygit
  tmux
  btop fastfetch
  imv wiremix wofi
  fontconfig swayosd
  applications
)

stow_package() {
  local pkg="$1"
  if [ -d "$DOTFILES_DIR/$pkg" ]; then
    echo "  stowing $pkg..."
    stow --dir="$DOTFILES_DIR" --target="$TARGET_DIR" -R "$pkg"
  else
    echo "  skipping $pkg (not found)"
  fi
}

if [ "$#" -gt 0 ]; then
  for pkg in "$@"; do
    stow_package "$pkg"
  done
else
  echo "Stowing all packages..."
  for pkg in "${PACKAGES[@]}"; do
    stow_package "$pkg"
  done
  echo "Done."
fi
