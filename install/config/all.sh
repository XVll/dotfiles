#!/usr/bin/env bash
# config/all.sh — System configuration phase
#
# Runs after all packages are installed. Every script from omarchy's
# install/config/all.sh is represented here in the same order — kept ones are
# inlined and active, skipped ones are commented out with a reason.
#
# Adapted for: Intel i5 desktop, no GPU, stow-based dotfiles, CachyOS/Arch.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

# ─────────────────────────────────────────────────────────────────────────────
# DOTFILES — stow.sh handles symlinking, run it manually
#
# Stow per-package as you install each section (see Stow: hints in packages.sh)
# or run ./stow.sh with no arguments to symlink everything at once.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# THEME — omarchy: config/theme.sh
# SKIPPED: Runs omarchy-theme-set (an omarchy-specific binary) to activate
# Tokyo Night, then symlinks btop and mako configs from the theme directory.
# We ship our theme configs directly via stow — no runtime setup needed.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# BRANDING — omarchy: config/branding.sh
# SKIPPED: Copies omarchy's own logo/icon files into ~/.config/omarchy/branding
# for use in fastfetch and a screensaver. We'll use our own branding via stow.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# GIT identity → packages.sh "Git tools" Configure block
# SHELL default → packages.sh "Shell + tools" Configure block

# ─────────────────────────────────────────────────────────────────────────────
# GPG — Configure keyservers for better reliability
# omarchy: config/gpg.sh
#
# The default GnuPG config only has one keyserver. If it's down, key fetches
# fail silently. Multiple keyservers give fallback options.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring GPG keyservers"
sudo mkdir -p /etc/gnupg
sudo tee /etc/gnupg/dirmngr.conf >/dev/null <<'EOF'
keyserver hkps://keyserver.ubuntu.com
keyserver hkps://pgp.surfnet.nl
keyserver hkps://keys.mailvelope.com
keyserver hkps://keyring.debian.org
keyserver hkps://pgp.mit.edu

connect-quick-timeout 4
EOF
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr  || true
sudo gpgconf --launch dirmngr || true
ok "GPG keyservers configured"

# ─────────────────────────────────────────────────────────────────────────────
# TIMEZONES — Allow wheel users to update timezone without a password
# omarchy: config/timezones.sh
#
# tzupdate auto-detects your timezone from your IP and calls timedatectl to
# apply it. Both commands need root; this sudoers rule removes the prompt so
# a GUI or script can invoke them without interrupting the user.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring passwordless timezone updates"
sudo tee /etc/sudoers.d/tzupdate >/dev/null <<'EOF'
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
sudo chmod 0440 /etc/sudoers.d/tzupdate
ok "Timezone sudoers rule written"

# ─────────────────────────────────────────────────────────────────────────────
# SUDO TRIES — Increase password attempts from 3 to 10
# omarchy: config/increase-sudo-tries.sh
#
# The default of 3 is easy to hit with a complex password. 10 attempts
# before lockout is more forgiving without being meaningfully less secure.
# Also updates hyprlock's faillock to match so the lock screen behaves the
# same way as the terminal sudo prompt.
# ─────────────────────────────────────────────────────────────────────────────
info "Increasing sudo password attempts to 10"
echo "Defaults passwd_tries=10" | sudo tee /etc/sudoers.d/passwd-tries >/dev/null
sudo chmod 440 /etc/sudoers.d/passwd-tries
sudo sed -i 's/^# *deny = .*/deny = 10/' /etc/security/faillock.conf
ok "Sudo tries set to 10"

