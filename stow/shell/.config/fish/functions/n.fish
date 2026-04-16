function n --wraps nvim --description 'Open nvim, default to current directory'
    if test (count $argv) -eq 0
        command nvim .
    else
        command nvim $argv
    end
end
