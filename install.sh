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
# Uncomment one at a time as we review each script.
source "$DOTFILES/install/01-shell.sh"
source "$DOTFILES/install/02-terminal.sh"
source "$DOTFILES/install/03-wm.sh"
source "$DOTFILES/install/04-input.sh"
source "$DOTFILES/install/07-audio.sh"
source "$DOTFILES/install/09-browser.sh"
source "$DOTFILES/install/10-system.sh"
source "$DOTFILES/install/11-network.sh"
source "$DOTFILES/install/13-docker.sh"
source "$DOTFILES/install/15-login.sh"
source "$DOTFILES/install/16-apps.sh"
source "$DOTFILES/install/17-dev.sh"

echo "Done."
