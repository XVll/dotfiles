#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_root

info "Configuring pacman"

# Arch ARM (aarch64) — Parallels kernel lacks Landlock, pacman sandbox fails
# NOTE: Remove DisableSandbox on CachyOS (x86_64 kernel has full Landlock support)
if ! grep -q "DisableSandbox" /etc/pacman.conf; then
  sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
fi

# Enable parallel downloads and color output
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

timedatectl set-ntp true
timedatectl set-timezone Europe/Istanbul

ok "Pacman configured"
