#!/bin/bash

# Docker domain

pkg-add docker docker-buildx lazydocker

# Daemon config: log rotation + bridge-network DNS to host resolved
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
    "log-driver": "json-file",
    "log-opts": { "max-size": "10m", "max-file": "5" },
    "dns": ["172.17.0.1"],
    "bip": "172.17.0.1/16"
}
EOF

# Expose systemd-resolved to the docker bridge
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e '[Resolve]\nDNSStubListenerExtra=172.17.0.1' \
  | sudo tee /etc/systemd/resolved.conf.d/20-docker-dns.conf >/dev/null
sudo systemctl restart systemd-resolved

# Start Docker on demand (socket activation — daemon runs only when needed)
sudo systemctl enable --now docker.socket

# Non-sudo docker access
sudo usermod -aG docker "$USER"

sudo systemctl daemon-reload
