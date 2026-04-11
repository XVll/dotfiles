#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Installing base build tools"

# Minimum needed to build AUR packages
sudo pacman -S --needed --noconfirm \
  base-devel \
  git

ok "Base build tools installed"
