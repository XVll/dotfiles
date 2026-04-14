#!/usr/bin/env bash
# theme.sh — Theming system (curated themes + wallpaper-generated via matugen)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# matugen = Material You color generator from wallpaper images
#           only needed for wallpaper-generated themes, curated themes work without it
info "Theme system"
paru -S --needed --noconfirm \
  matugen-bin
ok "matugen installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
info "Stowing theme configs"
"$DOTFILES_DIR/stow.sh" theme
ok "Theme configs stowed"

# ── Apply default theme ──────────────────────────────────────────────────────
info "Applying default theme (catppuccin-mocha)"
theme-set catppuccin-mocha
ok "Default theme applied"
