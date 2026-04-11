#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Re-enabling mkinitcpio hooks"

# Restore the hooks we disabled in preflight and rebuild initramfs once
if [[ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled ]]; then
  sudo mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled \
          /usr/share/libalpm/hooks/90-mkinitcpio-install.hook
fi

if [[ -f /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled ]]; then
  sudo mv /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled \
          /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook
fi

# Rebuild initramfs once for all installed kernels
sudo mkinitcpio -P

ok "mkinitcpio hooks restored and initramfs rebuilt"

info "Removing orphaned packages"

ORPHANS=$(paru -Qdtq 2>/dev/null || true)
if [ -n "$ORPHANS" ]; then
  echo "$ORPHANS" | paru -Rns --noconfirm -
  ok "Orphans removed"
else
  ok "No orphans"
fi

paru -Scc --noconfirm 2>/dev/null || true
ok "Package cache cleared"
