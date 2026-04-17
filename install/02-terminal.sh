#!/bin/bash

# Terminal domain: kitty, ghostty, tmux

pkg-add kitty ghostty tmux xdg-terminal-exec

cd "$DOTFILES" && stow -d stow -t "$HOME" terminal
