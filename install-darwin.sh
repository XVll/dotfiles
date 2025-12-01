#!/bin/bash
# Bootstrap script for macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/XVll/dotfiles/main/install-darwin.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==> Starting macOS dotfiles setup...${NC}"

# Install Xcode Command Line Tools
if ! xcode-select --print-path &> /dev/null; then
    echo -e "${BLUE}Installing Xcode Command Line Tools...${NC}"
    xcode-select --install
    echo -e "${RED}Press any key after installation completes...${NC}"
    read -n 1 -s -r
fi
echo -e "${GREEN}✓ Xcode Command Line Tools${NC}"

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${BLUE}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
echo -e "${GREEN}✓ Homebrew${NC}"

# Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo -e "${BLUE}Installing chezmoi...${NC}"
    brew install chezmoi
fi
echo -e "${GREEN}✓ chezmoi${NC}"

# Initialize and apply dotfiles
echo -e "${BLUE}Initializing dotfiles...${NC}"
chezmoi init XVll --apply

echo -e "${GREEN}==> Setup complete!${NC}"
echo -e "${BLUE}Restart your terminal or run: source ~/.zshrc${NC}"
