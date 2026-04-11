#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

echo
echo "  ================================"
echo "   Installation complete!"
echo "   Reboot to start Hyprland."
echo "  ================================"
echo
read -rp "  Reboot now? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  sudo reboot
fi
