#!/usr/bin/env bash
# Invoked inside the installed target by the GNOME Kickstart post section.
set -euo pipefail
stage=${1:?expected staging directory}
logo=/usr/share/icons/hicolor/scalable/apps/ornyx-linux.svg
rsvg-convert --width 360 "$logo" -o "$stage/ornyx.png"
install -Dm0644 "$stage/ornyx.png" /usr/share/pixmaps/ornyx-linux.png

# Fedora Settings loads two absolute PNG paths compiled into the binary.
# Read-only bind mounts cover those assets even after a vendor RPM update.
sed 's/#F1F1F2/#17191D/g' "$logo" > "$stage/ornyx-ink.svg"
rsvg-convert --width 360 "$stage/ornyx-ink.svg" -o "$stage/ornyx-ink.png"
install -m0644 "$stage/ornyx-ink.png" /usr/share/pixmaps/ornyx-ink.png
bash "$stage/brand-identity.sh" "$stage"

# Kawkab Mono v0.501 is distributed upstream under the SIL OFL.
curl --fail --location --silent --show-error --proto '=https' \
    https://github.com/aiaf/kawkab-mono/releases/download/v0.501/kawkab-mono-0.501.zip \
    -o "$stage/kawkab.zip"
(cd "$stage" && echo '11c06f57dddefaf0166d74caaa072865ab6ff8d34076e7ec5d2c20edda145666  kawkab.zip' | sha256sum -c -)
for asset in KawkabMono-{Regular,Light,Bold}.otf OFL.txt; do
    unzip -p "$stage/kawkab.zip" "kawkab-mono-0.501/$asset" > "$stage/$asset"
    install -Dm0644 "$stage/$asset" "/usr/local/share/fonts/kawkab-mono/$asset"
done
fc-cache -f

bash "$stage/brand-boot.sh" "$stage"
