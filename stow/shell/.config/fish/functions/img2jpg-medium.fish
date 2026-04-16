function img2jpg-medium --description 'Convert image to 4K JPG (max 2160px)'
    set -l img $argv[1]
    set -e argv[1]
    magick $img $argv -resize '2160x>' -quality 85 -strip (string replace -r '\.[^.]+$' '' $img)-medium.jpg
end
