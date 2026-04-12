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
# egl-wayland = EGL Wayland platform — lets OpenGL apps render natively (not via XWayland)
# gtk4-layer-shell = GTK4 wlr-layer-shell — needed by GTK4 surface apps (waybar, etc.)
# qt5-wayland + qt6-wayland = Qt native Wayland rendering instead of going through XWayland
# hyprland-guiutils = Hyprland GUI config and utility apps
info "Wayland session"
paru -S --needed --noconfirm \
  hyprland \
  uwsm \
  sddm \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  egl-wayland \
  gtk4-layer-shell \
  qt5-wayland \
  qt6-wayland \
  hyprland-guiutils
ok "Wayland session installed"

# GPU drivers — auto-detected from lspci output
# vulkan-intel / vulkan-radeon = Vulkan ICD driver — required for GPU-accelerated compositing
# intel-media-driver = Intel VA-API (HD/UHD/Xe/Iris/Arc) — hardware video decode/encode
# libva-intel-driver = legacy Intel VA-API (GMA series) — older codec support
info "Installing GPU drivers"
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

# ── Configure ─────────────────────────────────────────────────────────────────

# Sync keyboard layout from /etc/vconsole.conf → ~/.config/hypr/input.conf
# TTY and Wayland session will use the same layout after install
info "Syncing keyboard layout"
vconsole="/etc/vconsole.conf"
hyprconf="$HOME/.config/hypr/input.conf"
if [ -f "$vconsole" ] && [ -f "$hyprconf" ]; then
  if grep -q '^XKBLAYOUT=' "$vconsole"; then
    layout=$(grep '^XKBLAYOUT=' "$vconsole" | cut -d= -f2 | tr -d '"')
    sed -i "s/^  kb_layout =.*/  kb_layout = $layout/" "$hyprconf"
  fi
  if grep -q '^XKBVARIANT=' "$vconsole"; then
    variant=$(grep '^XKBVARIANT=' "$vconsole" | cut -d= -f2 | tr -d '"')
    sed -i "s/^  kb_variant =.*/  kb_variant = $variant/" "$hyprconf"
  fi
fi
ok "Keyboard layout synced"

# SDDM autologin — logs straight into hyprland-uwsm without password prompt
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
# Remove gnome-keyring from SDDM PAM — conflicts with unencrypted keyring below
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d'     /etc/pam.d/sddm 2>/dev/null || true
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm 2>/dev/null || true
sudo systemctl enable sddm.service
ok "SDDM configured with autologin (hyprland-uwsm)"

# Unencrypted default keyring — SDDM autologin skips the login password so
# GNOME Keyring never gets unlocked normally. An unencrypted keyring with
# lock-on-idle=false means apps (browsers, gh CLI) never prompt for a password.
info "Creating auto-unlocking GNOME Keyring"
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
ok "Default keyring created"
