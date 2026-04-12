#!/usr/bin/env bash
# pre-install/all.sh — Guards and system preparation
#
# Runs first, before any packages are installed. Verifies the environment
# is what we expect, configures pacman, syncs the system, and installs the
# minimum tools needed for the rest of the install to work.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

# ─────────────────────────────────────────────────────────────────────────────
# GUARD — Verify prerequisites before doing anything destructive
# (was guard.sh)
#
# Fail fast with a clear message if the environment isn't right. Better to
# stop here than to have a script halfway through fail in a confusing way.
# ─────────────────────────────────────────────────────────────────────────────
abort() {
  echo " ✗  Requires: $1"
  echo "    Stopping. Fix this before running install.sh"
  exit 1
}

# Must run as regular user, not root — many steps use sudo explicitly and
# running the whole script as root breaks user-level operations ($HOME, etc.)
(( EUID != 0 )) || abort "run as your user, not root"

# Must be on CachyOS — we rely on CachyOS repos, paru, and CachyOS defaults
grep -q 'ID=cachyos' /etc/os-release 2>/dev/null || abort "CachyOS"

# Must have Limine bootloader (CachyOS default since ~2024)
command -v limine &>/dev/null || abort "Limine bootloader"

# Must have btrfs root — we rely on btrfs for snapshot support
[[ "$(findmnt -n -o FSTYPE /)" == "btrfs" ]] || abort "btrfs root filesystem"

ok "Guards passed"

# ─────────────────────────────────────────────────────────────────────────────
# SETUP — Configure pacman, sync system, install base tools
# (was setup.sh)
#
# Done here at the top so everything that follows benefits from parallel
# downloads and a fully-updated package database.
#
# pacman tweaks:
# - Color + VerbosePkgLists: readable output during installs
# - ParallelDownloads = 5: download up to 5 packages at once
# - ILoveCandy: Pacman progress animation (harmless)
# - CheckSpace: warns before install if disk space would run out
#
# pacman -Syyuu: double -y forces a full DB refresh even if recently synced;
# -uu allows downgrading if the mirror has a newer DB than installed
# (important on a fresh CachyOS ISO where the DB may be stale).
# ─────────────────────────────────────────────────────────────────────────────
need_user

info "Configuring pacman"
sudo sed -i 's/^#Color/Color/'                               /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/'          /etc/pacman.conf
sudo sed -i 's/^#CheckSpace/CheckSpace/'                     /etc/pacman.conf
grep -q '^ILoveCandy' /etc/pacman.conf || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
ok "Pacman configured"

info "Syncing and upgrading system"
sudo pacman -Syyuu --noconfirm
ok "System up to date"

info "Installing base tools"
sudo pacman -S --needed --noconfirm base-devel git paru
ok "base-devel, git, paru installed"
