#!/usr/bin/env bash
# fonts.sh — Fonts and font configuration

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# ttf-jetbrains-mono-nerd = primary coding font — ligatures + Nerd Font icons
#                           used by waybar, starship, ghostty, nvim
# ttf-meslo-nerd = Meslo LG Nerd Font — popular terminal font, good alternative
# noto-fonts = broad Unicode coverage — fallback for scripts JetBrains/Liberation miss
# noto-fonts-emoji = emoji support — without this emoji render as boxes
# noto-fonts-cjk = Chinese/Japanese/Korean — without this CJK text renders as boxes
# ttf-liberation = sans-serif + serif system fonts — GTK app UI text, web compat
#                  (Liberation Sans/Serif used for -apple-system, BlinkMacSystemFont aliases)
# fontconfig = font configuration package — rendering, hinting, substitution rules
# ttf-ia-writer = iA Writer typeface (Mono/Duo/Quattro) — clean reading/prose font
# woff2-font-awesome = Font Awesome web font — used by Waybar icon modules
info "Fonts"
paru -S --needed --noconfirm \
  ttf-jetbrains-mono-nerd \
  ttf-meslo-nerd \
  noto-fonts \
  noto-fonts-emoji \
  noto-fonts-cjk \
  ttf-liberation \
  fontconfig \
  ttf-ia-writer \
  woff2-font-awesome
ok "Fonts installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" fontconfig

# ── Configure ─────────────────────────────────────────────────────────────────

# Rebuild font cache — makes newly installed fonts immediately available
info "Rebuilding font cache"
fc-cache -fv >/dev/null 2>&1
ok "Font cache rebuilt"
