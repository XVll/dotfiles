#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

abort() {
  echo " ✗  Requires: $1"
  echo "    Stopping. Fix this before running install.sh"
  exit 1
}

# Must run as regular user, not root
(( EUID != 0 )) || abort "run as your user, not root"

# Must be on CachyOS
[[ -f /etc/cachyos-release ]] || abort "CachyOS"

# Must have Limine bootloader (CachyOS default)
command -v limine &>/dev/null || abort "Limine bootloader"

# Must have btrfs root filesystem (CachyOS default)
[[ "$(findmnt -n -o FSTYPE /)" == "btrfs" ]] || abort "btrfs root filesystem"

ok "Guards passed"
