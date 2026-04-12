#!/usr/bin/env bash
# packages.sh — all packages in one place, grouped by category
#
# Uncomment a section when you're ready to install it, then run install.sh.
# Each section is independent — you can install them in any order.

source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
need_user

# ── System tools ──────────────────────────────────────────────────────────────
# Stow: (none — system-level packages, no dotfiles)
# btrfs-progs = btrfs CLI tools — balance, scrub, snapshot management from terminal
# snapper = btrfs snapshot manager — automatic snapshots before upgrades, manual rollback
# zram-generator = compressed RAM-based swap — faster than disk swap
# power-profiles-daemon = battery power profiles (balanced/performance/power-save)
# plymouth = animated boot splash screen — optional, purely cosmetic
# tzupdate = auto-detect and set timezone from IP geolocation
# info "System tools"
# paru -S --needed --noconfirm \
#   btrfs-progs \
#   snapper \
#   zram-generator \
#   power-profiles-daemon \
#   plymouth \
#   tzupdate
# ok "System tools installed"

# ── Wayland session ───────────────────────────────────────────────────────────
# Stow: ./stow.sh hypr uwsm xdg
# hyprland = tiling window manager (Wayland compositor)
# uwsm = Universal Wayland Session Manager — proper env setup, replaces exec-once hacks
# sddm = login/display manager
# xdg-desktop-portal-hyprland = screenshare + file picking through Hyprland
# xdg-desktop-portal-gtk = fallback portal for GTK apps
# egl-wayland = EGL platform support — lets OpenGL/EGL apps render on Wayland natively
# gtk4-layer-shell = GTK4 layer-shell protocol — needed by some Wayland surface apps
# qt5-wayland + qt6-wayland = Qt apps render natively on Wayland instead of XWayland
# vulkan-intel = Intel Vulkan driver — needed for GPU-accelerated compositing on Hyprland
# intel-media-driver = Intel VA-API driver — hardware video decode (H264/HEVC/AV1)
# libva-intel-driver = legacy Intel VA-API — older codec support alongside the modern driver
# hyprland-guiutils = GUI settings and utilities for Hyprland
# info "Wayland session"
# paru -S --needed --noconfirm \
#   hyprland \
#   uwsm \
#   sddm \
#   xdg-desktop-portal-hyprland \
#   xdg-desktop-portal-gtk \
#   egl-wayland \
#   gtk4-layer-shell \
#   qt5-wayland \
#   qt6-wayland \
#   vulkan-intel \
#   intel-media-driver \
#   libva-intel-driver \
#   hyprland-guiutils
# ok "Wayland session installed"
#
# Configure:
# # Sync keyboard layout from /etc/vconsole.conf into hypr/input.conf so TTY
# # and Wayland session use the same layout after install.
# vconsole="/etc/vconsole.conf"
# hyprconf="$HOME/.config/hypr/input.conf"
# if [ -f "$vconsole" ] && [ -f "$hyprconf" ]; then
#   if grep -q '^XKBLAYOUT=' "$vconsole"; then
#     layout=$(grep '^XKBLAYOUT=' "$vconsole" | cut -d= -f2 | tr -d '"')
#     sed -i "/^[[:space:]]*kb_options *=/i\  kb_layout = $layout" "$hyprconf"
#   fi
#   if grep -q '^XKBVARIANT=' "$vconsole"; then
#     variant=$(grep '^XKBVARIANT=' "$vconsole" | cut -d= -f2 | tr -d '"')
#     sed -i "/^[[:space:]]*kb_options *=/i\  kb_variant = $variant" "$hyprconf"
#   fi
# fi
# ok "Keyboard layout synced"
#
# # XCompose: CapsLock is the compose key (set in hypr/input.conf).
# # compose+space+n types your name, compose+space+e types your email.
# tee "$HOME/.XCompose" >/dev/null <<EOF
# # Compose key: CapsLock
# <Multi_key> <space> <n> : "$GIT_NAME"
# <Multi_key> <space> <e> : "$GIT_EMAIL"
# EOF
# ok "XCompose written"

