#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

abort() {
  echo " ✗  Requires: $1"
  echo "    Stopping. Fix this before running install.sh"
  exit 1
}

# Must be running as regular user (not root)
(( EUID != 0 )) || abort "run as your user, not root"

# Must be on CachyOS
# (On Arch ARM dev VM this file won't exist — that's expected)
if [[ ! -f /etc/cachyos-release ]] && [[ ! -f /etc/arch-release ]]; then
  abort "Arch-based distro"
fi

# Must have Limine bootloader (CachyOS default)
command -v limine &>/dev/null || abort "Limine bootloader (is this CachyOS?)"

# Must have btrfs root filesystem (CachyOS default)
[[ "$(findmnt -n -o FSTYPE /)" == "btrfs" ]] || abort "btrfs root filesystem (is this CachyOS?)"

ok "Guards passed"
