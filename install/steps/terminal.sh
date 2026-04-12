#!/usr/bin/env bash
# terminal.sh — Ghostty GPU-accelerated terminal

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# ghostty = GPU-accelerated terminal emulator with native Wayland support,
#           fast rendering, and good font ligature support — in CachyOS repo
info "Terminal"
paru -S --needed --noconfirm ghostty
ok "Terminal installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" ghostty
