#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Terminal multiplexer"

# tmux = split terminal into panes/windows, keep sessions alive after disconnect
paru -S --needed --noconfirm tmux

ok "Multiplexer installed"
