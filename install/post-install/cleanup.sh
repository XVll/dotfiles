#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Cleaning up"

# Remove orphaned packages (installed as dependencies, no longer needed)
ORPHANS=$(paru -Qdtq 2>/dev/null || true)
if [ -n "$ORPHANS" ]; then
  echo "$ORPHANS" | paru -Rns --noconfirm -
  ok "Orphans removed"
else
  ok "No orphans to remove"
fi

# Clear paru cache
paru -Scc --noconfirm 2>/dev/null || true

ok "Cleanup done"