# ─────────────────────────────────────────────────────────────────────────────
# LOCKOUT LIMIT — PAM faillock: 10 attempts, 2-minute lockout
# omarchy: config/increase-lockout-limit.sh
#
# PAM's pam_faillock module tracks failed logins and locks accounts after
# too many failures. The defaults (3 attempts, 10 min lockout) are very
# aggressive for a personal machine. 10 attempts + 2 min lockout is still
# protective but doesn't lock you out for a typo.
# The sddm-autologin edit ensures the autologin counter resets properly
# on successful login, preventing ghost lockouts.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring PAM faillock"
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' /etc/pam.d/system-auth
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' /etc/pam.d/system-auth
sudo sed -i '/pam_faillock\.so preauth/d' /etc/pam.d/sddm-autologin
sudo sed -i '/auth.*pam_permit\.so/a auth        required    pam_faillock.so authsucc' /etc/pam.d/sddm-autologin
ok "PAM faillock: 10 attempts, 2-minute lockout"

# ─────────────────────────────────────────────────────────────────────────────
# SSH FLAKINESS — Enable TCP MTU path discovery
# omarchy: config/ssh-flakiness.sh
#
# tcp_mtu_probing=1 tells the kernel to probe for the correct MTU when a
# connection stalls. SSH sessions can randomly freeze behind corporate
# firewalls, VPNs, or ISPs that silently drop ICMP "fragmentation needed"
# messages. This sysctl is the standard fix.
# ─────────────────────────────────────────────────────────────────────────────
info "Enabling TCP MTU probing (SSH flakiness fix)"
echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null
ok "TCP MTU probing enabled"

# ─────────────────────────────────────────────────────────────────────────────
# FILE WATCHERS — Increase inotify limit for dev tools
# omarchy: config/increase-file-watchers.sh
#
# inotify is how tools like VS Code, webpack, and Vite watch files for changes.
# The default kernel limit (8192 watchers) is too low for a modern project
# with node_modules. 524288 is the value recommended in the VS Code docs.
# ─────────────────────────────────────────────────────────────────────────────
info "Increasing inotify file watchers"
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-file-watchers.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1
ok "inotify limit set to 524288"

# KEYBOARD LAYOUT + XCOMPOSE → packages.sh "Wayland session" Configure block
# MISE WORK + POWERPROFILESCTL fix → packages.sh "Editor" Configure block

# DOCKER daemon config → packages.sh "Docker" Configure block
# MIMETYPES (xdg-mime) → packages.sh "Applications" Configure block

# ─────────────────────────────────────────────────────────────────────────────
# NAUTILUS PYTHON — omarchy: config/nautilus-python.sh
# SKIPPED: Copies a LocalSend right-click extension for Nautilus from an
# omarchy-specific path. The extension itself is fine but the source path
# is hardcoded to omarchy's install directory — we'll add it if needed later.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# LOCALDB — Update plocate/mlocate database
# omarchy: config/localdb.sh
#
# `locate` finds files by name instantly but relies on a pre-built index.
# The nightly timer hasn't run yet after a fresh install, so updatedb runs
# now to index everything we just installed.
# ─────────────────────────────────────────────────────────────────────────────
info "Updating locate database"
sudo updatedb
ok "Locate database updated"

# ─────────────────────────────────────────────────────────────────────────────
# WALKER ELEPHANT — omarchy: config/walker-elephant.sh
# SKIPPED: Sets up the Walker launcher and Elephant menu daemon — both are
# omarchy-specific tools with configs pulled from omarchy's path. We use
# Walker but configure it purely via stow.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# FAST SHUTDOWN — Reduce systemd stop timeout
# omarchy: config/fast-shutdown.sh
#
# By default systemd waits 90 seconds for each service to stop before
# force-killing it. On shutdown/reboot this means a hung service can add
# 90s of waiting. 10s is aggressive enough to be fast without cutting
# services off before they finish legitimate cleanup.
# The user@.service.d override applies the same timeout to user sessions.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring faster shutdown"
sudo mkdir -p /etc/systemd/system.conf.d
sudo tee /etc/systemd/system.conf.d/10-faster-shutdown.conf >/dev/null <<'EOF'
[Manager]
DefaultTimeoutStopSec=10s
DefaultTimeoutAbortSec=10s
EOF

