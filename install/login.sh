#!/bin/bash

# Login domain: SDDM, Plymouth

pkg-add sddm plymouth

# SDDM theme
omarchy-refresh-sddm

sudo mkdir -p /etc/sddm.conf.d
if [[ ! -f /etc/sddm.conf.d/theme.conf ]]; then
  cat <<EOF | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=omarchy
EOF
fi

sudo systemctl enable sddm.service

# Plymouth theme
sudo mkdir -p /usr/share/plymouth/themes/omarchy
omarchy-refresh-plymouth
sudo plymouth-set-default-theme omarchy
