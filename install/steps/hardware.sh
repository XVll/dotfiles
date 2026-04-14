#!/usr/bin/env bash
# hardware.sh — GPU drivers and hardware-specific configuration
#
# Run after wayland.sh (needs ~/.config/hypr/ to exist from stow).
# Auto-detects GPU and installs the right drivers.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Vulkan drivers ────────────────────────────────────────────────────────────
# Required for GPU-accelerated compositing in Hyprland.
info "Vulkan drivers"
declare -A VULKAN_DRIVERS=([Intel]=vulkan-intel [AMD]=vulkan-radeon)
VULKAN_PKGS=()
for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" >/dev/null 2>&1; then
    VULKAN_PKGS+=("${VULKAN_DRIVERS[$vendor]}")
    ok "  $vendor → ${VULKAN_DRIVERS[$vendor]}"
  fi
done
(( ${#VULKAN_PKGS[@]} > 0 )) && paru -S --needed --noconfirm "${VULKAN_PKGS[@]}"

# ── Intel VA-API ──────────────────────────────────────────────────────────────
# Hardware video decode/encode — used by browsers, mpv, obs, etc.
# intel-media-driver = HD/UHD/Xe/Iris/Arc (modern, 2016+)
# libva-intel-driver = GMA series (legacy, pre-2016)
INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel' || true)
if [[ -n $INTEL_GPU ]]; then
  info "Intel VA-API"
  if [[ ${INTEL_GPU,,} =~ (hd[[:space:]]graphics|uhd[[:space:]]graphics|xe|iris|arc) ]]; then
    paru -S --needed --noconfirm intel-media-driver libva-intel-driver
    ok "  intel-media-driver + libva-intel-driver"
  elif [[ ${INTEL_GPU,,} =~ gma ]]; then
    paru -S --needed --noconfirm libva-intel-driver
    ok "  libva-intel-driver (legacy GMA)"
  fi
fi

# ── Bluetooth ─────────────────────────────────────────────────────────────────
# bluez = the only Linux bluetooth daemon — kernel has the drivers, bluez manages them
# bluetui = TUI bluetooth manager — pair, connect, trust devices from terminal
info "Bluetooth"
paru -S --needed --noconfirm bluez bluetui
sudo systemctl enable bluetooth.service
ok "Bluetooth enabled"

# ── Networking ────────────────────────────────────────────────────────────────
# NetworkManager = manages all connections (ethernet, tethering, VPN)
# iwd = modern WiFi daemon — NM uses it as backend instead of wpa_supplicant
# wireless-regdb = regulatory database — unlocks full WiFi channels/power for your country
# usbmuxd = iPhone USB communication daemon — required for iPhone tethering
# libimobiledevice = Apple protocol library — usbmuxd dependency for iPhone support
info "Networking"
paru -S --needed --noconfirm networkmanager iwd wireless-regdb usbmuxd libimobiledevice

# Configure NetworkManager to use iwd as WiFi backend instead of wpa_supplicant
sudo mkdir -p /etc/NetworkManager/conf.d
cat <<'EOF' | sudo tee /etc/NetworkManager/conf.d/iwd-backend.conf >/dev/null
[device]
wifi.backend=iwd

[main]
iwd-config-path=auto
EOF

# iwd must be running for NM to use it as WiFi backend
sudo systemctl enable iwd.service
# Disable wpa_supplicant — iwd replaces it, NM won't use it with iwd backend
sudo systemctl disable --now wpa_supplicant.service 2>/dev/null || true
sudo systemctl enable NetworkManager.service
# Stop then restart NM so it picks up iwd backend cleanly
sudo systemctl stop NetworkManager.service
sudo systemctl restart NetworkManager.service

# networkd-wait-online causes 90s boot stall if network isn't up at boot — safe to mask on desktop
sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true
sudo systemctl mask    systemd-networkd-wait-online.service
ok "NetworkManager + iwd enabled"

# Wireless regulatory domain — unlocks full WiFi channels/power for your country
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

ok "Hardware configured"
