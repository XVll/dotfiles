#!/usr/bin/env bash
# install.sh — bootstrap a fresh Arch/CachyOS system
# Run as root for system steps, then as your user for the rest
#
# VM:      Arch Linux ARM (aarch64) on Parallels
# Target:  CachyOS (x86_64) on bare metal
#
# Usage: bash install.sh

set -euo pipefail

# ── Helpers ────────────────────────────────────────────────────────────────────
info()  { echo "==> $*"; }
ok()    { echo " ✓  $*"; }

# ── 1. System basics (run as root) ─────────────────────────────────────────────
system_basics() {
  info "System basics"

  # Pacman sandbox workaround — Parallels ARM kernel lacks Landlock support
  # NOTE: Not needed on CachyOS (x86_64 kernel has Landlock)
  if ! grep -q "DisableSandbox" /etc/pacman.conf; then
    echo "DisableSandbox" >> /etc/pacman.conf
  fi

  timedatectl set-ntp true
  timedatectl set-timezone Europe/Istanbul

  ok "System basics done"
}

# ── 2. User setup (run as root) ────────────────────────────────────────────────
user_setup() {
  info "User setup"

  useradd -m -G wheel,audio,video,storage -s /bin/bash fx
  passwd fx

  # Passwordless sudo for wheel group
  sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

  ok "User setup done"
}

# ── 3. Base packages (run as root) ─────────────────────────────────────────────
base_packages() {
  info "Base packages"

  pacman -S --needed --noconfirm \
    base-devel \
    git

  ok "Base packages done"
}

# ── 4. AUR helper — paru (run as your user) ────────────────────────────────────
install_paru() {
  info "Installing paru"

  # NOTE: On CachyOS, paru is available in the CachyOS repo:
  #   sudo pacman -S paru
  # On Arch ARM we build it from AUR:
  cd /tmp
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si --noconfirm
  cd ~

  ok "paru installed"
}

# ── 5. Core packages (run as your user) ───────────────────────────────────────
install_packages() {
  info "Installing core packages"

  # Window manager & Wayland session
  # uwsm = Universal Wayland Session Manager, handles proper env var setup
  # NOTE: omarchy uses same stack (hyprland + uwsm + sddm)
  paru -S --needed --noconfirm \
    hyprland \
    uwsm \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    sddm

  # Status bar & launcher
  # NOTE: omarchy uses walker as launcher; we use wofi (simpler, no extra deps)
  paru -S --needed --noconfirm \
    waybar \
    wofi

  # Terminal & shell
  # ghostty is AUR on ARM and may fail to build — using kitty (in official repos)
  # On CachyOS: swap kitty for ghostty
  paru -S --needed --noconfirm \
    kitty \
    zsh

  # Hyprland ecosystem
  # hypridle = locks screen after inactivity, hyprlock = the lock screen itself
  paru -S --needed --noconfirm \
    hypridle \
    hyprlock \
    hyprpaper \
    hyprpicker

  # Notifications
  paru -S --needed --noconfirm \
    mako

  # Audio — pipewire replaces PulseAudio entirely
  # wireplumber is the session manager that routes audio between apps and hardware
  # NOTE: omarchy uses identical stack
  paru -S --needed --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber

  # Fonts
  paru -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji

  # Utilities
  # polkit-gnome = GUI auth popups (e.g. sudo password prompts in GUI)
  # grim + slurp = Wayland screenshot tools
  # wl-clipboard = copy/paste for Wayland (replaces xclip/xsel)
  paru -S --needed --noconfirm \
    polkit-gnome \
    grim \
    slurp \
    wl-clipboard \
    brightnessctl \
    playerctl \
    networkmanager \
    network-manager-applet

  ok "Core packages installed"
}

# ── Main ───────────────────────────────────────────────────────────────────────
case "${1:-}" in
  system)    system_basics; user_setup; base_packages ;;
  paru)      install_paru ;;
  packages)  install_packages ;;
  *)
    echo "Usage: $0 <step>"
    echo "  system    — run as root: timezone, user, base packages"
    echo "  paru      — run as fx: install paru from AUR"
    echo "  packages  — run as fx: install all core packages"
    ;;
esac
