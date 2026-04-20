#!/bin/bash

# Apps domain: GUI + TUI apps, file managers, media, mime handlers, webapps

# File managers
pkg-add yazi                                  # TUI file manager

# Nautilus + extensions + gvfs backends for network/phone browsing
pkg-add nautilus              # GUI file manager
pkg-add nautilus-python       # Python extension API (used by localsend extension)
pkg-add python-gobject        # Python GTK bindings — required by nautilus-python
pkg-add sushi                 # Spacebar quick-preview in nautilus
pkg-add ffmpegthumbnailer     # Video thumbnails in nautilus
pkg-add gvfs-mtp              # Android USB (MTP) mount shown in nautilus sidebar
pkg-add gvfs-nfs              # NFS shares in nautilus Network pane (uses libnfs, userspace)
pkg-add gvfs-smb              # SMB/Windows shares in nautilus Network pane (uses smbclient, userspace)
pkg-add gvfs-afc              # iPhone (Apple File Conduit) mount in nautilus sidebar — needs usbmuxd

# Lazy-unmount gvfs-fuse mounts pre-suspend so the kernel freeze phase
# doesn't hang on FUSE tasks; restart gvfs-daemon post-resume.
# See: https://github.com/systemd/systemd/issues/40574
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root \
  "$DOTFILES/system/systemd/system-sleep/unmount-fuse" \
  /usr/lib/systemd/system-sleep/

# Notes / productivity
pkg-add obsidian onlyoffice-bin evince pinta

# Media
pkg-add mpv imv obs-studio imagemagick

# Communication
pkg-add kdeconnect            # Phone <-> Linux: clipboard, files, notifications (UDP/TCP 1714-1764)

# Password / secrets
pkg-add 1password-beta 1password-cli

# GNOME utilities
pkg-add gnome-calculator gnome-disk-utility

cd "$DOTFILES" && stow -d stow -t "$HOME" apps

# Icons come from the dashboardicons CDN; webapp-install/tui-install download
# into ~/.local/share/applications/icons/ on first run.
ICONS="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png"

# Web apps
webapp-install "WhatsApp"    https://web.whatsapp.com/         "$ICONS/whatsapp.png"
webapp-install "Google Maps" https://maps.google.com           "$ICONS/google-maps.png"
webapp-install "YouTube"     https://youtube.com/              "$ICONS/youtube.png"
webapp-install "GitHub"      https://github.com/               "$ICONS/github.png"
webapp-install "X"           https://x.com/                    "$ICONS/x-light.png"
webapp-install "Figma"       https://figma.com/                "$ICONS/figma.png"
webapp-install "Discord"     https://discord.com/channels/@me  "$ICONS/discord.png"

# TUIs
pkg-add gum fzf paru                                # deps for `apps` TUI
tui-install "Apps"       "apps"                             float "$ICONS/arch-linux.png"
tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'"  float "$ICONS/terminal.png"
tui-install "Docker"     "lazydocker"                       tile  "$ICONS/docker.png"

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
