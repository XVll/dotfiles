#!/bin/bash

# Terminal domain: ghostty, alacritty, kitty, tmux

pkg-add ghostty alacritty kitty tmux xdg-terminal-exec

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" terminal
