#!/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

# curl -fsSL https://raw.githubusercontent.com/XVll/dotfiles/main/install.sh | sh

if ! xcode-select --print-path &> /dev/null
then
    echo "${BLUE}Command Line Tools not found, installing now...${NC}"

    xcode-select --install

    # Wait until the Command Line Tools are installed
    until xcode-select --print-path &> /dev/null; do
        echo "${YELLOW}Waiting for Command Line Tools installation to complete...${NC}"
        sleep 5
    done

    echo "${GREEN}Command Line Tools installed successfully!${NC}"
else
    echo "${GREEN}Command Line Tools already installed!${NC}"
fi

if ! command -v brew &> /dev/null
then
    echo "${BLUE}Homebrew could not be found, installing now...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/fx/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "${GREEN}Homebrew is already installed!${NC}"
fi

if ! brew list --cask 1password &> /dev/null
then
    echo "${BLUE}1Password could not be found, installing now...${NC}"
    brew install --cask 1password
else
    echo "${GREEN}1Password is already installed!${NC}"
fi

if ! command -v op &> /dev/null
then
    echo "${BLUE}1Password CLI could not be found, installing now...${NC}"
    brew install 1password-cli
else
    echo "${GREEN}1Password CLI is already installed!${NC}"
fi

if ! command -v chezmoi &> /dev/null
then
    echo "${BLUE}Chezmoi could not be found, installing now...${NC}"
    brew install chezmoi
else
    echo "${GREEN}Chezmoi is already installed!${NC}"
fi

echo "${YELLOW}Ensure Full Disk Access is granted to Terminal, some preferences requires.${NC}"

while ! op account get > /dev/null 2>&1; do
    echo "${RED}Configure and sign in to your 1Password account in the desktop application then press any key to continue${NC}"
    read -n 1 -s -r
done

echo "${BLUE}Starting chezmoi...${NC}"
chezmoi init XVll --apply --ssh
echo "${GREEN}Done!${NC}"
