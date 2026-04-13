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
# bluetui = TUI Bluetooth manager — pulls in bluez (the driver stack) as a dependency
info "Bluetooth"
paru -S --needed --noconfirm bluetui
sudo systemctl enable bluetooth.service
ok "Bluetooth enabled"

ok "Hardware configured"
