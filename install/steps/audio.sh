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
# wiremix = TUI audio mixer — visual routing between PipeWire apps and devices
info "Audio"
paru -S --needed --noconfirm \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber \
  gst-plugin-pipewire \
  pamixer \
  alsa-utils \
  wiremix
ok "Audio installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" wiremix

# ── Configure ─────────────────────────────────────────────────────────────────

# Enable PipeWire user services — they start on login via systemd user session
# Must be user services (--user), not system services
info "Enabling PipeWire services"
systemctl --user enable pipewire pipewire-pulse wireplumber
ok "PipeWire stack enabled (starts on next login)"
