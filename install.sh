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

  # Wayland session
  # hyprland = tiling WM, uwsm = proper Wayland env setup, sddm = login screen
  # portals = allow apps to do screenshare/file picking through the compositor
  # NOTE: omarchy uses identical stack
  paru -S --needed --noconfirm \
    hyprland \
    uwsm \
    sddm \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk

  # Terminal
  # ghostty-git = builds from source, works on aarch64
  # NOTE: on CachyOS use ghostty-nightly-bin (pre-built, no compilation)
  # NOTE: omarchy ships ghostty/kitty/alacritty, all three
  paru -S --needed --noconfirm \
    ghostty-git

  # Shell
  # zsh = better completion, faster, what our dotfiles target
  paru -S --needed --noconfirm \
    zsh

  # Status bar
  # waybar = most popular Hyprland bar, highly configurable
  # NOTE: omarchy uses waybar too
  paru -S --needed --noconfirm \
    waybar

  # App launcher
  # walker = modern Wayland launcher, what omarchy uses
  # NOTE: on CachyOS use walker-bin (pre-built binary available)
  # NOTE: on ARM walker-bin is x86_64 only — build walker from AUR instead
  paru -S --needed --noconfirm \
    walker-bin

  # Hyprland ecosystem
  # hypridle = watches inactivity and triggers lock, hyprlock = the lock screen
  # hyprpaper = wallpaper daemon, hyprpicker = color picker
  # NOTE: omarchy uses all four
  paru -S --needed --noconfirm \
    hypridle \
    hyprlock \
    hyprpaper \
    hyprpicker

  # Notifications
  # mako = lightweight Wayland notification daemon (replaces dunst)
  # NOTE: omarchy uses mako too
  paru -S --needed --noconfirm \
    mako

  # Audio — pipewire replaces PulseAudio entirely
  # pipewire-pulse = drop-in PulseAudio replacement so apps don't notice the switch
  # wireplumber = session manager, routes audio between apps and hardware
  # NOTE: omarchy uses identical stack
  paru -S --needed --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber

  # Fonts
  # ttf-jetbrains-mono-nerd = primary font with ligatures + icons
  # noto = broad unicode + emoji coverage
  paru -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji

  # Utilities
  # polkit-gnome = GUI auth popups for sudo requests
  # grim + slurp = Wayland screenshot (grim captures, slurp selects region)
  # wl-clipboard = copy/paste on Wayland (replaces xclip/xsel)
  # brightnessctl = screen brightness via keybinds
  # playerctl = media play/pause/next via keybinds
  # networkmanager + applet = wifi/ethernet management + tray icon
  paru -S --needed --noconfirm \
    polkit-gnome \
    grim \
    slurp \
    wl-clipboard \
    brightnessctl \
    playerctl \
    networkmanager \
    network-manager-applet

  # Shell tooling
  # starship = fast prompt with git/language info
  # eza = modern ls with icons, bat = cat with syntax highlighting
  # zoxide = smart cd (z dotfiles jumps anywhere), fzf = fuzzy finder (Ctrl+R history)
  # zsh-autosuggestions = grey text suggestions, zsh-syntax-highlighting = colors as you type
  paru -S --needed --noconfirm \
    starship \
    eza \
    bat \
    zoxide \
    fzf \
    zsh-autosuggestions \
    zsh-syntax-highlighting

  # Stow (symlink manager)
  paru -S --needed --noconfirm \
    stow

  # Misc system
  paru -S --needed --noconfirm \
    swaybg

  ok "Core packages installed"
}

# ── 6. Link dotfiles with stow ─────────────────────────────────────────────────
link_dotfiles() {
  info "Linking dotfiles"
  cd "$(dirname "$0")"
  bash stow.sh
  ok "Dotfiles linked"
}

# ── Main ───────────────────────────────────────────────────────────────────────
case "${1:-}" in
  system)    system_basics; user_setup; base_packages ;;
  paru)      install_paru ;;
  packages)  install_packages ;;
  stow)      link_dotfiles ;;
  all)       install_packages; link_dotfiles ;;
  *)
    echo "Usage: $0 <step>"
    echo "  system    — run as root: timezone, user, base packages"
    echo "  paru      — run as fx: install paru from AUR"
    echo "  packages  — run as fx: install all core packages"
    echo "  stow      — run as fx: link dotfiles into HOME"
    echo "  all       — packages + stow"
    ;;
esac
