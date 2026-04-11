#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_root

info "Base packages"

# Minimum needed to bootstrap paru and clone the dotfiles repo
pacman -S --needed --noconfirm \
  base-devel \
  git

ok "Base packages done"
