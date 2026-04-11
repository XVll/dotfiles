# ── History ────────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ── Completion ─────────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case insensitive

# ── Aliases ────────────────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -la'
alias lt='eza --icons --tree --level=2'
alias cat='bat --style=plain'
alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias ..='cd ..'
alias ...='cd ../..'

# ── Path ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Editor ─────────────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── fzf ────────────────────────────────────────────────────────────────────────
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="
  --color=bg+:#1f2335,bg:#1a1b26,spinner:#7dcfff,hl:#f7768e
  --color=fg:#a9b1d6,header:#f7768e,info:#7aa2f7,pointer:#7dcfff
  --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e
  --border rounded --height 40%"

# ── zoxide (smart cd) ──────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Plugins ────────────────────────────────────────────────────────────────────
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Prompt (starship) ──────────────────────────────────────────────────────────
eval "$(starship init zsh)"
