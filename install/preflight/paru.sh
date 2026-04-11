#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Installing paru"

sudo pacman -S --needed --noconfirm paru

ok "paru installed"
