#!/usr/bin/env bash
# session.sh — Session manager and login screen
#
# uwsm manages the Wayland session (env propagation to systemd).
# SDDM shows the login screen on boot. Entering your password here also
# unlocks GNOME Keyring automatically via PAM — no extra config needed.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Installing session stack"
paru -S --needed --noconfirm \
  sddm \
  uwsm \
  gnome-keyring \
  libsecret
ok "Session stack installed"

info "Enabling SDDM"
sudo systemctl enable sddm.service
ok "SDDM enabled"
