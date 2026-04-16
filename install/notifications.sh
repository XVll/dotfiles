#!/bin/bash

# Notifications domain: mako

pkg-add mako

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" notifications

# Symlink mako config to themed output (theme system generates this)
ln -sf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config
