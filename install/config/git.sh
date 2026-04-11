#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Configuring git"

# Set from environment if provided, otherwise prompt
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"

if [ -z "$GIT_NAME" ]; then
  read -rp "  Git name: " GIT_NAME
fi

if [ -z "$GIT_EMAIL" ]; then
  read -rp "  Git email: " GIT_EMAIL
fi

[ -n "$GIT_NAME" ]  && git config --global user.name  "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"

ok "Git configured"
