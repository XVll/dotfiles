function eff --description 'Open fuzzy-found file in editor'
    set -l file (ff)
    test -n "$file"; and $EDITOR $file
end
