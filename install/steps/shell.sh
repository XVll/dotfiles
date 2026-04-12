#!/usr/bin/env bash
# shell.sh — Zsh, prompt, and CLI utilities

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# zsh = better completion, scripting, and plugin ecosystem than bash
# starship = fast cross-shell prompt — git status, language versions, exit codes
# eza = modern ls — icons, colors, tree view, git-aware
# bat = cat with syntax highlighting, line numbers, and git diff integration
# zoxide = smart cd — learns your dirs, jump with `z partial-name`
# fzf = fuzzy finder — powers Ctrl+R history search, file picker, and more
# zsh-autosuggestions = grey ghost text from history as you type
# zsh-syntax-highlighting = command coloring before you hit Enter
# wget = HTTP downloader — curl alternative, needed by many scripts
# bash-completion = tab completion scripts — many CLI tools install completions here
# less = standard terminal pager — man pages and most tools pipe through this
# man-db = man page database and viewer — documentation for system commands
# unzip = ZIP extraction — surprisingly many installers need this
# xdg-terminal-exec = standard terminal opener — file managers use this to launch a terminal
# tldr = simplified man pages with real-world examples — faster than man for common tasks
# plocate = fast file search via pre-built index — `locate` command
# whois = domain/IP lookup — useful for quick network investigation
# dust = disk usage tree — visual `du`, shows what's eating your disk space
# expac = pacman query tool — inspect package info, used in maintenance scripts
# gum = pretty interactive prompts — used by some install/config scripts
info "Shell + tools"
paru -S --needed --noconfirm \
  zsh \
  starship \
  eza \
  bat \
  zoxide \
  fzf \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  wget \
  bash-completion \
  less \
  man-db \
  unzip \
  xdg-terminal-exec \
  tldr \
  plocate \
  whois \
  dust \
  expac \
  gum
ok "Shell + tools installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" zsh starship

# ── Configure ─────────────────────────────────────────────────────────────────

# Set zsh as the default login shell — usermod works non-interactively
info "Setting default shell to zsh"
sudo usermod -s /bin/zsh "$USER"
ok "Default shell set to zsh (re-login to take effect)"

# Build plocate's file index — the nightly timer hasn't run on a fresh install
info "Building locate database"
sudo updatedb
ok "Locate database built"
