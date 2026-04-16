#!/bin/bash

# Terminal domain: kitty, ghostty, tmux

pkg-add kitty ghostty tmux xdg-terminal-exec

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" terminal
