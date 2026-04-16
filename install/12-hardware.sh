#!/bin/bash

# Hardware domain: GPU drivers (nvidia, vulkan, intel)

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
