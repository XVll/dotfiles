#!/bin/bash
set -eEo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Preflight
(( EUID != 0 )) || { echo "Do not run as root"; exit 1; }

echo "Installing dotfiles..."

# Bootstrap
sudo pacman -S --needed --noconfirm stow git base-devel paru
ln -snf "$SCRIPT_DIR" ~/.dotfiles

export DOTFILES="$HOME/.dotfiles"
export PATH="$DOTFILES/bin:$PATH"

# Domain installers (packages + stow + config)
source "$DOTFILES/install/01-shell.sh"
source "$DOTFILES/install/02-terminal.sh"
source "$DOTFILES/install/03-wm.sh"
source "$DOTFILES/install/04-input.sh"
source "$DOTFILES/install/05-bar.sh"
source "$DOTFILES/install/06-notifications.sh"
source "$DOTFILES/install/07-audio.sh"
source "$DOTFILES/install/08-launcher.sh"
source "$DOTFILES/install/09-browser.sh"
source "$DOTFILES/install/10-system.sh"
source "$DOTFILES/install/11-docker.sh"
source "$DOTFILES/install/12-theme.sh"
source "$DOTFILES/install/13-login.sh"
source "$DOTFILES/install/14-apps.sh"
source "$DOTFILES/install/15-dev.sh"

echo "Done."
