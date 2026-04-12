#!/usr/bin/env bash
# install.sh — CachyOS dotfiles installer
#
# Usage: bash install.sh
#
# Uncomment one section at a time, run install.sh, test it, then move on.
# Each step script handles its own: Install → Stow → Configure.

set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/install/pre-install.sh"

# ── Steps — uncomment one at a time ──────────────────────────────────────────
# source "$DOTFILES_DIR/install/steps/system.sh"       # sysctl, systemd, security config
# source "$DOTFILES_DIR/install/steps/fonts.sh"        # fonts before anything renders
# source "$DOTFILES_DIR/install/steps/wayland.sh"      # Hyprland + SDDM + GPU drivers
# source "$DOTFILES_DIR/install/steps/audio.sh"        # PipeWire — core desktop sound
# source "$DOTFILES_DIR/install/steps/terminal.sh"     # Ghostty
# source "$DOTFILES_DIR/install/steps/shell.sh"        # zsh, starship, CLI tools
# source "$DOTFILES_DIR/install/steps/utilities.sh"    # polkit, grim, iwd, firewall...
# source "$DOTFILES_DIR/install/steps/waybar.sh"       # status bar
# source "$DOTFILES_DIR/install/steps/walker.sh"       # app launcher
# source "$DOTFILES_DIR/install/steps/hypr-ecosystem.sh" # idle, lock, wallpaper, OSD
# source "$DOTFILES_DIR/install/steps/notifications.sh"  # mako
# source "$DOTFILES_DIR/install/steps/editor.sh"       # neovim + language tools
# source "$DOTFILES_DIR/install/steps/git.sh"          # lazygit, delta, gh CLI
# source "$DOTFILES_DIR/install/steps/tmux.sh"         # terminal multiplexer
# source "$DOTFILES_DIR/install/steps/monitoring.sh"   # btop, fastfetch
# source "$DOTFILES_DIR/install/steps/docker.sh"       # containers
# source "$DOTFILES_DIR/install/steps/printing.sh"     # CUPS
# source "$DOTFILES_DIR/install/steps/applications.sh" # GUI apps
# source "$DOTFILES_DIR/install/steps/tui-entries.sh"  # desktop entries for TUI apps (install last)
# source "$DOTFILES_DIR/install/steps/npx.sh"          # claude, opencode (needs editor.sh)

# source "$DOTFILES_DIR/install/post-install.sh"