# ── Terminal ──────────────────────────────────────────────────────────────────
# Stow: ./stow.sh ghostty
# ghostty = GPU-accelerated terminal, available in CachyOS repo
# info "Terminal"
# paru -S --needed --noconfirm ghostty
# ok "Terminal installed"

# ── Shell + tools ─────────────────────────────────────────────────────────────
# Stow: ./stow.sh zsh starship
# Configure: sudo usermod -s /bin/zsh "$USER" && sudo updatedb
# zsh = better completion and scripting than bash
# starship = fast cross-shell prompt with git/language context
# eza = modern ls with icons and colors
# bat = cat with syntax highlighting and line numbers
# zoxide = smart cd — learns your most-visited dirs, jump with z
# fzf = fuzzy finder — powers Ctrl+R history search and more
# zsh-autosuggestions = grey ghost text from history as you type
# zsh-syntax-highlighting = command coloring before you hit enter
# wget = HTTP downloader — curl alternative, needed by many scripts
# bash-completion = tab completion scripts — many CLI tools install completions here
# less = standard terminal pager — man pages and many tools depend on it
# man-db = man page database — documentation for system commands and installed tools
# unzip = ZIP archive extraction — surprisingly many things need this
# xdg-terminal-exec = standard terminal opener — file managers use this to open a terminal
# tldr = simplified man pages with real-world examples — quicker than man for common usage
# plocate = fast file search — the `locate` command, finds files instantly from a database
# whois = domain and IP lookup tool — useful for quick network investigation
# dust = disk usage analyzer — visual tree of what's eating your disk space, better than du
# expac = pacman query tool — query package info, useful in maintenance scripts
# gum = pretty interactive prompts for shell scripts
# info "Shell + tools"
# paru -S --needed --noconfirm \
#   zsh \
#   starship \
#   eza \
#   bat \
#   zoxide \
#   fzf \
#   zsh-autosuggestions \
#   zsh-syntax-highlighting \
#   wget \
#   bash-completion \
#   less \
#   man-db \
#   unzip \
#   xdg-terminal-exec \
#   tldr \
#   plocate \
#   whois \
#   dust \
#   expac \
#   gum
# ok "Shell + tools installed"
#
# Configure:
# # Set zsh as default shell — usermod works non-interactively unlike chsh
# sudo usermod -s /bin/zsh "$USER"
# ok "Default shell set to zsh (re-login to take effect)"
# # Build plocate's file index — the nightly timer hasn't run yet on a fresh install
# sudo updatedb
# ok "Locate database built"

# ── Status bar ────────────────────────────────────────────────────────────────
# Stow: ./stow.sh waybar
# waybar = most popular Hyprland-compatible status bar, highly configurable
# info "Status bar"
# paru -S --needed --noconfirm waybar
# ok "Status bar installed"

# ── App launcher ──────────────────────────────────────────────────────────────
# Stow: ./stow.sh walker
# walker = modern Wayland launcher with fuzzy search, available as pre-built binary
# info "App launcher"
# paru -S --needed --noconfirm walker-bin
# ok "App launcher installed"

# ── Hyprland ecosystem ────────────────────────────────────────────────────────
# Stow: ./stow.sh hypridle hyprlock hyprpaper swayosd
# hypridle = inactivity daemon — watches idle time and triggers actions (e.g. lock after N min)
# hyprlock = GPU-accelerated lock screen
# hyprpaper = wallpaper daemon — efficient, supports per-monitor images
# hyprpicker = color picker — click anywhere on screen to get the hex value
# hyprsunset = blue light filter — reduces screen temperature in the evening
# swayosd = on-screen display for volume/brightness — shows a popup when you press those keys
# info "Hyprland ecosystem"
# paru -S --needed --noconfirm \
#   hypridle \
#   hyprlock \
#   hyprpaper \
#   hyprpicker \
#   hyprsunset \
#   swayosd
# ok "Hyprland ecosystem installed"

