function img2jpg-large --description 'Convert image to 6K JPG (max 3160px)'
    set -l img $argv[1]
    set -e argv[1]
    magick $img $argv -resize '3160x>' -quality 85 -strip (string replace -r '\.[^.]+$' '' $img)-large.jpg
end
