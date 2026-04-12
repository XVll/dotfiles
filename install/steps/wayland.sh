#!/usr/bin/env bash
# wayland.sh — Hyprland compositor, display manager, XDG portals, GPU drivers

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# hyprland = tiling Wayland compositor — the window manager
# uwsm = Universal Wayland Session Manager — sets up env variables properly,
#         replaces manual exec-once env hacks in hyprland.conf
# sddm = display manager — handles login screen and session launch
# xdg-desktop-portal-hyprland = screensharing + file picker via Hyprland protocols
# xdg-desktop-portal-gtk = fallback portal for GTK apps that don't use Hyprland portal
# hyprland-preview-share-picker = screen share window picker UI
# egl-wayland = EGL Wayland platform — lets OpenGL apps render natively (not via XWayland)
# gtk4-layer-shell = GTK4 wlr-layer-shell — needed by GTK4 surface apps (waybar, etc.)
# qt5-wayland + qt6-wayland = Qt native Wayland rendering instead of going through XWayland
# kvantum-qt5 = Qt5 theme engine — keeps Qt apps visually consistent with GTK
# gnome-keyring = secret storage — browser passwords, git tokens, etc.
# libsecret = library apps use to talk to gnome-keyring
# hyprland-guiutils = Hyprland GUI utilities (hyprpm, color tools, etc.)
info "Wayland session"
paru -S --needed --noconfirm \
  hyprland \
  uwsm \
  sddm \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  hyprland-preview-share-picker \
  egl-wayland \
  gtk4-layer-shell \
  qt5-wayland \
  qt6-wayland \
  kvantum-qt5 \
  gnome-keyring \
  libsecret \
  hyprland-guiutils
ok "Wayland session installed"

# GPU drivers — auto-detected from lspci output
# vulkan-intel / vulkan-radeon = Vulkan ICD driver — required for GPU-accelerated compositing
# intel-media-driver = Intel VA-API (HD/UHD/Xe/Iris/Arc) — hardware video decode/encode
# libva-intel-driver = legacy Intel VA-API (GMA series) — older codec support
info "GPU drivers"
declare -A VULKAN_DRIVERS=([Intel]=vulkan-intel [AMD]=vulkan-radeon)
VULKAN_PKGS=()
for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" >/dev/null 2>&1; then
    VULKAN_PKGS+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done
(( ${#VULKAN_PKGS[@]} > 0 )) && paru -S --needed --noconfirm "${VULKAN_PKGS[@]}"

INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel' || true)
if [[ -n $INTEL_GPU ]]; then
  if [[ ${INTEL_GPU,,} =~ (hd[[:space:]]graphics|uhd[[:space:]]graphics|xe|iris|arc) ]]; then
    paru -S --needed --noconfirm intel-media-driver libva-intel-driver
  elif [[ ${INTEL_GPU,,} =~ gma ]]; then
    paru -S --needed --noconfirm libva-intel-driver
  fi
fi
ok "GPU drivers installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" hypr uwsm xdg
