#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Updating system"

# Full sync + upgrade before installing anything
# Prevents version conflicts between existing and new packages
sudo pacman -Syyuu --noconfirm

ok "System up to date"
