# Editor used by CLI
set -gx EDITOR nvim
set -gx SUDO_EDITOR $EDITOR
set -gx TERMINAL ghostty
set -gx BAT_THEME ansi

# Dotfiles bin on PATH
set -gx DOTFILES ~/.dotfiles
fish_add_path $DOTFILES/bin $HOME/.local/bin

# Style `gum confirm` prompts (ANSI color indices match the terminal theme)
set -gx GUM_CONFIRM_PROMPT_FOREGROUND 6
set -gx GUM_CONFIRM_SELECTED_FOREGROUND 0
set -gx GUM_CONFIRM_SELECTED_BACKGROUND 2
set -gx GUM_CONFIRM_UNSELECTED_FOREGROUND 7
set -gx GUM_CONFIRM_UNSELECTED_BACKGROUND 8
