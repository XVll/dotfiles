#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Git tools"

# lazygit = terminal UI for git — stage hunks, resolve conflicts, browse log visually
# git-delta = syntax-highlighted, side-by-side diffs (configured in .gitconfig as pager)
paru -S --needed --noconfirm \
  lazygit \
  git-delta

ok "Git tools installed"
