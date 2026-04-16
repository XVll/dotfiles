function compress --description 'Compress directory to tar.gz'
    tar -czf (string trim -r -c '/' $argv[1]).tar.gz (string trim -r -c '/' $argv[1])
end
