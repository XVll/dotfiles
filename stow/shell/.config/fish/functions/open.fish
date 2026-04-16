function open --description 'Open files with xdg-open'
    command xdg-open $argv >/dev/null 2>&1 &
    disown
end
