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
for pair in ornyx-linux:fedora_whitelogo_med ornyx-ink:fedora_logo_med; do
    src=/usr/share/pixmaps/${pair%:*}.png
    dest=/usr/share/pixmaps/${pair#*:}.png
    [[ -f $dest ]]
    unit=$(systemd-escape --path --suffix=mount "$dest")
    cat > "/etc/systemd/system/$unit" <<UNIT
[Unit]
Description=Ornyx Linux About artwork
[Mount]
What=$src
Where=$dest
Type=none
Options=bind,ro
[Install]
WantedBy=local-fs.target
UNIT
    systemctl enable "$unit"
done

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

# Replace the target's /etc symlink atomically, preserving the RPM's vendor file.
# shellcheck disable=SC1091
source /usr/lib/os-release
[[ $ID == fedora && $VERSION_ID == 45 ]]
cat > "$stage/os-release" <<RELEASE
NAME="Ornyx Linux"
PRETTY_NAME="Ornyx Linux $VERSION_ID"
ID=ornyx
ID_LIKE="fedora"
VERSION="$VERSION_ID"
VERSION_ID="$VERSION_ID"
PLATFORM_ID="platform:f$VERSION_ID"
LOGO=ornyx-linux
HOME_URL="https://github.com/fut0r/Ornyx-Linux"
BUG_REPORT_URL="https://github.com/fut0r/Ornyx-Linux/issues"
RELEASE
install -m0644 "$stage/os-release" /etc/.ornyx-os-release
mv -Tf /etc/.ornyx-os-release /etc/os-release
if [[ -f /etc/default/grub ]]; then
    sed -i '/^GRUB_DISTRIBUTOR=/d' /etc/default/grub
    echo 'GRUB_DISTRIBUTOR="Ornyx Linux"' >> /etc/default/grub
fi
# Future Fedora BLS entries read NAME from /etc/os-release.
for entry in /boot/loader/entries/"$(cat /etc/machine-id)"-*.conf; do
    [[ -f $entry ]] || continue
    sed -i -E '/^title[[:space:]]+Fedora/ { s/^title([[:space:]]+)Fedora( Linux)?/title\1Ornyx Linux/; s/ [(]Workstation Edition[)]//; }' "$entry"
done

themes=/usr/share/plymouth/themes
install -d "$themes/ornyx"
cp "$themes/spinner/"*.png "$themes/ornyx/"
install -m0644 "$stage/ornyx.png" "$themes/ornyx/watermark.png"
sed -e '/^Name\[/d' -e 's/^Name=.*/Name=Ornyx Linux/' \
    -e "s|^ImageDir=.*|ImageDir=$themes/ornyx|" \
    "$themes/spinner/spinner.plymouth" > "$themes/ornyx/ornyx.plymouth"
plymouth-set-default-theme ornyx
dracut --regenerate-all --force
