#!/usr/bin/env bash
# docker.sh — Docker container runtime

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# docker = container runtime
# docker-buildx = multi-platform build plugin — `docker buildx build`
# docker-compose = multi-container orchestration — define services in YAML
# lazydocker = TUI for Docker — manage containers, images, volumes visually
info "Docker"
paru -S --needed --noconfirm \
  docker \
  docker-buildx \
  docker-compose \
  lazydocker
ok "Docker installed"

# ── Configure ─────────────────────────────────────────────────────────────────

# daemon.json — log rotation (10MB × 5 files per container), DNS through
# systemd-resolved, Docker bridge IP (172.17.0.1/16)
info "Configuring Docker daemon"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'JSON'
{
    "log-driver": "json-file",
    "log-opts": { "max-size": "10m", "max-file": "5" },
    "dns": ["172.17.0.1"],
    "bip": "172.17.0.1/16"
}
JSON

# Expose systemd-resolved on the Docker bridge so containers can resolve DNS
sudo mkdir -p /etc/systemd/resolved.conf.d
printf '[Resolve]\nDNSStubListenerExtra=172.17.0.1\n' \
  | sudo tee /etc/systemd/resolved.conf.d/20-docker-dns.conf >/dev/null
sudo systemctl restart systemd-resolved

# Run docker without sudo
sudo usermod -aG docker "$USER"

# Docker starts on first use (socket activation) — don't block boot
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf >/dev/null <<'UNIT'
[Unit]
DefaultDependencies=no
UNIT
sudo systemctl daemon-reload
ok "Docker configured (re-login to run without sudo)"
