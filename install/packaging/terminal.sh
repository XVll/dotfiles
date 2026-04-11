#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Terminal"

# ghostty-git = builds from source — required on aarch64 (no pre-built binary)
# NOTE: On CachyOS (x86_64) use ghostty-nightly-bin instead (faster, no compilation)
paru -S --needed --noconfirm ghostty-git

# kitty = ARM fallback terminal (works out of the box on aarch64)
# NOTE: On CachyOS, ghostty covers this — kitty is optional
paru -S --needed --noconfirm kitty

ok "Terminal installed"
