function img2png --description 'Convert image to optimized PNG'
    set -l img $argv[1]
    set -e argv[1]
    magick $img $argv -strip \
        -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        (string replace -r '\.[^.]+$' '' $img)-optimized.png
end
