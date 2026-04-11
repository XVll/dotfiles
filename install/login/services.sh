#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Enabling services"

# NetworkManager = wifi/ethernet (system service)
sudo systemctl enable NetworkManager

# pipewire audio stack (user services — start automatically on login)
systemctl --user enable pipewire pipewire-pulse wireplumber

ok "Services enabled"
