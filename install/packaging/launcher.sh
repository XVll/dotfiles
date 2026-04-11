#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "App launcher"

# walker-bin = modern Wayland launcher — pre-built binary, x86_64 only
# NOTE: On CachyOS (x86_64) use walker-bin
# NOTE: On Arch ARM (aarch64) walker-bin is unavailable — wofi is the fallback
paru -S --needed --noconfirm walker-bin

# wofi = simple GTK-based Wayland launcher — ARM fallback
paru -S --needed --noconfirm wofi

ok "App launcher installed"
