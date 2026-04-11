#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Configuring pacman"
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
grep -q "^ILoveCandy" /etc/pacman.conf || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
grep -q "^VerbosePkgLists" /etc/pacman.conf || sudo sed -i '/^ILoveCandy/a VerbosePkgLists' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
ok "Pacman configured"

info "Syncing and upgrading system"
sudo pacman -Syyuu --noconfirm
ok "System up to date"

info "Installing base build tools"
sudo pacman -S --needed --noconfirm base-devel git
ok "base-devel installed"

info "Installing paru"
sudo pacman -S --needed --noconfirm paru
ok "paru installed"
