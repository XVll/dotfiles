function img2jpg --description 'Convert image to JPG (quality 85)'
    set -l img $argv[1]
    set -e argv[1]
    magick $img $argv -quality 85 -strip (string replace -r '\.[^.]+$' '' $img)-converted.jpg
end
