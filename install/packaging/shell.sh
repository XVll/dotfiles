#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Shell + tools"

# zsh = better completion and scripting than bash
# starship = fast cross-shell prompt with git/language context
# eza = modern ls with icons and colors
# bat = cat with syntax highlighting and line numbers
# zoxide = smart cd — learns your most-visited dirs, jump with z
# fzf = fuzzy finder — powers Ctrl+R history search and more
# zsh-autosuggestions = grey ghost text from history as you type
# zsh-syntax-highlighting = command coloring before you hit enter
paru -S --needed --noconfirm \
  zsh \
  starship \
  eza \
  bat \
  zoxide \
  fzf \
  zsh-autosuggestions \
  zsh-syntax-highlighting

ok "Shell + tools installed"
