#!/bin/bash

# Apps domain: lazygit, opencode, mise, btop, fastfetch, imv, nautilus, xournalpp, typora

pkg-add lazygit btop fastfetch imv nautilus nautilus-python python-gobject \
  xournalpp typora mise obsidian localsend \
  1password-beta 1password-cli evince gnome-calculator gnome-disk-utility \
  gnome-keyring gnome-themes-extra imagemagick kdenlive libreoffice-fresh \
  mpv nvim obs-studio pinta signal-desktop spotify sushi \
  ffmpegthumbnailer dust python-terminaltexteffects impala \
  visual-studio-code-bin

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" apps

# Application icons (used by webapp and TUI .desktop entries)
ICON_DIR="$HOME/.local/share/applications/icons"
mkdir -p "$ICON_DIR"
cp ~/.local/share/omarchy/applications/icons/*.png "$ICON_DIR/"

# Web apps
omarchy-webapp-install "WhatsApp" https://web.whatsapp.com/ WhatsApp.png
omarchy-webapp-install "Google Maps" https://maps.google.com "Google Maps.png"
omarchy-webapp-install "ChatGPT" https://chatgpt.com/ ChatGPT.png
omarchy-webapp-install "YouTube" https://youtube.com/ YouTube.png
omarchy-webapp-install "GitHub" https://github.com/ GitHub.png
omarchy-webapp-install "X" https://x.com/ X.png
omarchy-webapp-install "Figma" https://figma.com/ Figma.png
omarchy-webapp-install "Discord" https://discord.com/channels/@me Discord.png

# TUIs
omarchy-tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'" float "$ICON_DIR/Disk Usage.png"
omarchy-tui-install "Docker" "lazydocker" tile "$ICON_DIR/Docker.png"

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

# VSCode configuration
mkdir -p ~/.vscode ~/.config/Code/User
cat > ~/.vscode/argv.json << 'ARGVEOF'
{
  "password-store":"gnome-libsecret"
}
ARGVEOF
printf '{\n  "update.mode": "none"\n}\n' > ~/.config/Code/User/settings.json
omarchy-theme-set-vscode

# Install mise tools
mise install

# Note: the `nvim` package is installed above, but the editor config is not
# managed by this installer. Bring your own LazyVim (or other) config under
# ~/.config/nvim (to be stowed later).
#
# To hook your nvim into Omarchy's theme-sync system, add this single file to
# your LazyVim plugin specs:
#
#     -- ~/.config/nvim/lua/plugins/omarchy-theme.lua
#     return dofile(vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua"))
#
# That loads whichever theme is currently set by `omarchy-theme-set` as a
# LazyVim plugin spec. Restart nvim or run `:Lazy reload` after a theme change
# to pick it up (omarchy-theme-set does not hot-reload running nvim instances).
