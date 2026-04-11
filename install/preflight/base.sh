#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_root

info "Installing base build tools"

# Minimum to bootstrap paru and build AUR packages
pacman -S --needed --noconfirm \
  base-devel \
  git

ok "Base build tools installed"
