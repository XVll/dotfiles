#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Installing paru"

if pacman -Si paru &>/dev/null; then
  # Available in repo (CachyOS ships paru in their repo)
  sudo pacman -S --needed --noconfirm paru
else
  # Fall back to building from AUR
  cd /tmp
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si --noconfirm
  cd ~
fi

ok "paru installed"
