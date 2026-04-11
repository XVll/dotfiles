#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Enabling services"

# sddm = display/login manager (system service — starts on boot, shows login screen)
sudo systemctl enable sddm

# NetworkManager = wifi/ethernet (system service — manages all network connections)
sudo systemctl enable NetworkManager

# pipewire audio stack (user services — start automatically on login)
systemctl --user enable pipewire pipewire-pulse wireplumber

ok "Services enabled"
