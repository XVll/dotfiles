#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

info "Disabling mkinitcpio hooks during install"

# Without this, every kernel-related package triggers an initramfs rebuild.
# On a fresh install that can happen 10+ times — each rebuild takes 30-60s.
# We disable the hooks now and re-enable them in post-install, then rebuild once.

if [[ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook ]]; then
  sudo mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook \
          /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled
fi

if [[ -f /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook ]]; then
  sudo mv /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook \
          /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled
fi

ok "mkinitcpio hooks disabled (will re-enable in post-install)"
