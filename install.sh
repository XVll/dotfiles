#!/usr/bin/env bash
# install.sh — bootstrap a fresh Arch/CachyOS system
#
# VM:     Arch Linux ARM (aarch64) on Parallels
# Target: CachyOS (x86_64) on bare metal
#
# Run in order on a fresh Arch install:
#
#   Step 1 — as root:
#     bash install.sh preflight
#
#   Step 2 — as fx (re-login after step 1):
#     bash install.sh packages
#     bash install.sh config
#     bash install.sh login
#     bash install.sh post
#
#   Or run everything non-interactive at once (as fx, after root preflight):
#     bash install.sh all

set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  preflight) source "$DOTFILES_DIR/install/preflight/all.sh" ;;
  packages)  source "$DOTFILES_DIR/install/packaging/all.sh" ;;
  config)    source "$DOTFILES_DIR/install/config/all.sh" ;;
  login)     source "$DOTFILES_DIR/install/login/all.sh" ;;
  post)      source "$DOTFILES_DIR/install/post-install/all.sh" ;;
  all)
    source "$DOTFILES_DIR/install/packaging/all.sh"
    source "$DOTFILES_DIR/install/config/all.sh"
    source "$DOTFILES_DIR/install/login/all.sh"
    source "$DOTFILES_DIR/install/post-install/all.sh"
    ;;
  *)
    echo "Usage: $0 <step>"
    echo ""
    echo "  preflight  — as root: pacman config, user creation, base-devel, paru"
    echo "  packages   — as fx:   install all packages"
    echo "  config     — as fx:   stow dotfiles, git config, set shell"
    echo "  login      — as fx:   sddm autologin, enable services"
    echo "  post       — as fx:   cleanup orphans, reboot prompt"
    echo "  all        — as fx:   packages + config + login + post"
    ;;
esac
