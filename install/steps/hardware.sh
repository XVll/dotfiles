#!/usr/bin/env bash
# hardware.sh — GPU drivers and hardware-specific configuration
#
# Run after wayland.sh (needs ~/.config/hypr/ to exist from stow).
# Auto-detects GPU and installs the right drivers. Creates
# ~/.config/hypr/hardware.conf with any required env vars.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

HYPR_HARDWARE_CONF="$HOME/.config/hypr/hardware.conf"

# ── Vulkan drivers ────────────────────────────────────────────────────────────
# Required for GPU-accelerated compositing in Hyprland.
# NVIDIA Vulkan is covered by nvidia-utils in the NVIDIA section below.
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

# ── NVIDIA ────────────────────────────────────────────────────────────────────
# Driver selection depends on GPU architecture:
# - Turing+ (GTX 16xx, RTX 20xx-50xx): nvidia-open-dkms — open kernel module
# - Maxwell/Pascal/Volta (GTX 9xx/10xx): nvidia-580xx-dkms — legacy proprietary
#
# Also configures:
# - modprobe: enables DRM modesetting (required for Wayland)
# - mkinitcpio: early KMS for correct display from boot
# - hardware.conf: Hyprland env vars for Vulkan backend and VA-API
NVIDIA=$(lspci | grep -i 'nvidia' || true)
if [[ -n $NVIDIA ]]; then
  info "NVIDIA drivers"
  KERNEL_HEADERS="$(pacman -Qqs '^linux(-zen|-lts|-hardened)?$' | head -1)-headers"

  if echo "$NVIDIA" | grep -qE "GTX 16[0-9]{2}|RTX [2-5][0-9]{3}|RTX PRO [0-9]{4}|Quadro RTX|RTX A[0-9]{4}|A[1-9][0-9]{2}|H[1-9][0-9]{2}|T4|L[0-9]+"; then
    paru -S --needed --noconfirm "$KERNEL_HEADERS" nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver
    GPU_ARCH="turing_plus"
    ok "  Turing+ → nvidia-open-dkms"
  elif echo "$NVIDIA" | grep -qE "GTX (9[0-9]{2}|10[0-9]{2})|GT 10[0-9]{2}|Quadro [PM][0-9]{3,4}|Quadro GV100|MX *[0-9]+|Titan (X|Xp|V)|Tesla V100"; then
    paru -S --needed --noconfirm "$KERNEL_HEADERS" nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils
    GPU_ARCH="maxwell_pascal_volta"
    ok "  Maxwell/Pascal/Volta → nvidia-580xx-dkms"
  else
    err "NVIDIA GPU detected but no compatible driver found. See: https://wiki.archlinux.org/title/NVIDIA"
  fi

  # DRM modesetting — required for Wayland to work with NVIDIA
  sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<'EOF'
options nvidia_drm modeset=1
EOF

  # Early KMS — loads nvidia modules before display server starts
  sudo tee /etc/mkinitcpio.conf.d/nvidia.conf >/dev/null <<'EOF'
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF

  # Hyprland env vars — written to hardware.conf, sourced by hyprland.conf
  if [[ $GPU_ARCH == "turing_plus" ]]; then
    cat >"$HYPR_HARDWARE_CONF" <<'EOF'
# NVIDIA Turing+ (RTX 20xx, GTX 16xx, and newer) — GSP firmware supported
env = NVD_BACKEND,direct
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
  else
    cat >"$HYPR_HARDWARE_CONF" <<'EOF'
# NVIDIA Maxwell/Pascal/Volta (GTX 9xx/10xx) — no GSP firmware
env = NVD_BACKEND,egl
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
  fi
  ok "NVIDIA configured"
else
  # No NVIDIA — create empty hardware.conf so hyprland.conf source doesn't warn
  : >"$HYPR_HARDWARE_CONF"
fi
