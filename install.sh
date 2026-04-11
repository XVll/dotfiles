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

# ── Main ───────────────────────────────────────────────────────────────────────
case "${1:-}" in
  system)       system_basics; user_setup; base_packages ;;
  paru)         install_paru ;;
  *)
    echo "Usage: $0 <step>"
    echo "  system  — run as root: timezone, user, base packages"
    echo "  paru    — run as fx: install paru from AUR"
    ;;
esac
