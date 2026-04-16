function ff --description 'Fuzzy find files with preview'
    if test "$TERM" = xterm-kitty
        fzf --preview 'case $(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'
    else
        fzf --preview 'bat --style=numbers --color=always {}'
    end
end