sudo mkdir -p /etc/systemd/system/user@.service.d
sudo tee /etc/systemd/system/user@.service.d/faster-shutdown.conf >/dev/null <<'EOF'
[Service]
TimeoutStopSec=10s
EOF
sudo systemctl daemon-reload
ok "Shutdown timeout set to 10s"

# ─────────────────────────────────────────────────────────────────────────────
# UNMOUNT FUSE — Unmount FUSE filesystems before sleep
# omarchy: config/unmount-fuse.sh
#
# FUSE daemons (like gvfsd-fuse used by Nautilus for network/cloud drives)
# can block in uninterruptible sleep during suspend, causing the suspend
# to silently fail or take forever. This sleep hook lazy-unmounts them
# before the kernel freezes processes, then restarts gvfs on wake so the
# mounts come back.
# ─────────────────────────────────────────────────────────────────────────────
info "Installing FUSE unmount sleep hook"
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo tee /usr/lib/systemd/system-sleep/unmount-fuse >/dev/null <<'EOF'
#!/bin/bash
# Lazy-unmount gvfsd-fuse filesystems before suspend/hibernate to prevent
# the kernel's process freeze from timing out.

if [[ $1 == "pre" ]]; then
  while IFS=' ' read -r _ mountpoint fstype _; do
    if [[ $fstype == fuse.gvfsd-fuse ]]; then
      mountpoint=$(printf '%b' "$mountpoint")
      fusermount3 -uz "$mountpoint" 2>/dev/null || fusermount -uz "$mountpoint" 2>/dev/null || true
    fi
  done < /proc/mounts
fi

