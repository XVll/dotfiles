#!/bin/bash

# Browser domain: chromium

pkg-add chromium

cd "$DOTFILES" && stow -d stow -t "$HOME" browser
