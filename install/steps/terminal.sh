#!/usr/bin/env bash
# terminal.sh — Ghostty GPU-accelerated terminal

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# ghostty = GPU-accelerated terminal emulator with native Wayland support,
#           fast rendering, and good font ligature support — in CachyOS repo
# neovim = vim-based modal editor — we use LazyVim as the config framework
# tree-sitter-cli = treesitter grammar CLI — build/update syntax grammars
#                   C compiler (gcc from base-devel) is also required
info "Terminal"
paru -S --needed --noconfirm \
  ghostty \
  neovim \
  tree-sitter-cli
ok "Terminal installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" ghostty nvim
