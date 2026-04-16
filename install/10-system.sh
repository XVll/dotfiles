#!/bin/bash

# System domain: systemd tweaks, power, sysctl, sudoers

pkg-add kernel-modules-hook \
  gvfs-mtp gvfs-nfs gvfs-smb inetutils inxi \
  xmlstarlet qt5-wayland libsecret libyaml exfatprogs

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" system

# Faster shutdown systemd configs
sudo mkdir -p /etc/systemd/system.conf.d
sudo cp "$DOTFILES/system/systemd/faster-shutdown.conf" /etc/systemd/system.conf.d/10-faster-shutdown.conf
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo cp ~/.config/systemd/user@.service.d/faster-shutdown.conf /etc/systemd/system/user@.service.d/

# System-sleep scripts
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root "$DOTFILES/system/systemd/system-sleep/unmount-fuse" /usr/lib/systemd/system-sleep/

# Kernel modules hook
sudo systemctl enable --now linux-modules-cleanup.service

# Increase sudo password tries
echo "Defaults passwd_tries=10" | sudo tee /etc/sudoers.d/passwd-tries >/dev/null
sudo chmod 440 /etc/sudoers.d/passwd-tries
sudo sed -i 's/^# *deny = .*/deny = 10/' /etc/security/faillock.conf

# Increase lockout limit, decrease timeout
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"

# Ensure lockout limit is reset on restart
sudo sed -i '/pam_faillock\.so preauth/d' /etc/pam.d/sddm-autologin
sudo sed -i '/auth.*pam_permit\.so/a auth        required    pam_faillock.so authsucc' /etc/pam.d/sddm-autologin

# Increase file watchers for dev tools
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-file-watchers.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1

# Disable USB autosuspend
if [[ ! -f /etc/modprobe.d/disable-usb-autosuspend.conf ]]; then
  echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null
fi

# Ignore power button (handled by WM menu instead)
sudo sed -i 's/.*HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

sudo systemctl daemon-reload
