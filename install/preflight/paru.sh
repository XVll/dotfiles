#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Installing paru"

# paru is in the CachyOS repo — no AUR build needed
sudo pacman -S --needed --noconfirm paru

ok "paru installed"
