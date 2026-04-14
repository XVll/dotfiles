#!/usr/bin/env bash
# audio.sh — PipeWire audio stack

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# pipewire = modern audio/video server — replaces PulseAudio and JACK
# pipewire-pulse = PulseAudio drop-in replacement — existing apps link against
#                 libpulse and see no difference
# pipewire-alsa = ALSA compatibility — routes ALSA apps through PipeWire
# wireplumber = session/policy manager — decides how audio flows between devices
#               and apps (replaces pipewire-media-session)
# gst-plugin-pipewire = GStreamer PipeWire plugin — video conferencing needs this
# pamixer = CLI volume control — used by Hyprland keybinds for raise/lower/mute
# alsa-utils = ALSA tools (amixer, aplay, speaker-test) — useful for debugging
# pulsemixer = TUI audio mixer — volumes, default device, mute per-app
# playerctl = media player controller — used by keybinds for play/pause/next/prev
info "Audio"
paru -S --needed --noconfirm \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber \
  gst-plugin-pipewire \
  pamixer \
  alsa-utils \
  pulsemixer \
  playerctl
ok "Audio installed"

# ── Configure ─────────────────────────────────────────────────────────────────

# Enable PipeWire user services — they start on login via systemd user session
# Must be user services (--user), not system services
info "Enabling PipeWire services"
systemctl --user enable pipewire pipewire-pulse wireplumber
ok "PipeWire stack enabled (starts on next login)"
