#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_root

info "System basics"

# Pacman sandbox workaround — Parallels ARM kernel lacks Landlock support
# NOTE: Not needed on CachyOS (x86_64 kernel has full Landlock support)
if ! grep -q "DisableSandbox" /etc/pacman.conf; then
  sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
fi

timedatectl set-ntp true
timedatectl set-timezone Europe/Istanbul

ok "System basics done"
