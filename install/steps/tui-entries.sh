#!/usr/bin/env bash
# tui-entries.sh — Desktop entries for TUI apps (walker + Hyprland windowrules)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Configure ─────────────────────────────────────────────────────────────────

# Creates .desktop entries so TUI apps appear in walker and launch in a terminal
# with the right size and float/tile behaviour via Hyprland windowrules.
#
# app-id pattern:
#   TUI.float → Hyprland windowrule floats the window at a fixed size
#   TUI.tile  → Hyprland windowrule tiles it normally
#
# Requires: xdg-terminal-exec (from shell.sh) and the relevant TUI tool installed

DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

info "Creating TUI desktop entries"

create_tui_desktop() {
  local name="$1" exec_cmd="$2" window_style="$3" icon="$4"
  cat > "$DESKTOP_DIR/${name}.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=$name
Comment=$name
Exec=xdg-terminal-exec --app-id=TUI.$window_style -e $exec_cmd
Terminal=false
Type=Application
Icon=$icon
StartupNotify=true
EOF
  chmod +x "$DESKTOP_DIR/${name}.desktop"
}

create_tui_desktop "System Monitor"  "btop"                              float utilities-system-monitor
create_tui_desktop "Disk Usage"      "bash -c 'dust -r; read -n 1 -s'"  float drive-harddisk
create_tui_desktop "Lazygit"         "lazygit"                           tile  applications-vcs
create_tui_desktop "WiFi"            "impala"                            float network-wireless
create_tui_desktop "Audio Mixer"     "wiremix"                           float audio-volume-high
create_tui_desktop "Lazydocker"      "lazydocker"                        tile  com.docker.docker

update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
ok "TUI desktop entries created"
