#!/bin/bash
# Bootstrap script for Linux/WSL
# Usage: curl -fsSL https://raw.githubusercontent.com/XVll/dotfiles/main/install-linux.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==> Starting Linux dotfiles setup...${NC}"

# Detect package manager and install essentials
if command -v apt &> /dev/null; then
    echo -e "${BLUE}Installing essentials via apt...${NC}"
    sudo apt update
    sudo apt install -y git curl zsh build-essential
elif command -v dnf &> /dev/null; then
    echo -e "${BLUE}Installing essentials via dnf...${NC}"
    sudo dnf install -y git curl zsh gcc make
elif command -v pacman &> /dev/null; then
    echo -e "${BLUE}Installing essentials via pacman...${NC}"
    sudo pacman -Syu --noconfirm git curl zsh base-devel
fi
echo -e "${GREEN}✓ Essentials installed${NC}"

# Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo -e "${BLUE}Installing chezmoi...${NC}"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
    export PATH="$HOME/.local/bin:$PATH"
fi
echo -e "${GREEN}✓ chezmoi${NC}"

# Initialize and apply dotfiles
echo -e "${BLUE}Initializing dotfiles...${NC}"
~/.local/bin/chezmoi init XVll --apply

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${BLUE}Setting zsh as default shell...${NC}"
    chsh -s $(which zsh)
fi

echo -e "${GREEN}==> Setup complete!${NC}"
echo -e "${BLUE}Restart your terminal or run: exec zsh${NC}"
