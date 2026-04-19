#!/bin/bash

# Dev domain: editors, VCS tools, runtimes, build tooling

pkg-add nvim visual-studio-code-bin lazygit mise uv claude-code \
  luarocks \
  tree-sitter-cli \
  postgresql-libs

#   luarocks:          lua package manager — some nvim plugins need it at build time
#   tree-sitter-cli:   for :TSInstallFromGrammar and local parser dev in nvim
#   postgresql-libs:   libpq — required by DB clients, psycopg, language servers

cd "$DOTFILES" && stow -d stow -t "$HOME" dev

# VSCode settings + extensions: managed via VSCode Settings Sync (GitHub).
# argv.json (gnome-keyring) is stowed — Settings Sync doesn't cover it.

# Language runtimes + cli tools pinned in ~/.config/mise/config.toml
mise install
