function img2jpg-small --description 'Convert image to small JPG (max 1080px)'
    set -l img $argv[1]
    set -e argv[1]
    magick $img $argv -resize '1080x>' -quality 85 -strip (string replace -r '\.[^.]+$' '' $img)-small.jpg
end
