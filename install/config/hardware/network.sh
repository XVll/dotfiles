# TODO: Rework for CachyOS — use NetworkManager with iwd backend
# CachyOS ships NetworkManager by default. Configure NM to use iwd as wifi backend
# instead of enabling standalone iwd.

# Ensure iwd service will be started
sudo systemctl enable iwd.service

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
