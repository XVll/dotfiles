#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Configuring pacman"

# Enable parallel downloads and color output (commented out by default in Arch)
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

# Sync package databases and upgrade everything before we start installing
# Prevents conflicts between old package versions and new ones we're about to install
sudo pacman -Syyuu --noconfirm

timedatectl set-ntp true
sudo timedatectl set-timezone Europe/Istanbul

ok "Pacman configured and system up to date"
