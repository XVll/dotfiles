# File system
if command -q eza
    alias ls 'eza -lh --group-directories-first --icons=auto'
    alias lsa 'eza -lah --group-directories-first --icons=auto'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'eza --tree --level=2 --long --icons --git -a'
end

# Directories
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'

# Tools
abbr --add cat bat
abbr --add c opencode
abbr --add cx 'printf "\033[2J\033[3J\033[H" && claude --allow-dangerously-skip-permissions'
abbr --add d docker
abbr --add r rails
abbr --add t 'tmux attach || tmux new -s Work'

# Git
abbr --add g git
abbr --add gcm 'git commit -m'
abbr --add gcam 'git commit -a -m'
abbr --add gcad 'git commit -a --amend'

# Compression
alias decompress 'tar -xzf'