# ── Notifications ─────────────────────────────────────────────────────────────
# Stow: ./stow.sh mako
# mako = lightweight Wayland notification daemon (replaces dunst on Wayland)
# info "Notifications"
# paru -S --needed --noconfirm mako
# ok "Notifications installed"

# ── Audio ─────────────────────────────────────────────────────────────────────
# Stow: ./stow.sh wiremix
# pipewire = modern audio/video server, replaces PulseAudio and JACK
# pipewire-pulse = PulseAudio drop-in replacement — existing apps see no difference
# pipewire-alsa = ALSA compatibility layer
# wireplumber = session/policy manager — decides how audio flows between apps and hardware
# gst-plugin-pipewire = GStreamer PipeWire plugin — video conferencing apps need this
# pamixer = CLI volume control — Hyprland keybinds call this to raise/lower/mute volume
# alsa-utils = ALSA tools (amixer, aplay, speaker-test) — useful for diagnosing audio issues
# wiremix = TUI audio mixer for PipeWire — visual way to route audio between apps and devices
# info "Audio"
# paru -S --needed --noconfirm \
#   pipewire \
#   pipewire-pulse \
#   pipewire-alsa \
#   wireplumber \
#   gst-plugin-pipewire \
#   pamixer \
#   alsa-utils \
#   wiremix
# ok "Audio installed"

# ── Fonts ─────────────────────────────────────────────────────────────────────
# Stow: ./stow.sh fontconfig
# ttf-jetbrains-mono-nerd = primary coding font — ligatures + Nerd Font icons for waybar/starship
# noto-fonts = broad unicode coverage — fallback for anything JetBrainsMono doesn't cover
# noto-fonts-emoji = emoji support
# noto-fonts-cjk = Chinese/Japanese/Korean characters — without this CJK text renders as boxes
# fontconfig = font configuration utility — controls font rendering, hinting, substitution
# ttf-ia-writer = iA Writer typeface (Mono/Duo/Quattro) — clean reading/writing font
# info "Fonts"
# paru -S --needed --noconfirm \
#   ttf-jetbrains-mono-nerd \
#   noto-fonts \
#   noto-fonts-emoji \
#   noto-fonts-cjk \
#   fontconfig \
#   ttf-ia-writer
# fc-cache -fv
# ok "Fonts installed"

