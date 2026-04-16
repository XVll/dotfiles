#!/bin/bash

# Theme domain: theme definitions, templates, branding

pkg-add kvantum-qt5 yaru-icon-theme

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" theme

# Install SDDM theme
omarchy-refresh-sddm

# Install Plymouth theme
sudo mkdir -p /usr/share/plymouth/themes/omarchy
omarchy-refresh-plymouth

# GTK / icon theme
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"
sudo gtk-update-icon-cache /usr/share/icons/Yaru

# Fix Nautilus action icons for Yaru theme
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Setup user theme folder and set initial theme
mkdir -p ~/.config/omarchy/themes
omarchy-theme-set "Tokyo Night"
rm -rf ~/.config/chromium/SingletonLock

# Theme symlinks for apps
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config

# Browser managed policy directories for theme changes
sudo mkdir -p /etc/chromium/policies/managed
sudo chmod a+rw /etc/chromium/policies/managed

sudo mkdir -p /etc/brave/policies/managed
sudo chmod a+rw /etc/brave/policies/managed

# Default Chromium to follow system appearance
echo '{"browser":{"theme":{"color_scheme":0}}}' | sudo tee /usr/lib/chromium/initial_preferences >/dev/null
