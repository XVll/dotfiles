#!/bin/bash

# System domain: systemd tweaks, system-sleep scripts, base utilities, hardware config

pkg-add bolt gvfs-mtp gvfs-nfs gvfs-smb inetutils inxi iwd \
  kernel-modules-hook power-profiles-daemon ufw ufw-docker \
  wireless-regdb tzupdate xmlstarlet qt5-wayland \
  libsecret libyaml exfatprogs

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" system

# Faster shutdown systemd configs
sudo mkdir -p /etc/systemd/system.conf.d
sudo cp "$OMARCHY_PATH/systemd/faster-shutdown.conf" /etc/systemd/system.conf.d/10-faster-shutdown.conf 2>/dev/null
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo cp ~/.config/systemd/user@.service.d/faster-shutdown.conf /etc/systemd/system/user@.service.d/

# System-sleep scripts
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root "$OMARCHY_PATH/systemd/system-sleep/keyboard-backlight" /usr/lib/systemd/system-sleep/
sudo install -m 0755 -o root -g root "$OMARCHY_PATH/systemd/system-sleep/unmount-fuse" /usr/lib/systemd/system-sleep/

# Kernel modules hook
chrootable_systemctl_enable linux-modules-cleanup.service

# DNS resolver
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# GPG keyserver config
sudo mkdir -p /etc/gnupg
sudo cp ~/.gnupg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr || true
sudo gpgconf --launch dirmngr || true

# Timezone sudoers
sudo tee /etc/sudoers.d/omarchy-tzupdate >/dev/null <<EOF
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
sudo chmod 0440 /etc/sudoers.d/omarchy-tzupdate

# Increase sudo password tries
echo "Defaults passwd_tries=10" | sudo tee /etc/sudoers.d/passwd-tries >/dev/null
sudo chmod 440 /etc/sudoers.d/passwd-tries
sudo sed -i 's/^# *deny = .*/deny = 10/' /etc/security/faillock.conf

# Increase lockout limit, decrease timeout
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"

# Ensure lockout limit is reset on restart
sudo sed -i '/pam_faillock\.so preauth/d' /etc/pam.d/sddm-autologin
sudo sed -i '/auth.*pam_permit\.so/a auth        required    pam_faillock.so authsucc' /etc/pam.d/sddm-autologin

# SSH MTU probing fix
grep -q "tcp_mtu_probing" /etc/sysctl.d/99-sysctl.conf 2>/dev/null || \
  echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null

# Increase file watchers for dev tools
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-omarchy-file-watchers.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1

# Fix powerprofilesctl shebang for mise compatibility
sudo sed -i '/env python3/ c\#!/bin/python3' /usr/bin/powerprofilesctl 2>/dev/null

# Disable USB autosuspend
if [[ ! -f /etc/modprobe.d/disable-usb-autosuspend.conf ]]; then
  echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null
fi

# Ignore power button (handled by WM menu instead)
sudo sed -i 's/.*HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

# Networking
# TODO: Rework for CachyOS — use NetworkManager with iwd backend
sudo systemctl enable iwd.service
sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null
sudo systemctl mask systemd-networkd-wait-online.service 2>/dev/null

# Wireless regulatory domain
if [[ -f "/etc/conf.d/wireless-regdom" ]]; then
  unset WIRELESS_REGDOM
  . /etc/conf.d/wireless-regdom
