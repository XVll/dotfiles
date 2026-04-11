#!/usr/bin/env bash
# install.sh — run as your user (with sudo) after OS installation
#
# On a completely fresh Arch install (no user yet):
#   sudo bash install/preflight/user.sh   ← one-time, then re-login as fx
#
# On CachyOS (the real target), the installer already created your user.
# Just run:
#   bash install.sh

set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/install/helpers.sh"
source "$DOTFILES_DIR/install/preflight/all.sh"
source "$DOTFILES_DIR/install/packaging/all.sh"
source "$DOTFILES_DIR/install/config/all.sh"
source "$DOTFILES_DIR/install/login/all.sh"
source "$DOTFILES_DIR/install/post-install/all.sh"
