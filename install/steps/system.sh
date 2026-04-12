#!/usr/bin/env bash
# system.sh — System tools and base system configuration

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# btrfs-progs = btrfs CLI tools — balance, scrub, snapshot management
# snapper = btrfs snapshot manager — automatic snapshots before upgrades
# zram-generator = compressed RAM swap — faster than disk swap, good for 16GB+
# power-profiles-daemon = balanced/performance/power-save profiles via DBus
# plymouth = animated boot splash — cosmetic, requires initramfs rebuild to enable
# tzupdate = auto-detect and set timezone from IP geolocation
info "System tools"
paru -S --needed --noconfirm \
  btrfs-progs \
  snapper \
  zram-generator \
  power-profiles-daemon \
  plymouth \
  tzupdate
ok "System tools installed"

# ── Configure ─────────────────────────────────────────────────────────────────

# Multiple GPG keyservers — single keyserver goes down often, fallbacks prevent hangs
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

# Passwordless timezone updates — tzupdate and timedatectl need root
info "Allowing passwordless timezone updates"
sudo tee /etc/sudoers.d/tzupdate >/dev/null <<'EOF'
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
sudo chmod 0440 /etc/sudoers.d/tzupdate
ok "Timezone sudoers rule written"

# 10 password attempts — default 3 is too aggressive for a long password
info "Increasing sudo password attempts to 10"
echo "Defaults passwd_tries=10" | sudo tee /etc/sudoers.d/passwd-tries >/dev/null
sudo chmod 440 /etc/sudoers.d/passwd-tries
sudo sed -i 's/^# *deny = .*/deny = 10/' /etc/security/faillock.conf
ok "Sudo tries set to 10"

# PAM faillock — 10 attempts, 2-minute lockout instead of default 3/10min
info "Configuring PAM faillock"
sudo sed -i \
  's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' \
  /etc/pam.d/system-auth
sudo sed -i \
  's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' \
  /etc/pam.d/system-auth
ok "PAM faillock: 10 attempts, 2-minute lockout"

# TCP MTU probing — kernel probes for correct MTU when connection stalls
# Fixes SSH session freezes behind VPNs and corporate firewalls
info "Enabling TCP MTU probing"
echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null
ok "TCP MTU probing enabled"

# inotify limit — VS Code, Vite, webpack watch files via inotify
# Default 8192 is too low for a project with node_modules
info "Increasing inotify file watchers"
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-file-watchers.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1
ok "inotify limit set to 524288"

# Faster shutdown — 10s per-service timeout instead of default 90s
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

# FUSE unmount hook — lazy-unmounts gvfsd-fuse before suspend
# Without this, suspend can hang if GNOME virtual filesystem is mounted
info "Installing FUSE unmount sleep hook"
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo tee /usr/lib/systemd/system-sleep/unmount-fuse >/dev/null <<'EOF'
#!/bin/bash
if [[ $1 == "pre" ]]; then
  while IFS=' ' read -r _ mountpoint fstype _; do
    if [[ $fstype == fuse.gvfsd-fuse ]]; then
      mountpoint=$(printf '%b' "$mountpoint")
      fusermount3 -uz "$mountpoint" 2>/dev/null || fusermount -uz "$mountpoint" 2>/dev/null || true
    fi
  done < /proc/mounts
fi
if [[ $1 == "post" ]]; then
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

# input group — raw /dev/input/ access for gamepads and dictation hotkeys
info "Adding $USER to input group"
sudo usermod -aG input "$USER"
ok "Added to input group (re-login to apply)"

# linux-modules-cleanup — removes orphaned kernel module dirs after upgrades
info "Enabling kernel modules cleanup"
sudo systemctl enable linux-modules-cleanup.service
ok "Kernel modules cleanup enabled"

# USB autosuspend off — Linux parks idle USB devices by default to save power
# On desktop this causes peripherals to drop out or lag
info "Disabling USB autosuspend"
echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null
ok "USB autosuspend disabled"

# Power button → ignore — let Hyprland bind it to a power menu instead
info "Disabling logind power button handler"
sudo sed -i 's/.*HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
ok "Power button set to ignore"
