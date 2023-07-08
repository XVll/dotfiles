#!/bin/sh

# curl -fsSL https://raw.githubusercontent.com/XVll/dotfiles/main/install.sh | bash

if ! xcode-select --print-path &> /dev/null
then
    echo "Command Line Tools not found, installing now..."
    # Installing Command Line Tools
    xcode-select --install
else
    echo "Command Line Tools already installed!"
fi

if ! command -v brew &> /dev/null
then
    echo "Homebrew could not be found, installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/fx/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed!"
fi

if ! brew list --cask 1password &> /dev/null
then
    echo "1Password could not be found, installing now..."
    brew install --cask 1password
else
    echo "1Password is already installed!"
fi

if ! command -v op &> /dev/null
then
    echo "1Password CLI could not be found, installing now..."
    brew install 1password-cli
else
    echo "1Password CLI is already installed!"
fi

if ! command -v chezmoi &> /dev/null
then
    echo "Chezmoi could not be found, installing now..."
    brew install chezmoi
else
    echo "Chezmoi is already installed!"
fi

echo "Setup your 1Password account in the desktop application and press any key to continue"
echo "Ensure Full Disk Access is granted to Terminal, some preferences requires."
read -n 1 -s -r


echo "Starting chezmoi..."
chezmoi init XVll --apply
echo "Done!"