# ── Utilities ─────────────────────────────────────────────────────────────────
# Stow: ./stow.sh wofi
# polkit-gnome = GUI popup for privilege escalation (sudo dialogs in GUI apps)
# grim = Wayland screenshot tool — captures full screen or a region
# slurp = region selector — used together with grim/satty to pick a screen area
# satty = screenshot annotation — draw arrows, text, boxes on screenshots after capture
# wl-clipboard = copy/paste on Wayland (replaces xclip/xsel)
# brightnessctl = screen brightness control via keybinds
# playerctl = media control — play/pause/next/prev via keybinds, works with any MPRIS player
# iwd = WiFi daemon — manages connections and DHCP natively
# impala = TUI frontend for iwd — launch via keybind to connect to WiFi networks
# jq = JSON processor — used constantly in scripts and by many CLI tools
# imagemagick = image processing — used by wallpaper tools, thumbnails, many scripts
# inetutils = basic network tools (ping, hostname, ftp) — some are missing by default on Arch
# ufw = uncomplicated firewall — simple rules-based firewall, sensible default protection
# gnome-keyring = credential storage daemon — browsers, gh CLI, and many apps store secrets here
# gnome-themes-extra = GTK themes including Adwaita Dark — GTK apps look wrong without this
# libsecret = secret storage library — the API that apps use to talk to gnome-keyring
# avahi = mDNS daemon — makes `hostname.local` reachable on your local network
# nss-mdns = mDNS resolver — pairs with avahi so the system can resolve .local hostnames
# wireless-regdb = wireless regulatory database — sets correct WiFi channel/power limits
# webp-pixbuf-loader = WebP image support for GTK apps — without this WebP files show as broken
# swaybg = simple wallpaper setter — placeholder until hyprpaper config is ready
# bolt = Thunderbolt device manager — optional, only if you use Thunderbolt/USB4 peripherals
# gvfs-mtp = MTP support — optional, only to browse Android phones as a filesystem
# gvfs-nfs = NFS support — optional, only if you mount NFS network shares
# gvfs-smb = Samba/SMB support — optional, only if you mount Windows/Samba shares
# bluetui = Bluetooth TUI manager — optional, only if you use Bluetooth devices
# kvantum-qt5 = Qt5 theme engine — optional, only if you want custom Qt app theming
# exfatprogs = ExFAT filesystem tools — needed to read/write ExFAT USB drives
# fcitx5 = input method framework — optional, only for CJK input
# fcitx5-gtk = GTK support for fcitx5 — optional, pair with fcitx5
# fcitx5-qt = Qt support for fcitx5 — optional, pair with fcitx5
# xmlstarlet = XML processing CLI — optional, only if you work with XML files in scripts
# info "Utilities"
# paru -S --needed --noconfirm \
#   polkit-gnome \
#   grim \
#   slurp \
#   satty \
#   wl-clipboard \
#   brightnessctl \
#   playerctl \
#   iwd \
#   impala \
#   jq \
#   imagemagick \
#   inetutils \
#   ufw \
#   gnome-keyring \
#   gnome-themes-extra \
#   libsecret \
#   avahi \
#   nss-mdns \
#   wireless-regdb \
#   webp-pixbuf-loader \
#   swaybg \
#   bolt \
#   gvfs-mtp \
#   gvfs-nfs \
#   gvfs-smb \
#   bluetui \
#   kvantum-qt5 \
#   exfatprogs \
#   fcitx5 \
#   fcitx5-gtk \
#   fcitx5-qt \
#   xmlstarlet
# ok "Utilities installed"

# ── Editor ────────────────────────────────────────────────────────────────────
# Stow: ./stow.sh nvim
# neovim = vim-based modal editor (we use LazyVim as config framework)
# ripgrep = grep replacement — required by telescope and fzf-lua plugins inside nvim
# fd = find replacement — required by telescope for file search
# nodejs + npm = JavaScript runtime — Mason (nvim LSP manager) uses these to install LSPs
# clang = C compiler — treesitter parsers compile native binaries, LazyVim needs this
# tree-sitter-cli = treesitter grammar CLI — needed to build/update syntax grammars in nvim
# luarocks = Lua package manager — some neovim plugins require Lua modules via luarocks
# mise = universal version manager (node/python/ruby/go/rust) — manage runtimes per project
# rust = Rust language + cargo — optional, remove if you don't develop in Rust
# ruby = Ruby runtime + gem — optional, remove if you don't develop in Ruby
# dotnet-runtime-9.0 = .NET runtime — optional, remove if you don't run .NET apps
# mariadb-libs = MySQL/MariaDB client libraries — optional, only if you connect to MySQL
# postgresql-libs = PostgreSQL client libraries — optional, only if you connect to Postgres
# python-poetry-core = Poetry build backend — optional, only for Python Poetry projects
# info "Editor"
# paru -S --needed --noconfirm \
#   neovim \
#   ripgrep \
#   fd \
#   nodejs \
#   npm \
#   clang \
#   tree-sitter-cli \
#   luarocks \
#   mise \
#   rust \
#   ruby \
#   dotnet-runtime-9.0 \
#   mariadb-libs \
#   postgresql-libs \
#   python-poetry-core
# ok "Editor installed"
#
# Configure:
# # Set up ~/Work as the dev projects root. mise adds ./bin to PATH inside
# # any project under ~/Work so project-local scripts are immediately available.
# mkdir -p "$HOME/Work/tries"
# cat >"$HOME/Work/.mise.toml" <<'MISE'
# [env]
# _.path = "{{ cwd }}/bin"
# MISE
# mise trust "$HOME/Work/.mise.toml"
# mise use -g node@latest
# ok "~/Work and mise configured"
#
# # powerprofilesctl has a shebang of #!/usr/bin/env python3. When mise is
# # active, env resolves to mise's shim instead of system python3, breaking
# # the tool. Patching to an absolute path fixes it.
# sudo sed -i '/env python3/ c\#!/bin/python3' /usr/bin/powerprofilesctl
# ok "powerprofilesctl shebang fixed"

