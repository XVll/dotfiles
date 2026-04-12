#!/usr/bin/env bash
# post-install.sh — Final setup, cleanup, and reboot
#
# Runs last. Every script from omarchy's install/post-install/all.sh is
# represented here in order — kept ones are inlined, skipped ones are
# commented out with a reason.
#
# Also includes our own additions (nvim bootstrap, cleanup) that omarchy
# handles elsewhere or differently.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
need_user

# ─────────────────────────────────────────────────────────────────────────────
# HIBERNATION — omarchy: post-install/hibernation.sh
# SKIPPED: Runs omarchy-hibernation-setup --force (an omarchy binary).
# Under the hood it: finds/creates a swap file or partition, calculates the
# required size from RAM, adds the resume= kernel parameter to the bootloader,
# and adds the resume hook to mkinitcpio. On a desktop with plenty of RAM
# and always-on AC power, hibernation is rarely useful. Revisit if needed.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# PACMAN — omarchy: post-install/pacman.sh
# Handled in pre-install/all.sh (setup step) since pacman needs to be
# configured before any packages are installed. See there for details.
# SKIPPED from omarchy: custom mirrorlist (CachyOS manages its own mirrors
# via cachyos-mirrorlist). Also skipped: Apple T2 repo (not our hardware).
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# ALLOW REBOOT — Passwordless reboot for the duration of install
# omarchy: post-install/allow-reboot.sh
#
# The finished screen prompts for a reboot using sudo reboot. Without this
# rule the user would need to type their password just to reboot at the very
# end — annoying after a long install. This sudoers rule grants it only for
# /usr/bin/reboot. Omarchy removes it after first run; we do the same inline
# in the finished step below.
# ─────────────────────────────────────────────────────────────────────────────
info "Allowing passwordless reboot for install"
sudo tee /etc/sudoers.d/99-installer-reboot >/dev/null <<EOF
$USER ALL=(ALL) NOPASSWD: /usr/bin/reboot
EOF
sudo chmod 440 /etc/sudoers.d/99-installer-reboot
ok "Passwordless reboot enabled"

# ─────────────────────────────────────────────────────────────────────────────
# DNS RESOLVER — Point /etc/resolv.conf at systemd-resolved's stub
# omarchy: first-run/dns-resolver.sh (moved here — no session needed)
#
# By default /etc/resolv.conf may point at a static file or nothing useful.
# Symlinking to the stub-resolv.conf means all DNS queries go through
# systemd-resolved, which handles split DNS, per-interface resolvers, and
# caching. Standard recommendation from the Arch wiki.
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring DNS resolver"
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
ok "DNS resolver symlinked to systemd-resolved"

# ─────────────────────────────────────────────────────────────────────────────
# FIREWALL — UFW default-deny with Docker and LocalSend exceptions
# omarchy: first-run/firewall.sh (moved here — no session needed)
#
# UFW sits in front of everything:
# - deny incoming / allow outgoing: sane default for a desktop
# - port 53317: LocalSend (LAN file sharing) needs both UDP and TCP
# - Docker DNS rule: lets containers reach systemd-resolved on the host
#   (172.17.0.1 is the Docker bridge gateway we set in config/docker)
# - ufw-docker: patches UFW's Docker rules so containers respect the firewall
#   (without this Docker punches its own iptables holes past UFW)
# ─────────────────────────────────────────────────────────────────────────────
info "Configuring firewall"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp
sudo ufw allow 53317/tcp
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw --force enable
sudo systemctl enable ufw
sudo ufw-docker install
sudo ufw reload
ok "Firewall configured"

# ─────────────────────────────────────────────────────────────────────────────
# NVIM — Bootstrap LazyVim plugins headlessly
# (our own addition)
#
# Runs neovim in headless mode to pre-install all plugins defined in the
# LazyVim config. Must run after the dotfiles stow step so nvim finds
# ~/.config/nvim. Without this, the first interactive launch of nvim would
# trigger a slow plugin sync and leave the editor unusable until it finishes.
# ─────────────────────────────────────────────────────────────────────────────
info "Bootstrapping LazyVim plugins"
if [ ! -d "$HOME/.config/nvim" ]; then
  err "~/.config/nvim not found — dotfiles stow must run before this step"
fi
nvim --headless "+Lazy! sync" +qa
ok "LazyVim plugins installed"

# ─────────────────────────────────────────────────────────────────────────────
# THEME — Apply default theme to generate all color configs
# (our own addition)
#
# theme-set reads themes/tokyo-night/colors.toml, processes all app templates
# from theme-templates/, and writes generated color files to
# ~/.config/theme/current/. App configs source/import from that directory.
# Must run after dotfiles stow so the bin/theme-set symlink exists.
# ─────────────────────────────────────────────────────────────────────────────
info "Applying default theme"
theme-set tokyo-night
ok "Theme applied"

# ─────────────────────────────────────────────────────────────────────────────
# CLEANUP — Remove orphaned packages and clear the package cache
# (our own addition)
#
# After all installs are done, packages that were pulled in as dependencies
# but are no longer needed can be removed. paru -Scc clears the downloaded
# package cache so we don't leave GBs of tarballs sitting in /var/cache/pacman.
# ─────────────────────────────────────────────────────────────────────────────
info "Cleaning up orphaned packages"
ORPHANS=$(paru -Qdtq 2>/dev/null || true)
if [ -n "$ORPHANS" ]; then
  echo "$ORPHANS" | paru -Rns --noconfirm -
  ok "Orphans removed"
else
  ok "No orphans found"
fi
paru -Scc --noconfirm 2>/dev/null || true
ok "Package cache cleared"

# ─────────────────────────────────────────────────────────────────────────────
# FINISHED — Remove install sudoers rule and prompt for reboot
# omarchy: post-install/finished.sh (adapted — no tte/gum animations)
#
# Omarchy's version uses tte (terminal text effects) to animate the logo and
# gum for a styled reboot prompt. We keep it simple.
# The sudoers rule created in allow-reboot above is removed here so it doesn't
# persist beyond this install session.
# ─────────────────────────────────────────────────────────────────────────────
sudo rm -f /etc/sudoers.d/99-installer-reboot

echo
echo "  ================================"
echo "   Installation complete!"
echo "   Reboot to start Hyprland."
echo "  ================================"
echo

read -rp "  Reboot now? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  sudo reboot
fi
