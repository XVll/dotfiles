#!/bin/bash

# Launcher domain: walker, elephant

pkg-add omarchy-walker libqalculate

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" launcher

# Ensure walker autostart and restart systemd config are active
systemctl --user daemon-reload

# Enable elephant service (walker launcher backend)
elephant service enable
systemctl --user start elephant.service

# Pacman hook to restart walker after updates
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/walker-restart.hook > /dev/null << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = walker
Target = walker-debug
Target = elephant*

[Action]
Description = Restarting Walker services after system update
When = PostTransaction
Exec = $OMARCHY_PATH/bin/omarchy-restart-walker
EOF
