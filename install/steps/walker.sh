#!/usr/bin/env bash
# walker.sh — Application launcher

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# walker-bin = Wayland application launcher — fuzzy search across apps, commands,
#              files, and custom modules; pre-built binary from AUR
info "App launcher"
paru -S --needed --noconfirm walker-bin
ok "App launcher installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" walker
