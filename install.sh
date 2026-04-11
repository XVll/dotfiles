#!/usr/bin/env bash
# install.sh — run as your user (with sudo) on a fresh CachyOS install
#
# Usage: bash install.sh

set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/install/helpers.sh"
source "$DOTFILES_DIR/install/preflight/all.sh"
source "$DOTFILES_DIR/install/packaging/all.sh"
source "$DOTFILES_DIR/install/config/all.sh"
source "$DOTFILES_DIR/install/login/all.sh"
source "$DOTFILES_DIR/install/post-install/all.sh"
