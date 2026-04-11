#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

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