if [[ $1 == "post" ]]; then
  # Run in background — user.slice is still frozen at this point
  (
    sleep 5
    for uid_dir in /run/user/*; do
      uid=$(basename "$uid_dir")
      if [[ -S $uid_dir/bus ]]; then
        sudo -u "#$uid" env \
          DBUS_SESSION_BUS_ADDRESS="unix:path=$uid_dir/bus" \
          XDG_RUNTIME_DIR="$uid_dir" \
          systemctl --user restart gvfs-daemon.service 2>/dev/null || true
      fi
    done
  ) &
fi
EOF
sudo chmod 755 /usr/lib/systemd/system-sleep/unmount-fuse
ok "FUSE sleep hook installed"

# ─────────────────────────────────────────────────────────────────────────────
# SUDOLESS ASDCONTROL — omarchy: config/sudoless-asdcontrol.sh
# SKIPPED: Passwordless sudo for asdcontrol, which controls brightness on
# Apple Studio Displays via USB. We don't have an Apple Studio Display.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# INPUT GROUP — Add user to the input group
# omarchy: config/input-group.sh
#
# The input group allows reading raw input devices from /dev/input/.
# Required for: dictation tools (that listen for a hotkey globally),
# Xbox/gamepad controllers, some accessibility software.
# Takes effect after re-login.
# ─────────────────────────────────────────────────────────────────────────────
info "Adding $USER to input group"
sudo usermod -aG input "$USER"
ok "Added to input group (re-login to apply)"

# ─────────────────────────────────────────────────────────────────────────────
# OMARCHY AI SKILL — omarchy: config/omarchy-ai-skill.sh
# SKIPPED: Symlinks omarchy's bundled Claude Code skill into ~/.claude/skills.
# This is their skill file, not ours.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# KERNEL MODULES CLEANUP — Enable linux-modules-cleanup service
# omarchy: config/kernel-modules-hook.sh
#
# Every kernel upgrade leaves old module directories in /usr/lib/modules/.
# linux-modules-cleanup.service removes orphaned module dirs after upgrades
# so the directory doesn't slowly accumulate GBs of old kernels.
# ─────────────────────────────────────────────────────────────────────────────
info "Enabling kernel modules cleanup"
sudo systemctl enable linux-modules-cleanup.service
ok "Kernel modules cleanup enabled"

# ─────────────────────────────────────────────────────────────────────────────
# WIFI POWERSAVE — omarchy: config/wifi-powersave-rules.sh
# SKIPPED: udev rules that toggle WiFi power saving off on AC and on on battery.
# We're on a desktop — no battery, always on AC.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# PLOCATE AC ONLY — omarchy: config/plocate-ac-only.sh
# SKIPPED: Prevents the nightly plocate-updatedb from running on battery power
# (disk indexing drains battery). Desktop is always on AC — irrelevant.
# ─────────────────────────────────────────────────────────────────────────────


# ═════════════════════════════════════════════════════════════════════════════
# HARDWARE
# ═════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# NETWORK — Enable wireless daemon, suppress boot stall
# omarchy: config/hardware/network.sh
#
# iwd replaces wpa_supplicant as the WiFi backend — faster, lower memory,
# better reconnect behavior. systemd-networkd-wait-online.service causes a
# 90s boot timeout if the network isn't up by the time systemd reaches
# network-online.target (common on desktop with iwd). Masking it skips
# the wait entirely without breaking anything that actually needs it.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring network"
sudo systemctl enable iwd.service
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask    systemd-networkd-wait-online.service
ok "iwd enabled, networkd-wait-online masked"

# ─────────────────────────────────────────────────────────────────────────────
# WIRELESS REGDOM — Set WiFi regulatory domain from timezone
# omarchy: config/hardware/set-wireless-regdom.sh
#
# WiFi regulations (legal channels, max TX power) differ by country. Without
# the correct regulatory domain the kernel uses a conservative fallback that
# may block channels your router uses. This derives your country code from
# /etc/localtime and writes it to wireless-regdom, which is read at boot by
# the cfg80211 module.
# ─────────────────────────────────────────────────────────────────────────────
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

  # Some timezone paths start with the 2-letter country code directly
  if [[ ! $COUNTRY =~ ^[A-Z]{2}$ ]] && [[ -f /usr/share/zoneinfo/zone.tab ]]; then
    COUNTRY=$(awk -v tz="$TIMEZONE" '$3 == tz {print $1; exit}' /usr/share/zoneinfo/zone.tab)
  fi

  if [[ $COUNTRY =~ ^[A-Z]{2}$ ]]; then
    echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee -a /etc/conf.d/wireless-regdom >/dev/null
    command -v iw &>/dev/null && sudo iw reg set "$COUNTRY"
  fi
fi
ok "Wireless regulatory domain set"

# ─────────────────────────────────────────────────────────────────────────────
# FIX FKEYS — omarchy: config/hardware/fix-fkeys.sh
# SKIPPED: Sets hid_apple fnmode=2 so Apple-style keyboards (Lofree Flow84,
# etc.) always send F1–F12 without holding Fn. We use a standard keyboard.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# BLUETOOTH — Enable bluetooth service at boot
# omarchy: config/hardware/bluetooth.sh
# ─────────────────────────────────────────────────────────────────────────────
info "Enabling bluetooth"
sudo systemctl enable bluetooth.service
ok "Bluetooth enabled"

# ─────────────────────────────────────────────────────────────────────────────
# PRINTER — CUPS + Avahi + mDNS for network printer discovery
# omarchy: config/hardware/printer.sh
#
# CUPS is the print server. Avahi provides mDNS so printers advertising via
# Bonjour/mDNS are discoverable on the local network.
# The resolved.conf disables resolved's built-in mDNS (since Avahi owns it).
# The nsswitch.conf edit adds mdns_minimal so .local hostnames resolve.
# cups-browsed auto-adds discovered network printers to CUPS.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring printing"
sudo systemctl enable cups.service

# Disable resolved's mDNS — Avahi handles it
sudo mkdir -p /etc/systemd/resolved.conf.d
printf '[Resolve]\nMulticastDNS=no\n' | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf >/dev/null
sudo systemctl enable avahi-daemon.service

# Add mDNS resolution for .local domains
sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns/' /etc/nsswitch.conf

# Auto-add remote printers found via mDNS
if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf 2>/dev/null; then
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf >/dev/null
fi
sudo systemctl enable cups-browsed.service
ok "Printing configured"

# ─────────────────────────────────────────────────────────────────────────────
# USB AUTOSUSPEND — Disable USB power management
# omarchy: config/hardware/usb-autosuspend.sh
#
# Linux suspends idle USB devices by default to save power. On a desktop this
# causes peripherals (mice, keyboards, audio interfaces, USB hubs) to drop
# out or lag. autosuspend=-1 keeps all USB devices always powered on.
# ─────────────────────────────────────────────────────────────────────────────
info "Disabling USB autosuspend"
echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null
ok "USB autosuspend disabled"

# ─────────────────────────────────────────────────────────────────────────────
# IGNORE POWER BUTTON — Stop logind from shutting down on power button press
# omarchy: config/hardware/ignore-power-button.sh
#
# The default logind behavior is to shut the system down immediately on power
# button press. Setting it to ignore lets you bind the power button to a
# custom power menu in Hyprland (sleep / restart / shutdown) instead.
# ─────────────────────────────────────────────────────────────────────────────
info "Disabling logind power button handler"
sudo sed -i 's/.*HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
ok "Power button set to ignore"

# ─────────────────────────────────────────────────────────────────────────────
# NVIDIA — omarchy: config/hardware/nvidia.sh
# SKIPPED: Auto-detects NVIDIA GPU and installs the appropriate driver package
# (nvidia-open-dkms for Turing+, nvidia-580xx-dkms for older), configures
# early KMS via modprobe and mkinitcpio, and sets Hyprland env vars.
# We have Intel integrated graphics only — no NVIDIA GPU present.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# VULKAN — Install Vulkan ICD driver for detected GPU
# omarchy: config/hardware/vulkan.sh
#
# Vulkan is required by Hyprland for hardware-accelerated compositing.
# This auto-detects the GPU vendor from lspci and installs the matching
# driver. For Intel integrated graphics: vulkan-intel.
# (NVIDIA Vulkan is bundled with nvidia-utils — handled by nvidia.sh above.)
# ─────────────────────────────────────────────────────────────────────────────
info "Installing Vulkan driver"
declare -A VULKAN_DRIVERS=(
  [Intel]=vulkan-intel
  [AMD]=vulkan-radeon
)
VULKAN_PKGS=()
for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" >/dev/null 2>&1; then
    VULKAN_PKGS+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done
if (( ${#VULKAN_PKGS[@]} > 0 )); then
  paru -S --needed --noconfirm "${VULKAN_PKGS[@]}"
fi
ok "Vulkan driver installed"

# ─────────────────────────────────────────────────────────────────────────────
# INTEL VIDEO ACCELERATION — Hardware video decode/encode via VA-API
# omarchy: config/hardware/intel/video-acceleration.sh
#
# VA-API lets the GPU handle video decode instead of the CPU. Without it,
# video playback in mpv or browsers uses software decoding which is slower
# and hotter. intel-media-driver covers HD Graphics 5xx and newer (Broadwell+,
# including UHD, Iris, Xe). libva-intel-driver covers the older GMA series.
# ─────────────────────────────────────────────────────────────────────────────
info "Installing Intel video acceleration"
INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel' || true)
if [[ -n $INTEL_GPU ]]; then
  if [[ ${INTEL_GPU,,} =~ (hd[[:space:]]graphics|uhd[[:space:]]graphics|xe|iris|arc) ]]; then
    paru -S --needed --noconfirm intel-media-driver
  elif [[ ${INTEL_GPU,,} =~ gma ]]; then
    paru -S --needed --noconfirm libva-intel-driver
  fi
fi
ok "Intel video acceleration installed"

# ─────────────────────────────────────────────────────────────────────────────
# INTEL LPMD — omarchy: config/hardware/intel/lpmd.sh
# SKIPPED: Intel Low Power Mode Daemon dynamically parks efficiency cores when
# the system is idle, reducing power draw. Only useful on hybrid (P+E core)
# laptop CPUs (Alder Lake+). Desktop i5 is not a hybrid core laptop CPU.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# INTEL THERMALD — omarchy: config/hardware/intel/thermald.sh
# SKIPPED: Thermal management daemon that prevents sustained CPU throttling
# on Intel laptops. On a desktop the BIOS and system cooling are sufficient.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# INTEL IPU7 CAMERA — omarchy: config/hardware/intel/ipu7-camera.sh
# SKIPPED: MIPI camera support for Intel IPU7 (Lunar Lake, Panther Lake).
# Desktop machines don't have integrated MIPI cameras.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# INTEL PTL KERNEL — omarchy: config/hardware/intel/ptl-kernel.sh
# SKIPPED: Installs a custom kernel with patches for Intel Panther Lake
# (2025+ mobile silicon). Not applicable to our i5 desktop.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# INTEL FIX WIFI7 EHT — omarchy: config/hardware/intel/fix-wifi7-eht.sh
# SKIPPED: Disables WiFi 7 (EHT) on Intel BE200/BE211 cards due to a broken
# RX data path in the iwlwifi driver. Desktop i5 is unlikely to have a
# WiFi 7 card, and desktops are often wired anyway.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# DELL XPS — omarchy: config/hardware/dell/*
# SKIPPED: Haptic touchpad daemon (Dell XPS 13/15/16 Synaptics touchpad) and
# OLED panel power fix for XPS + Panther Lake. Desktop machine, no Dell XPS.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# ASUS ROG — omarchy: config/hardware/asus/*
# SKIPPED: WirePlumber soft mixer fix and mic gain reduction for ASUS ROG
# laptops with Realtek ALC285. Not ASUS ROG hardware.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# FRAMEWORK — omarchy: config/hardware/framework/*
# SKIPPED: Framework 16 AMD audio profile fix and QMK HID udev rule for
# per-key RGB control. Not Framework hardware.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# APPLE — omarchy: config/hardware/apple/*
# SKIPPED: T2 security chip support (tiny-dfr, t2fanrd, apple-bce), SPI
# keyboard modules (applespi), and NVMe d3cold suspend fix for MacBook models.
# Not Apple hardware.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# BROADCOM WIFI — omarchy: config/hardware/fix-bcm43xx.sh
# SKIPPED: Installs broadcom-wl DKMS driver for BCM4360/BCM4331 chips found
# in 2012–2015 MacBooks. Not applicable hardware.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# SURFACE KEYBOARD — omarchy: config/hardware/fix-surface-keyboard.sh
# SKIPPED: Loads pinctrl and surface_aggregator kernel modules required for
# the keyboard to work on Microsoft Surface devices.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# YT6801 ETHERNET — omarchy: config/hardware/fix-yt6801-ethernet-adapter.sh
# SKIPPED: Installs DKMS driver for Motorcomm YT6801 USB ethernet adapter
# (found in Slimbook Executive). Not applicable hardware.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# SYNAPTIC TOUCHPAD — omarchy: config/hardware/fix-synaptic-touchpad.sh
# SKIPPED: Enables Synaptics InterTouch (psmouse module) for specific laptop
# touchpads. Desktop machine, no touchpad.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# TUXEDO BACKLIGHT — omarchy: config/hardware/fix-tuxedo-backlight.sh
# SKIPPED: Installs tuxedo-drivers-dkms for keyboard backlight on Tuxedo
# and Slimbook (Clevo chassis) laptops. Not applicable hardware.
# ─────────────────────────────────────────────────────────────────────────────
