#!/usr/bin/env bash
# Shared helpers — sourced by every install phase script

LOG_FILE="/var/log/install.log"

info()      { echo "==> $*"; }
ok()        { echo " ✓  $*"; }
err()       { echo " ✗  $*" >&2; exit 1; }
need_root() { [ "$(id -u)" -eq 0 ] || err "This step must run as root"; }
need_user() { [ "$(id -u)" -ne 0 ] || err "This step must run as your user, not root"; }

# Run a script and log all output with timestamps
# Usage: run_logged install/packaging/wayland.sh
run_logged() {
  local script="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script" | sudo tee -a "$LOG_FILE" > /dev/null
  bash -c "source '$script'" >> "$LOG_FILE" 2>&1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Done: $script" | sudo tee -a "$LOG_FILE" > /dev/null
}

# Trap any error and show which line failed
trap 'err "Failed at line $LINENO — check $LOG_FILE for details"' ERR
