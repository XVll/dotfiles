#!/bin/bash

# Dev domain: editors, VCS tools, runtimes, build tooling

pkg-add nvim visual-studio-code-bin lazygit mise \
  luarocks tree-sitter-cli postgresql-libs claude-code

cd "$DOTFILES" && stow -d stow -t "$HOME" dev

# VSCode: use gnome-keyring for secrets, disable auto-updates (Arch manages it)
mkdir -p ~/.vscode ~/.config/Code/User
cat > ~/.vscode/argv.json << 'ARGVEOF'
{
  "password-store":"gnome-libsecret"
}
ARGVEOF
printf '{\n  "update.mode": "none"\n}\n' > ~/.config/Code/User/settings.json

# Language runtimes via mise
mise use --global node@latest
mise use --global bun@latest
mise use --global python@latest
curl -fsSL https://astral.sh/uv/install.sh | sh
mise use --global dotnet@latest

# Install remaining mise-managed tools (npm packages in ~/.config/mise/config.toml)
mise install
