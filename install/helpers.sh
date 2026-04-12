#!/usr/bin/env bash
# Shared helpers — sourced by every install phase script

info()      { echo "==> $*"; }
ok()        { echo " ✓  $*"; }
err()       { echo " ✗  $*" >&2; exit 1; }
need_user() { [ "$(id -u)" -ne 0 ] || err "This step must run as your user, not root"; }

# Trap any error and show which line failed
trap 'err "Failed at line $LINENO"' ERR
