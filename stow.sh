#!/usr/bin/env bash
# stow.sh — symlink all packages into $HOME
# Usage: ./stow.sh [package]   (no args = stow everything)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"

PACKAGES=(
  # Scripts (theme-set, theme-list, theme-current → ~/.local/bin/)
  bin

  # Shell
  zsh
  starship

  # Editor
  nvim

  # Window manager & Wayland
  hypr
  hyprlock
  hypridle
  hyprpaper

  # Status bar
  waybar

  # Launcher
  walker

  # Terminal
  ghostty

  # Notifications
  mako

  # Git
  git
  lazygit

  # Multiplexer
  tmux

  # System info
  btop
  fastfetch

  # Utilities
  imv
  wiremix
  wofi

  # Session / system
  uwsm
  xdg
  fontconfig
  swayosd

  # App launcher overrides (hide/fix .desktop entries)
  applications
)

stow_package() {
  local pkg="$1"
  if [ -d "$DOTFILES_DIR/$pkg" ]; then
    echo "  stowing $pkg..."
    stow --dir="$DOTFILES_DIR" --target="$TARGET_DIR" "$pkg"
  else
    echo "  skipping $pkg (not found)"
  fi
}

if [ -n "$1" ]; then
  stow_package "$1"
else
  echo "Stowing all packages..."
  for pkg in "${PACKAGES[@]}"; do
    stow_package "$pkg"
  done
  echo "Done."
fi
