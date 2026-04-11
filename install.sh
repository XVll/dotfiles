#!/usr/bin/env bash
# install.sh — bootstrap a fresh Arch/CachyOS system
#
# VM:     Arch Linux ARM (aarch64) on Parallels
# Target: CachyOS (x86_64) on bare metal
#
# Run steps in order:
#   bash install.sh system    — as root:  pacman config, timezone, user, base packages
#   bash install.sh paru      — as fx:    install paru AUR helper
#   bash install.sh packages  — as fx:    install all packages
#   bash install.sh config    — as fx:    stow dotfiles, enable services, set shell
#   bash install.sh all       — as fx:    packages + config

set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  system)   source "$DOTFILES_DIR/install/system/all.sh" ;;
  paru)     source "$DOTFILES_DIR/install/paru/all.sh" ;;
  packages) source "$DOTFILES_DIR/install/packaging/all.sh" ;;
  config)   source "$DOTFILES_DIR/install/config/all.sh" ;;
  all)
    source "$DOTFILES_DIR/install/packaging/all.sh"
    source "$DOTFILES_DIR/install/config/all.sh"
    ;;
  *)
    echo "Usage: $0 <step>"
    echo "  system    — run as root: pacman config, timezone, user, base packages"
    echo "  paru      — run as fx: install paru AUR helper"
    echo "  packages  — run as fx: install all packages"
    echo "  config    — run as fx: stow dotfiles, enable services, set shell"
    echo "  all       — packages + config"
    ;;
esac
