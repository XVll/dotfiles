#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Configuring pacman"

# Enable color output
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

# Pacman progress bar (the pacman eating dots)
sudo sed -i 's/^#ILoveCandy/ILoveCandy/' /etc/pacman.conf
# Add ILoveCandy if it doesn't exist at all
grep -q "^ILoveCandy" /etc/pacman.conf || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

# Show old and new package versions on upgrades
grep -q "^VerbosePkgLists" /etc/pacman.conf || sudo sed -i '/^ILoveCandy/a VerbosePkgLists' /etc/pacman.conf

# Download up to 5 packages at once
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

info "Syncing and upgrading system"

# Full sync + upgrade before installing anything
# Prevents version conflicts between existing and new packages
sudo pacman -Syyuu --noconfirm

ok "Pacman configured and system up to date"
