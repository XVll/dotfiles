#!/bin/bash

# Bar domain: waybar

pkg-add waybar

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" bar