# ── Git tools ─────────────────────────────────────────────────────────────────
# Stow: ./stow.sh git lazygit
# lazygit = terminal UI for git — stage hunks, resolve conflicts, browse log visually
# git-delta = syntax-highlighted, side-by-side diffs (configured in .gitconfig as pager)
# github-cli = gh CLI — auth, PR review, issue/PR management without leaving the terminal
# info "Git tools"
# paru -S --needed --noconfirm \
#   lazygit \
#   git-delta \
#   github-cli
# ok "Git tools installed"
#
# Configure:
# # Set global git identity — reads GIT_NAME/GIT_EMAIL env vars or prompts
# GIT_NAME="${GIT_NAME:-}"
# GIT_EMAIL="${GIT_EMAIL:-}"
# if [ -z "$GIT_NAME" ];  then read -rp "  Git name: "  GIT_NAME;  fi
# if [ -z "$GIT_EMAIL" ]; then read -rp "  Git email: " GIT_EMAIL; fi
# [ -n "$GIT_NAME" ]  && git config --global user.name  "$GIT_NAME"
# [ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
# ok "Git identity set"

# ── Terminal multiplexer ──────────────────────────────────────────────────────
# Stow: ./stow.sh tmux
# tmux = split terminal into panes/windows, keep sessions alive after disconnect
# info "Terminal multiplexer"
# paru -S --needed --noconfirm tmux
# ok "Terminal multiplexer installed"

# ── Monitoring ────────────────────────────────────────────────────────────────
# Stow: ./stow.sh btop fastfetch
# btop = beautiful resource monitor (CPU/RAM/disk/network) — replaces htop
# fastfetch = system info display shown on terminal login — replaces neofetch
# inxi = detailed system hardware report — very useful when diagnosing hardware issues
# usage = terminal system usage overview — alternative top-level view
# info "Monitoring"
# paru -S --needed --noconfirm \
#   btop \
#   fastfetch \
#   inxi \
#   usage
# ok "Monitoring installed"

# ── Docker ────────────────────────────────────────────────────────────────────
# Stow: (none — Docker is configured by config/all.sh, not dotfiles)
# docker = container runtime — optional, remove if you don't use containers
# docker-buildx = multi-platform build extension for docker — optional, pair with docker
# docker-compose = multi-container orchestration via YAML — optional, pair with docker
# lazydocker = TUI for managing containers, images, volumes — optional, pair with docker
# info "Docker"
# paru -S --needed --noconfirm \
#   docker \
#   docker-buildx \
#   docker-compose \
#   lazydocker
# ok "Docker installed"
#
# Configure:
# # Log rotation (10MB × 5 files per container), DNS through systemd-resolved,
# # socket activation (start on first use, not at boot).
# sudo mkdir -p /etc/docker
# sudo tee /etc/docker/daemon.json >/dev/null <<'JSON'
# {
#     "log-driver": "json-file",
#     "log-opts": { "max-size": "10m", "max-file": "5" },
#     "dns": ["172.17.0.1"],
#     "bip": "172.17.0.1/16"
# }
# JSON
# # Expose systemd-resolved to the Docker bridge so containers can resolve DNS
# sudo mkdir -p /etc/systemd/resolved.conf.d
# printf '[Resolve]\nDNSStubListenerExtra=172.17.0.1\n' \
#   | sudo tee /etc/systemd/resolved.conf.d/20-docker-dns.conf >/dev/null
# sudo systemctl restart systemd-resolved
# # Allow running docker without sudo
# sudo usermod -aG docker "$USER"
# # Prevent Docker from blocking boot if network isn't ready
# sudo mkdir -p /etc/systemd/system/docker.service.d
# sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf >/dev/null <<'UNIT'
# [Unit]
# DefaultDependencies=no
# UNIT
# sudo systemctl daemon-reload
# ok "Docker configured"

