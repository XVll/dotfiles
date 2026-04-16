#!/bin/bash

# Browser domain: chromium, brave

pkg-add chromium

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" browser
