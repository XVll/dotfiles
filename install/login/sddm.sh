# Install SDDM theme
omarchy-refresh-sddm

# Setup SDDM login service
sudo mkdir -p /etc/sddm.conf.d
if [[ ! -f /etc/sddm.conf.d/theme.conf ]]; then
  cat <<EOF | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=omarchy
EOF
fi

sudo systemctl enable sddm.service
