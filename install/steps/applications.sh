#!/usr/bin/env bash
# applications.sh — GUI applications

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# chromium = web browser
# obsidian = Markdown knowledge base / note-taking
# signal-desktop = Signal encrypted messenger
# spotify = Spotify music streaming client
# libreoffice-fresh = full office suite (Writer, Calc, Impress)
# evince = PDF and document viewer (also handles DJVU, PS, XPS)
# kdenlive = video editor
# obs-studio = screen recorder and streaming
# gnome-calculator = calculator GUI
# gnome-disk-utility = disk management GUI — format, partition, SMART checks
# pinta = simple image editor, similar to MS Paint
# localsend = LAN file sharing between devices
# typora = WYSIWYG Markdown editor (paid app)
# xournalpp = PDF annotation and digital note-taking
# imv = lightweight image viewer — opens images instantly from terminal/file manager
# mpv = video player — plays any format with minimal UI
# nautilus = GNOME file manager — for when you need a GUI file browser
# nautilus-python = Python extension support for nautilus
# ffmpegthumbnailer = video thumbnails in nautilus
# sushi = quick file preview in nautilus (spacebar)
# yaru-icon-theme = Ubuntu Yaru icon set
# gpu-screen-recorder = GPU-accelerated screen recorder — simpler than OBS
# 1password-beta = 1Password password manager
# 1password-cli = 1Password CLI — pair with 1password-beta
info "Applications"
paru -S --needed --noconfirm \
  chromium \
  obsidian \
  signal-desktop \
  spotify \
  libreoffice-fresh \
  evince \
  kdenlive \
  obs-studio \
  gnome-calculator \
  gnome-disk-utility \
  pinta \
  localsend \
  typora \
  xournalpp \
  imv \
  mpv \
  nautilus \
  nautilus-python \
  ffmpegthumbnailer \
  sushi \
  yaru-icon-theme \
  gpu-screen-recorder \
  1password-beta \
  1password-cli
ok "Applications installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" imv applications

# ── Configure ─────────────────────────────────────────────────────────────────

# Register default apps for file types — xdg-open, file managers, and link
# clicks will use these. update-desktop-database rebuilds the MIME cache first.
info "Setting default applications"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
xdg-mime default org.gnome.Nautilus.desktop inode/directory
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff
xdg-mime default org.gnome.Evince.desktop application/pdf
xdg-settings set default-web-browser chromium.desktop
xdg-mime default chromium.desktop x-scheme-handler/http
xdg-mime default chromium.desktop x-scheme-handler/https
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default nvim.desktop text/plain
xdg-mime default nvim.desktop application/x-shellscript
xdg-mime default nvim.desktop application/xml
ok "Default applications set"
