#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Editor"

# neovim = vim-based modal editor (we use LazyVim as config framework)
# ripgrep = grep replacement — required by telescope and fzf-lua plugins inside nvim
# fd = find replacement — required by telescope for file search
# nodejs + npm = JavaScript runtime — Mason (nvim LSP manager) uses these to install language servers
paru -S --needed --noconfirm \
  neovim \
  ripgrep \
  fd \
  nodejs \
  npm

ok "Editor installed"
