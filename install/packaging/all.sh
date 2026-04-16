# Packages
mapfile -t packages < <(grep -vE '^(#|$)' "$OMARCHY_INSTALL/omarchy-base.packages")
pkg-add "${packages[@]}"

# Application icons (consumed by the webapp and TUI .desktop entries below)
ICON_DIR="$HOME/.local/share/applications/icons"
mkdir -p "$ICON_DIR"
cp ~/.local/share/omarchy/applications/icons/*.png "$ICON_DIR/"

# Web apps
omarchy-webapp-install "HEY" https://app.hey.com HEY.png "omarchy-webapp-handler-hey %u" "x-scheme-handler/mailto"
omarchy-webapp-install "Basecamp" https://launchpad.37signals.com Basecamp.png
omarchy-webapp-install "WhatsApp" https://web.whatsapp.com/ WhatsApp.png
omarchy-webapp-install "Google Photos" https://photos.google.com/ "Google Photos.png"
omarchy-webapp-install "Google Contacts" https://contacts.google.com/ "Google Contacts.png"
omarchy-webapp-install "Google Messages" https://messages.google.com/web/conversations "Google Messages.png"
omarchy-webapp-install "Google Maps" https://maps.google.com "Google Maps.png"
omarchy-webapp-install "ChatGPT" https://chatgpt.com/ ChatGPT.png
omarchy-webapp-install "YouTube" https://youtube.com/ YouTube.png
omarchy-webapp-install "GitHub" https://github.com/ GitHub.png
omarchy-webapp-install "X" https://x.com/ X.png
omarchy-webapp-install "Figma" https://figma.com/ Figma.png
omarchy-webapp-install "Discord" https://discord.com/channels/@me Discord.png

omarchy-webapp-install "Fizzy" https://app.fizzy.do/ Fizzy.png

# TUIs
omarchy-tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'" float "$ICON_DIR/Disk Usage.png"
omarchy-tui-install "Docker" "lazydocker" tile "$ICON_DIR/Docker.png"

# Mise tools (node + npm CLIs from ~/.config/mise/config.toml)
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
