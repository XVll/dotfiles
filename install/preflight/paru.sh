#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Installing paru (AUR helper)"

# NOTE: On CachyOS, paru is in the official repo — skip the build:
#   sudo pacman -S paru
# On Arch ARM (aarch64), build from AUR (no pre-built binary):
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ~

ok "paru installed"
