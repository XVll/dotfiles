# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source configuration
source ~/.config/bash/envs
source ~/.config/bash/shell
source ~/.config/bash/aliases
source ~/.config/bash/functions
source ~/.config/bash/init
[[ $- == *i* ]] && bind -f ~/.config/bash/inputrc

# Personal additions below
