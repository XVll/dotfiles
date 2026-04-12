#!/usr/bin/env bash
# editor.sh — Neovim and language tooling

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Install ───────────────────────────────────────────────────────────────────
# neovim = vim-based modal editor — we use LazyVim as the config framework
# ripgrep = grep replacement — required by telescope and fzf-lua plugins
# fd = find replacement — required by telescope for fast file search
# nodejs + npm = JavaScript runtime — Mason uses these to install LSP servers
# clang = C compiler — treesitter compiles native parser binaries, needs this
# tree-sitter-cli = treesitter grammar CLI — build/update syntax grammars
# luarocks = Lua package manager — some nvim plugins pull in Lua modules
# mise = universal version manager — manages node/python/ruby/go/rust per project
# rust = Rust toolchain — remove if you don't develop in Rust
# ruby = Ruby runtime — remove if you don't develop in Ruby
# dotnet-runtime-9.0 = .NET runtime — remove if you don't run .NET apps
# mariadb-libs = MySQL/MariaDB client libs — only if you connect to MySQL
# postgresql-libs = PostgreSQL client libs — only if you connect to Postgres
# python-poetry-core = Poetry build backend — only for Python Poetry projects
info "Editor"
paru -S --needed --noconfirm \
  neovim \
  ripgrep \
  fd \
  nodejs \
  npm \
  clang \
  tree-sitter-cli \
  luarocks \
  mise \
  rust \
  ruby \
  dotnet-runtime-9.0 \
  mariadb-libs \
  postgresql-libs \
  python-poetry-core
ok "Editor installed"

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" nvim

# ── Configure ─────────────────────────────────────────────────────────────────

# ~/Work — dev projects root. mise adds ./bin to PATH inside any project here
# so project-local scripts are immediately available without installing globally
info "Setting up ~/Work and mise"
mkdir -p "$HOME/Work/tries"
cat >"$HOME/Work/.mise.toml" <<'MISE'
[env]
_.path = "{{ cwd }}/bin"
MISE
mise trust "$HOME/Work/.mise.toml"
mise use -g node@latest
ok "~/Work and mise configured"

# powerprofilesctl shebang fix — it uses #!/usr/bin/env python3 but when mise
# is active, env resolves to mise's shim instead of system python3
info "Fixing powerprofilesctl shebang"
sudo sed -i '/env python3/ c\#!/bin/python3' /usr/bin/powerprofilesctl
ok "powerprofilesctl shebang fixed"
