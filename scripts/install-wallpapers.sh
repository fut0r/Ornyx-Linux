#!/usr/bin/env bash
# Read the pinned photo manifest on stdin. Render native 4K files in the target.
set -euo pipefail
destination=${1:?expected output directory}
stage=$(mktemp -d)
trap 'rm -r -- "$stage"' EXIT
mkdir -p "$destination"
while IFS=$'\t' read -r slug digest url; do
    curl -fsSL --retry 3 --proto '=https' --proto-redir '=https' \
        -A 'OrnyxLinux/1 (https://github.com/fut0r/Ornyx-Linux)' "$url" -o "$stage/photo"
    echo "$digest  $stage/photo" | sha256sum -c -
    color=sRGB
    if [[ $slug == manhattan ]]; then color=Gray; fi
    magick "$stage/photo" -auto-orient -colorspace "$color" -resize '3840x2160^' \
        -gravity center -extent 3840x2160 -strip -quality 92 "$stage/$slug.jpg"
    install -m0644 "$stage/$slug.jpg" "$destination/$slug.jpg"
done
