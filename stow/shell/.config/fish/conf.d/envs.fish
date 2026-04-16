# Editor used by CLI
set -gx EDITOR nvim
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME ansi

# Dotfiles bin on PATH
set -gx DOTFILES ~/.dotfiles
fish_add_path $DOTFILES/bin $HOME/.local/bin
