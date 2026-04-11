#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Terminal"

# ghostty = GPU-accelerated terminal, available in CachyOS repo
paru -S --needed --noconfirm ghostty

ok "Terminal installed"
