#!/usr/bin/env bash
# notifications.sh — Wayland notification daemon

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# mako = lightweight Wayland notification daemon — replaces dunst on Wayland,
#        styled via config file, supports actions and grouping
info "Notifications"
paru -S --needed --noconfirm mako
ok "Notifications installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" mako