fi
if [[ ! -n ${WIRELESS_REGDOM} ]]; then
  if [[ -e "/etc/localtime" ]]; then
    TIMEZONE=$(readlink -f /etc/localtime)
    TIMEZONE=${TIMEZONE#/usr/share/zoneinfo/}
    COUNTRY="${TIMEZONE%%/*}"
    if [[ ! $COUNTRY =~ ^[A-Z]{2}$ ]] && [[ -f /usr/share/zoneinfo/zone.tab ]]; then
      COUNTRY=$(awk -v tz="$TIMEZONE" '$3 == tz {print $1; exit}' /usr/share/zoneinfo/zone.tab)
    fi
    if [[ $COUNTRY =~ ^[A-Z]{2}$ ]]; then
      echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee -a /etc/conf.d/wireless-regdom >/dev/null
      if command -v iw &>/dev/null; then
        sudo iw reg set ${COUNTRY}
      fi
    fi
  fi
fi

# Bluetooth
chrootable_systemctl_enable bluetooth.service

# Firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp  # LocalSend
sudo ufw allow 53317/tcp  # LocalSend
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw --force enable
sudo systemctl enable ufw
sudo ufw-docker install
sudo ufw reload

# Nvidia (auto-detect)
# TODO: Validate against CachyOS nvidia handling — CachyOS has its own nvidia
# installer/detection that may overlap or conflict with this script.
NVIDIA="$(lspci | grep -i 'nvidia')"
if [[ -n $NVIDIA ]]; then
  KERNEL_HEADERS="$(pacman -Qqs '^linux(-zen|-lts|-hardened)?$' | head -1)-headers"

  # Turing+ (GTX 16xx, RTX 20xx-50xx, RTX Pro, Quadro RTX, datacenter A/H/T/L series) have GSP firmware
  if echo "$NVIDIA" | grep -qE "GTX 16[0-9]{2}|RTX [2-5][0-9]{3}|RTX PRO [0-9]{4}|Quadro RTX|RTX A[0-9]{4}|A[1-9][0-9]{2}|H[1-9][0-9]{2}|T4|L[0-9]+"; then
    PACKAGES=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver)
    GPU_ARCH="turing_plus"
  # Maxwell (GTX 9xx), Pascal (GT/GTX 10xx, Quadro P, MX series), Volta (Titan V, Tesla V100, Quadro GV100) lack GSP
  elif echo "$NVIDIA" | grep -qE "GTX (9[0-9]{2}|10[0-9]{2})|GT 10[0-9]{2}|Quadro [PM][0-9]{3,4}|Quadro GV100|MX *[0-9]+|Titan (X|Xp|V)|Tesla V100"; then
    PACKAGES=(nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils)
    GPU_ARCH="maxwell_pascal_volta"
  fi

  if [[ -z ${PACKAGES+x} ]]; then
    echo "No compatible driver for your NVIDIA GPU. See: https://wiki.archlinux.org/title/NVIDIA"
  else
    pkg-add "$KERNEL_HEADERS" "${PACKAGES[@]}"

    sudo tee /etc/modprobe.d/nvidia.conf <<EOF >/dev/null
options nvidia_drm modeset=1
EOF
    sudo tee /etc/mkinitcpio.conf.d/nvidia.conf <<EOF >/dev/null
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF

    if [[ $GPU_ARCH = "turing_plus" ]]; then
      cat >>"$HOME/.config/hypr/envs.conf" <<'EOF'

# NVIDIA (Turing+ with GSP firmware)
env = NVD_BACKEND,direct
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
    elif [[ $GPU_ARCH = "maxwell_pascal_volta" ]]; then
      cat >>"$HOME/.config/hypr/envs.conf" <<'EOF'

# NVIDIA (Maxwell/Pascal/Volta without GSP firmware)
env = NVD_BACKEND,egl
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
    fi
  fi
fi

# Vulkan (auto-detect)
# (NVIDIA Vulkan is handled above via nvidia-utils)
declare -A VULKAN_DRIVERS=(
  [Intel]=vulkan-intel
  [AMD]=vulkan-radeon
)
VULKAN_PACKAGES=()
for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" >/dev/null; then
    VULKAN_PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done
if (( ${#VULKAN_PACKAGES[@]} > 0 )); then
  pkg-add "${VULKAN_PACKAGES[@]}"
fi

# Intel video acceleration (auto-detect)
if INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  if [[ ${INTEL_GPU,,} =~ (hd\ graphics|uhd\ graphics|xe|iris|arc) ]]; then
    pkg-add intel-media-driver
  elif [[ ${INTEL_GPU,,} =~ "gma" ]]; then
    pkg-add libva-intel-driver
  fi
fi

sudo systemctl daemon-reload
