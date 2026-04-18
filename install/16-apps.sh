#!/bin/bash

# Apps domain: GUI + TUI apps, file managers, media, mime handlers, webapps

# File managers
pkg-add yazi                                  # TUI file manager
pkg-add nautilus nautilus-python python-gobject sushi ffmpegthumbnailer

# Notes / productivity
pkg-add obsidian onlyoffice-desktopeditors evince pinta

# Media
pkg-add mpv imv obs-studio imagemagick

# Communication
pkg-add localsend

# Password / secrets
pkg-add 1password-beta 1password-cli

# GNOME utilities
pkg-add gnome-calculator gnome-disk-utility

cd "$DOTFILES" && stow -d stow -t "$HOME" apps

# Icons come from the dashboardicons CDN; webapp-install/tui-install download
# into ~/.local/share/applications/icons/ on first run.
ICONS="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg"

# Web apps
webapp-install "WhatsApp"    https://web.whatsapp.com/         "$ICONS/whatsapp.svg"
webapp-install "Google Maps" https://maps.google.com           "$ICONS/google-maps.svg"
webapp-install "YouTube"     https://youtube.com/              "$ICONS/youtube.svg"
webapp-install "GitHub"      https://github.com/               "$ICONS/github.svg"
webapp-install "X"           https://x.com/                    "$ICONS/x-light.svg"
webapp-install "Figma"       https://figma.com/                "$ICONS/figma.svg"
webapp-install "Discord"     https://discord.com/channels/@me  "$ICONS/discord.svg"

# TUIs
tui-install "Files"      "yazi"                             tile  "$ICONS/yazi.svg"
tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'"  float "$ICONS/harddisk.svg"
tui-install "Docker"     "lazydocker"                       tile  "$ICONS/docker.svg"

# MIME type defaults
update-desktop-database ~/.local/share/applications

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
xdg-mime default mpv.desktop video/x-flv
xdg-mime default mpv.desktop video/x-ms-wmv
xdg-mime default mpv.desktop video/mpeg
xdg-mime default mpv.desktop video/ogg
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/3gpp
xdg-mime default mpv.desktop video/3gpp2
xdg-mime default mpv.desktop video/x-ms-asf
xdg-mime default mpv.desktop video/x-ogm+ogg
xdg-mime default mpv.desktop video/x-theora+ogg
xdg-mime default mpv.desktop application/ogg

xdg-mime default nvim.desktop text/plain
xdg-mime default nvim.desktop text/english
xdg-mime default nvim.desktop text/x-makefile
xdg-mime default nvim.desktop text/x-c++hdr
xdg-mime default nvim.desktop text/x-c++src
xdg-mime default nvim.desktop text/x-chdr
xdg-mime default nvim.desktop text/x-csrc
xdg-mime default nvim.desktop text/x-java
xdg-mime default nvim.desktop text/x-moc
xdg-mime default nvim.desktop text/x-pascal
xdg-mime default nvim.desktop text/x-tcl
xdg-mime default nvim.desktop text/x-tex
xdg-mime default nvim.desktop application/x-shellscript
xdg-mime default nvim.desktop text/x-c
xdg-mime default nvim.desktop text/x-c++
xdg-mime default nvim.desktop application/xml
xdg-mime default nvim.desktop text/xml
