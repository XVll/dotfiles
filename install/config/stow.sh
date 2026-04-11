#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Linking dotfiles"
cd "$DOTFILES_DIR"
bash stow.sh
ok "Dotfiles linked"
