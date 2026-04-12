#!/usr/bin/env bash
# tmux.sh — Terminal multiplexer

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# tmux = terminal multiplexer — split panes/windows, keep sessions alive after
#        disconnect, great for remote work and long-running processes
info "Terminal multiplexer"
paru -S --needed --noconfirm tmux
ok "Terminal multiplexer installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" tmux
