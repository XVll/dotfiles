function sff --description 'Fuzzy find file and scp to destination'
    if test (count $argv) -eq 0
        echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
        return 1
    end
    set -l file (find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff)
    test -n "$file"; and scp "$file" $argv[1]
end
