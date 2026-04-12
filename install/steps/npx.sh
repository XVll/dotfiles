#!/usr/bin/env bash
# npx.sh — npm-based CLI tools via mise + npx wrappers

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
need_user

# ── Stow ──────────────────────────────────────────────────────────────────────
bash "$DOTFILES_DIR/stow.sh" bin

# ── Configure ─────────────────────────────────────────────────────────────────

# Creates ~/.local/bin wrappers that run npm tools via mise's managed Node
# without globally installing them. Each invocation fetches the latest version
# via npx --yes if not cached.
#
# Requires: mise and nodejs (from editor.sh)

info "NPX tools"
mkdir -p "$HOME/.local/bin"

npx_install() {
  local package="$1" command="$2"
  cat > "$HOME/.local/bin/$command" <<EOF
#!/bin/bash
exec mise exec node@latest -- npx --yes $package "\$@"
EOF
  chmod +x "$HOME/.local/bin/$command"
  ok "  $command → npx $package"
}

npx_install "opencode-ai"              "opencode"
npx_install "@anthropic-ai/claude-code" "claude"

ok "NPX tools installed"