# ── Printing ──────────────────────────────────────────────────────────────────
# Stow: (none — no dotfiles for printing)
# cups = UNIX printing system — optional, remove if you don't print
# cups-browsed = auto-discovers network printers — optional, pair with cups
# cups-filters = print filters and backends — optional, pair with cups
# cups-pdf = virtual PDF printer — optional, lets you "print to PDF" from any app
# system-config-printer = printer configuration GUI — optional, pair with cups
# info "Printing"
# paru -S --needed --noconfirm \
#   cups \
#   cups-browsed \
#   cups-filters \
#   cups-pdf \
#   system-config-printer
# ok "Printing installed"

# ── Applications ──────────────────────────────────────────────────────────────
# Stow: ./stow.sh imv applications
# chromium = web browser — optional, choose your preferred browser
# obsidian = Markdown knowledge base / note-taking — optional
# signal-desktop = Signal encrypted messenger — optional
# spotify = Spotify music streaming client — optional
# libreoffice-fresh = full office suite (Writer, Calc, Impress) — optional
# evince = PDF and document viewer — optional but practical, handles PDF/DJVU/PS
# kdenlive = video editor — optional
# obs-studio = screen recorder and streaming software — optional
# gnome-calculator = calculator GUI — optional (bc/qalc work fine in terminal)
# gnome-disk-utility = disk management GUI (format, partition, SMART) — optional
# pinta = simple image editor similar to MS Paint — optional
# localsend = local file sharing across devices on LAN — optional
# typora = WYSIWYG Markdown editor — optional (note: paid app)
# xournalpp = PDF annotation and digital note-taking — optional, useful with a stylus
# imv = lightweight image viewer — opens images instantly from terminal
# mpv = video player — optional but practical, plays any format with minimal UI
# nautilus = GNOME file manager — optional, for when you need a GUI file browser
# nautilus-python = Python extension support for nautilus — optional, pair with nautilus
# ffmpegthumbnailer = video thumbnails in file managers — optional, pair with nautilus
# sushi = quick file preview in nautilus (spacebar) — optional, pair with nautilus
# yaru-icon-theme = Ubuntu Yaru icon theme — optional, alternative to default icons
# gpu-screen-recorder = GPU-accelerated screen recorder — optional, simpler than obs
# 1password-beta = 1Password password manager — optional
# 1password-cli = 1Password CLI — optional, pair with 1password-beta
# info "Applications"
# paru -S --needed --noconfirm \
#   chromium \
#   obsidian \
#   signal-desktop \
#   spotify \
#   libreoffice-fresh \
#   evince \
#   kdenlive \
#   obs-studio \
#   gnome-calculator \
#   gnome-disk-utility \
#   pinta \
#   localsend \
#   typora \
#   xournalpp \
#   imv \
#   mpv \
#   nautilus \
#   nautilus-python \
#   ffmpegthumbnailer \
#   sushi \
#   yaru-icon-theme \
#   gpu-screen-recorder \
#   1password-beta \
#   1password-cli
# ok "Applications installed"
#
# Configure:
# # Register default apps for file types so xdg-open, file managers, and
# # link clicks go to the right place.
# update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
# xdg-mime default org.gnome.Nautilus.desktop inode/directory
# xdg-mime default imv.desktop image/png
# xdg-mime default imv.desktop image/jpeg
# xdg-mime default imv.desktop image/gif
# xdg-mime default imv.desktop image/webp
# xdg-mime default imv.desktop image/bmp
# xdg-mime default imv.desktop image/tiff
# xdg-mime default org.gnome.Evince.desktop application/pdf
# xdg-settings set default-web-browser chromium.desktop
# xdg-mime default chromium.desktop x-scheme-handler/http
# xdg-mime default chromium.desktop x-scheme-handler/https
# xdg-mime default mpv.desktop video/mp4
# xdg-mime default mpv.desktop video/x-msvideo
# xdg-mime default mpv.desktop video/x-matroska
# xdg-mime default mpv.desktop video/webm
# xdg-mime default mpv.desktop video/quicktime
# xdg-mime default nvim.desktop text/plain
# xdg-mime default nvim.desktop application/x-shellscript
# xdg-mime default nvim.desktop application/xml
# ok "Default applications set"

