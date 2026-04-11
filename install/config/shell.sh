#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Setting default shell"

# chsh requires password interactively — use usermod via sudo instead
sudo usermod -s /bin/zsh "$USER"

ok "Default shell set to zsh (re-login to take effect)"
