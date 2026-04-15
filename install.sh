#!/bin/bash
set -eEo pipefail

export OMARCHY_PATH="$HOME/.local/share/omarchy"
export OMARCHY_INSTALL="$OMARCHY_PATH/install"
export PATH="$OMARCHY_PATH/bin:$PATH"

# Helpers
section() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
run_logged() { section "$(basename "$1")"; source "$1"; }

# Compat shims (removed as downstream scripts are cleaned)
chrootable_systemctl_enable() { sudo systemctl enable --now "$1"; }
start_install_log() { :; }
stop_install_log() { :; }
clear_logo() { :; }

# Preflight
(( EUID != 0 )) || { echo "Do not run as root"; exit 1; }
command -v limine &>/dev/null || { echo "Limine bootloader required"; exit 1; }
[[ $(findmnt -n -o FSTYPE /) = "btrfs" ]] || { echo "Btrfs root filesystem required"; exit 1; }

# Install
source "$OMARCHY_INSTALL/packaging/all.sh"
source "$OMARCHY_INSTALL/config/all.sh"
source "$OMARCHY_INSTALL/login/all.sh"
source "$OMARCHY_INSTALL/post-install/all.sh"
