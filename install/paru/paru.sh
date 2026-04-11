#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Installing paru"

# NOTE: On CachyOS, paru is available in the CachyOS repo — skip the AUR build:
#   sudo pacman -S paru
# On Arch ARM, build from AUR (no pre-built binary for aarch64):
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ~

ok "paru installed"
