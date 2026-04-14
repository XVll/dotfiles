#!/usr/bin/env bash
# audio.sh — PipeWire audio stack

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# pipewire       = modern audio/video server — replaces PulseAudio and JACK
# pipewire-pulse = PulseAudio drop-in replacement — apps link against libpulse
# pipewire-alsa  = ALSA compatibility — routes ALSA apps through PipeWire
# pipewire-jack  = JACK compatibility — pro audio apps (Ardour, REAPER) work
# wireplumber    = session/policy manager — decides how audio flows between
#                  devices and apps (replaces pipewire-media-session)
# gst-plugin-pipewire = GStreamer PipeWire plugin — video conferencing needs this
# pamixer        = CLI volume control — used by Hyprland keybinds
# playerctl      = media player controller — keybinds for play/pause/next/prev
# wiremix        = TUI PipeWire mixer — per-device/stream volume control
info "Audio"
paru -S --needed --noconfirm \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber \
  gst-plugin-pipewire \
  pamixer \
  playerctl \
  wiremix
ok "Audio installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
info "Stowing wiremix config"
"$DOTFILES_DIR/stow.sh" wiremix
ok "WireMix config stowed"

# ── Configure ─────────────────────────────────────────────────────────────────

# Enable PipeWire user services — they start on login via systemd user session
# Must be user services (--user), not system services
info "Enabling PipeWire services"
systemctl --user enable pipewire pipewire-pulse wireplumber
ok "PipeWire stack enabled (starts on next login)"