# ── TUI desktop entries ───────────────────────────────────────────────────────
# Stow: (none — this section creates the files directly, no dotfiles needed)
# Creates .desktop files so TUI apps appear in walker and can be launched as
# properly sized floating or tiled windows via Hyprland windowrules.
#
# Exec=xdg-terminal-exec --app-id=TUI.float -e <command>
# The app-id (TUI.float or TUI.tile) is matched by a Hyprland windowrule that
# automatically floats or tiles the window at the right size.
#
# DESKTOP_DIR="$HOME/.local/share/applications"
# ICON_DIR="$HOME/.local/share/applications/icons"
# mkdir -p "$DESKTOP_DIR" "$ICON_DIR"
#
# create_tui_desktop() {
#   local name="$1" exec_cmd="$2" window_style="$3" icon="$4"
#   local app_class="TUI.$window_style"
#   cat > "$DESKTOP_DIR/${name}.desktop" <<EOF
# [Desktop Entry]
# Version=1.0
# Name=$name
# Comment=$name
# Exec=xdg-terminal-exec --app-id=$app_class -e $exec_cmd
# Terminal=false
# Type=Application
# Icon=$icon
# StartupNotify=true
# EOF
#   chmod +x "$DESKTOP_DIR/${name}.desktop"
# }
#
# create_tui_desktop "System Monitor"  "btop"                          float utilities-system-monitor
# create_tui_desktop "Disk Usage"      "bash -c 'dust -r; read -n 1 -s'" float drive-harddisk
# create_tui_desktop "Lazygit"         "lazygit"                       tile  applications-vcs
# create_tui_desktop "WiFi"            "impala"                        float network-wireless
# create_tui_desktop "Audio Mixer"     "wiremix"                       float audio-volume-high
# create_tui_desktop "Lazydocker"      "lazydocker"                    tile  com.docker.docker
# ok "TUI desktop entries created"

# ── NPX tools ─────────────────────────────────────────────────────────────────
# Stow: ./stow.sh bin
# Installs npm-based CLI tools as ~/.local/bin wrappers using mise + npx.
# Each wrapper runs: mise exec node@latest -- npx --yes <package>
# Requires: mise and nodejs (installed in Editor section above)
#
# npx_install() {
#   local package="$1" command="$2"
#   cat > "$HOME/.local/bin/$command" <<EOF
# #!/bin/bash
# exec mise exec node@latest -- npx --yes $package "\$@"
# EOF
#   chmod +x "$HOME/.local/bin/$command"
#   ok "  $command → npx $package"
# }
# mkdir -p "$HOME/.local/bin"
# info "NPX tools"
# npx_install "opencode-ai"              "opencode"
# npx_install "@anthropic-ai/claude-code" "claude"
# ok "NPX tools installed"
