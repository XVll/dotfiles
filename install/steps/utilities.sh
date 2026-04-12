#!/usr/bin/env bash
# utilities.sh — Wayland utilities, network, and system helpers

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# polkit-gnome = GUI privilege escalation — sudo dialogs in GUI apps
# grim = Wayland screenshot — captures full screen or a region to a file
# slurp = region selector — draw a selection box, used with grim/satty
# satty = screenshot annotation — draw arrows, text, boxes after capture
# wl-clipboard = copy/paste for Wayland (replaces xclip/xsel)
# brightnessctl = screen brightness via keybinds — works with backlight drivers
# playerctl = media keys — play/pause/next/prev via keybinds, MPRIS protocol
# iwd = WiFi daemon — manages connections natively, no wpa_supplicant needed
# impala = TUI for iwd — connect to WiFi networks from the terminal/keybind
# jq = JSON processor — used constantly in scripts and by many CLI tools
# imagemagick = image processing — used by wallpaper tools, thumbnails, scripts
# inetutils = basic network tools — ping, hostname (some missing from Arch base)
# ufw = uncomplicated firewall — simple rules-based firewall
# gnome-keyring = credential daemon — browsers, gh CLI, SSH agent store secrets here
# gnome-themes-extra = GTK themes including Adwaita Dark — GTK apps look wrong without
# libsecret = secret storage API — what apps use to talk to gnome-keyring
# avahi = mDNS daemon — makes hostname.local reachable on your LAN
# nss-mdns = mDNS resolver — pairs with avahi to resolve .local hostnames
# wireless-regdb = wireless regulatory database — correct WiFi channels/power limits
# webp-pixbuf-loader = WebP image support for GTK apps — without this WebP shows broken
# swaybg = simple Wayland wallpaper setter — useful before hyprpaper is configured
# bolt = Thunderbolt device manager — only if you use Thunderbolt/USB4 peripherals
# gvfs-mtp = MTP filesystem — browse Android phones as a drive
# gvfs-nfs = NFS filesystem — mount NFS network shares
# gvfs-smb = SMB filesystem — mount Windows/Samba shares
# bluetui = Bluetooth TUI manager — connect/pair devices from the terminal
# kvantum-qt5 = Qt5 theme engine — for custom Qt app theming
# exfatprogs = ExFAT tools — read/write ExFAT USB drives
info "Utilities"
paru -S --needed --noconfirm \
  polkit-gnome \
  grim \
  slurp \
  satty \
  wl-clipboard \
  brightnessctl \
  playerctl \
  iwd \
  impala \
  jq \
  imagemagick \
  inetutils \
  ufw \
  gnome-keyring \
  gnome-themes-extra \
  libsecret \
  avahi \
  nss-mdns \
  wireless-regdb \
  webp-pixbuf-loader \
  swaybg \
  bolt \
  gvfs-mtp \
  gvfs-nfs \
  gvfs-smb \
  bluetui \
  kvantum-qt5 \
  exfatprogs
ok "Utilities installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" wofi

# ── Configure ─────────────────────────────────────────────────────────────────

# iwd — replaces wpa_supplicant, faster and lower memory
# systemd-networkd-wait-online causes a 90s boot stall if network isn't up;
# masking it skips the wait without breaking anything on a desktop
info "Configuring network"
sudo systemctl enable iwd.service
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask    systemd-networkd-wait-online.service
ok "iwd enabled, networkd-wait-online masked"

# Wireless regulatory domain — sets legal WiFi channels/power for your country
# Derived from /etc/localtime if not already set
info "Setting wireless regulatory domain"
if [[ -f "/etc/conf.d/wireless-regdom" ]]; then
  unset WIRELESS_REGDOM
  # shellcheck disable=SC1091
  source /etc/conf.d/wireless-regdom
fi
if [[ -z ${WIRELESS_REGDOM:-} ]] && [[ -e "/etc/localtime" ]]; then
  TIMEZONE=$(readlink -f /etc/localtime)
  TIMEZONE=${TIMEZONE#/usr/share/zoneinfo/}
  COUNTRY="${TIMEZONE%%/*}"
  if [[ ! $COUNTRY =~ ^[A-Z]{2}$ ]] && [[ -f /usr/share/zoneinfo/zone.tab ]]; then
    COUNTRY=$(awk -v tz="$TIMEZONE" '$3 == tz {print $1; exit}' /usr/share/zoneinfo/zone.tab)
  fi
  if [[ $COUNTRY =~ ^[A-Z]{2}$ ]]; then
    echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee -a /etc/conf.d/wireless-regdom >/dev/null
    command -v iw &>/dev/null && sudo iw reg set "$COUNTRY"
  fi
fi
ok "Wireless regulatory domain set"

# Bluetooth — enable at boot
info "Enabling bluetooth"
sudo systemctl enable bluetooth.service
ok "Bluetooth enabled"
