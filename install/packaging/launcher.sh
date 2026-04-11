#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "App launcher"

# walker = modern Wayland launcher with fuzzy search, available as pre-built binary
paru -S --needed --noconfirm walker-bin

ok "App launcher installed"
