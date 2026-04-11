#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_root

info "Creating user"

useradd -m -G wheel,audio,video,storage -s /bin/bash fx
passwd fx

# Passwordless sudo for wheel group
sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

ok "User fx created"
