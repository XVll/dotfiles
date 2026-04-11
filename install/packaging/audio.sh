#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

info "Audio"

# pipewire = modern audio/video server, replaces PulseAudio and JACK
# pipewire-pulse = PulseAudio drop-in replacement — existing apps see no difference
# pipewire-alsa = ALSA compatibility layer
# wireplumber = session/policy manager — decides how audio flows between apps and hardware
paru -S --needed --noconfirm \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber

ok "Audio installed"
