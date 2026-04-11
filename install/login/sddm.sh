#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Setting up SDDM"

# Configure autologin with hyprland-uwsm session (same as omarchy)
# uwsm provides proper Wayland env setup; session name must match /usr/share/wayland-sessions/
sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null
[Autologin]
User=$USER
Session=hyprland-uwsm

[Theme]
Current=
EOF

sudo systemctl enable sddm

ok "SDDM enabled with autologin (hyprland-uwsm)"
