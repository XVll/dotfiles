#!/usr/bin/env bash
# git.sh — Git tools and identity

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# lazygit = TUI git client — stage hunks, resolve conflicts, browse log visually
# git-delta = diff pager — syntax-highlighted, side-by-side diffs (set as pager in .gitconfig)
# github-cli = gh CLI — auth, PR review, issue management without leaving the terminal
# neovim-remote = nvr — opens files in existing Neovim session (used by lazygit editPreset)
info "Git tools"
paru -S --needed --noconfirm \
  lazygit \
  git-delta \
  git-lfs \
  github-cli \
  neovim-remote
ok "Git tools installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" git lazygit

# ── Configure ─────────────────────────────────────────────────────────────────

# Git identity — reads GIT_NAME/GIT_EMAIL env vars or prompts interactively
info "Setting git identity"
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"
if [ -z "$GIT_NAME" ];  then read -rp "  Git name:  " GIT_NAME;  fi
if [ -z "$GIT_EMAIL" ]; then read -rp "  Git email: " GIT_EMAIL; fi
[ -n "$GIT_NAME" ]  && git config --global user.name  "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
ok "Git identity set"
