#!/bin/bash

# Browser domain: chromium

pkg-add chromium

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" browser
