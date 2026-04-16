#!/bin/bash

# Shell domain: bash, starship, git, gpg

pkg-add bash bash-completion starship git gnupg \
  bat eza fd fzf less man-db ripgrep tldr unzip usage whois \
  zoxide jq expac github-cli gum paru tobi-try

cd "$(dirname "$0")/.." && stow -d stow -t "$HOME" shell
