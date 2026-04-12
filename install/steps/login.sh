#!/usr/bin/env bash
# login.sh — Display manager, session launch, and credential storage
#
# Run after wayland.sh. Handles everything between power-on and your desktop:
# SDDM autologin, session selection, and GNOME Keyring auto-unlock.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── SDDM autologin ────────────────────────────────────────────────────────────
# Skips the login screen and goes straight into Hyprland on boot.
# Session name must match /usr/share/wayland-sessions/hyprland-uwsm.desktop
info "Configuring SDDM"
sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null
[Autologin]
User=$USER
Session=hyprland-uwsm

[Theme]
Current=
EOF

# Remove gnome-keyring from SDDM PAM — autologin never enters a password so
# PAM-based keyring unlock would fail, causing apps to nag for manual unlock.
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d'     /etc/pam.d/sddm 2>/dev/null || true
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm 2>/dev/null || true

sudo systemctl enable sddm.service
ok "SDDM configured (autologin → hyprland-uwsm)"

# ── GNOME Keyring auto-unlock ─────────────────────────────────────────────────
# With autologin there is no password entry, so the keyring never gets the
# PAM unlock signal. Apps that store secrets (Chromium, gh CLI, etc.) would
# repeatedly prompt you to unlock it manually.
#
# Creating an unencrypted keyring means it is always open. Trade-off: anyone
# with physical access to the machine can read stored secrets. Acceptable for
# a personal desktop with disk encryption at rest.
info "Creating auto-unlocking keyring"
KEYRING_DIR="$HOME/.local/share/keyrings"
mkdir -p "$KEYRING_DIR"
cat >"$KEYRING_DIR/Default_keyring.keyring" <<EOF
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF
printf 'Default_keyring\n' >"$KEYRING_DIR/default"
chmod 700 "$KEYRING_DIR"
chmod 600 "$KEYRING_DIR/Default_keyring.keyring"
chmod 644 "$KEYRING_DIR/default"
ok "Keyring configured (auto-unlock, unencrypted)"
