#!/usr/bin/env bash
# login/all.sh — Display manager, boot, and session configuration
#
# Runs after config phase. Every script from omarchy's install/login/all.sh
# is represented here in order — kept ones are inlined, skipped ones are
# commented out with a reason.
#
# Also includes our own additions (services) that omarchy handles elsewhere.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

# ─────────────────────────────────────────────────────────────────────────────
# PLYMOUTH — omarchy: login/plymouth.sh
# SKIPPED: Installs and activates omarchy's custom boot splash theme.
# We don't have a custom Plymouth theme yet. Plain boot is fine for now.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# DEFAULT KEYRING — Create an auto-unlocking GNOME Keyring
# omarchy: login/default-keyring.sh
#
# SDDM autologin skips password entry, which means GNOME Keyring never gets
# unlocked (it normally unlocks using your login password as the encryption
# key). Any app that uses the keyring — Chromium, SSH agent, libsecret
# clients — will pop up an unlock dialog on every use.
#
# The fix is to create an unencrypted keyring named "Default keyring" with
# lock-on-idle and lock-after disabled. GNOME Keyring will use this as the
# default and never prompt for a password.
# ─────────────────────────────────────────────────────────────────────────────
info "Creating auto-unlocking GNOME Keyring"
KEYRING_DIR="$HOME/.local/share/keyrings"
KEYRING_FILE="$KEYRING_DIR/Default_keyring.keyring"
DEFAULT_FILE="$KEYRING_DIR/default"

mkdir -p "$KEYRING_DIR"

cat >"$KEYRING_FILE" <<EOF
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF

cat >"$DEFAULT_FILE" <<'EOF'
Default_keyring
EOF

chmod 700 "$KEYRING_DIR"
chmod 600 "$KEYRING_FILE"
chmod 644 "$DEFAULT_FILE"
ok "Default keyring created"

# ─────────────────────────────────────────────────────────────────────────────
# SDDM — Configure display manager and autologin
# omarchy: login/sddm.sh
#
# Three things here:
# 1. Autologin: logs you straight into Hyprland via hyprland-uwsm without a
#    password prompt. The session name must match a file in
#    /usr/share/wayland-sessions/ — hyprland-uwsm.desktop is provided by uwsm.
# 2. PAM patch: removes pam_gnome_keyring from SDDM's PAM config. When SDDM
#    uses a password it would normally try to unlock/create an encrypted
#    keyring — which conflicts with the unencrypted Default_keyring above.
#    Stripping it out lets the keyring we created above work undisturbed.
# 3. Enable sddm.service so it starts on boot.
#
# SKIPPED from omarchy: theme (omarchy-specific SDDM theme via omarchy-refresh-sddm)
# We leave [Theme] Current= empty (uses the SDDM default).
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring SDDM"
sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null
[Autologin]
User=$USER
Session=hyprland-uwsm

[Theme]
Current=
EOF

# Remove gnome-keyring from SDDM PAM so it doesn't interfere with our
# unencrypted default keyring
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d'     /etc/pam.d/sddm
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm

sudo systemctl enable sddm.service
ok "SDDM configured with autologin (hyprland-uwsm)"

# ─────────────────────────────────────────────────────────────────────────────
# LIMINE + SNAPPER — omarchy: login/limine-snapper.sh
# SKIPPED: This is the largest login script — it does several things:
#
# 1. Installs limine-snapper-sync and limine-mkinitcpio-hook packages.
# 2. Writes mkinitcpio hook config (adds plymouth, btrfs-overlayfs, etc.).
# 3. Finds the Limine bootloader config wherever it lives on the EFI partition,
#    replaces it with omarchy's template (sets kernel cmdline, UKI, snapshots).
# 4. Sets up Snapper for BTRFS root and home subvolumes with omarchy's
#    preferred limits (5 snapshots max, space-aware, no timeline creates).
# 5. Re-enables mkinitcpio pacman hooks that were disabled during pre-install
#    to avoid redundant rebuilds, then runs limine-update.
#
# Why skipped: requires BTRFS + Limine which CachyOS provides, but the
# Snapper/bootloader config is highly specific to omarchy's partition layout
# and their limine.conf template (which we don't have). We'll revisit when
# we decide on our own bootloader and snapshot strategy.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# SERVICES — Enable core system and user services
# (our own addition — omarchy spreads this across multiple scripts)
#
# NetworkManager: handles WiFi and ethernet connections. Runs as a system
# service. Required before anything network-dependent starts.
#
# Pipewire stack: pipewire is the audio/video server replacing PulseAudio
# and JACK. pipewire-pulse is a PulseAudio-compatible interface for apps
# that link against libpulse. wireplumber is the session/policy manager
# that routes audio between sources and sinks.
# These are user services — systemd starts them automatically when you log in.
# ─────────────────────────────────────────────────────────────────────────────
info "Enabling system services"
sudo systemctl enable NetworkManager
ok "NetworkManager enabled"

info "Enabling user audio services"
systemctl --user enable pipewire pipewire-pulse wireplumber
ok "Pipewire stack enabled"
