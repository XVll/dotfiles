#!/bin/bash
set -eEo pipefail

export OMARCHY_PATH="$HOME/.local/share/omarchy"
export PATH="$OMARCHY_PATH/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"
export OMARCHY_INSTALL="$INSTALL_DIR"

# Helpers
section() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
run_logged() { section "$(basename "$1")"; source "$1"; }
chrootable_systemctl_enable() { sudo systemctl enable --now "$1"; }

# Preflight
(( EUID != 0 )) || { echo "Do not run as root"; exit 1; }

echo "Installing dotfiles..."

# Domain installers (packages + stow)
source "$INSTALL_DIR/system.sh"
source "$INSTALL_DIR/shell.sh"
source "$INSTALL_DIR/input.sh"
source "$INSTALL_DIR/wm.sh"
source "$INSTALL_DIR/bar.sh"
source "$INSTALL_DIR/notifications.sh"
source "$INSTALL_DIR/audio.sh"
source "$INSTALL_DIR/terminal.sh"
source "$INSTALL_DIR/launcher.sh"
source "$INSTALL_DIR/browser.sh"
source "$INSTALL_DIR/theme.sh"
source "$INSTALL_DIR/login.sh"
source "$INSTALL_DIR/apps.sh"
source "$INSTALL_DIR/dev.sh"
source "$INSTALL_DIR/docker.sh"

echo "Done."
