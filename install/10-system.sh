#!/bin/bash

# System domain: systemd tweaks, sysctl, kernel modules, phone plumbing

pkg-add kernel-modules-hook exfatprogs

# iPhone plumbing: required for any iOS access (USB mount via gvfs-afc + USB tethering)
pkg-add usbmuxd               # USB <-> iOS multiplexer daemon (auto-starts as service)
pkg-add libimobiledevice      # C library for iOS protocols — gvfs-afc links against this

cd "$DOTFILES" && stow -d stow -t "$HOME" system

# Faster shutdown systemd configs
sudo mkdir -p /etc/systemd/system.conf.d
sudo cp "$DOTFILES/system/systemd/faster-shutdown.conf" /etc/systemd/system.conf.d/10-faster-shutdown.conf
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo cp ~/.config/systemd/user@.service.d/faster-shutdown.conf /etc/systemd/system/user@.service.d/

# Kernel modules hook
sudo systemctl enable --now linux-modules-cleanup.service

# Increase file watchers for dev tools
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-file-watchers.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1

sudo systemctl daemon-reload
