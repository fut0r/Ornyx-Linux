#!/usr/bin/env bash
# Apply GNOME identity and artwork on an existing Fedora 45 installation.
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
source /usr/lib/os-release
[[ $ID == fedora && $VERSION_ID == 45 ]]
stage=$(mktemp -d)
trap 'rm -r -- "$stage"' EXIT
pix=/usr/share/pixmaps
schemas=/usr/share/glib-2.0/schemas
override=zz-ornyx-branding.gschema.override
for asset in fedora_whitelogo_med fedora_logo_med; do
    test -f "$pix/$asset.png"
done
magick "$repo/branding/ornyx-linux.png" -resize 360x "$stage/ornyx-linux.png"
magick "$stage/ornyx-linux.png" -channel RGB -fill '#17191D' -colorize 100 +channel "$stage/ornyx-ink.png"
mkdir "$stage/schemas"
cp "$schemas/"*.xml "$repo/config/gnome/$override" "$stage/schemas/"
glib-compile-schemas --strict "$stage/schemas"
if [[ ${1:-} == --check ]]; then
    echo "Desktop branding preflight passed."
    exit 0
fi
with_boot=false
if [[ ${1:-} == --with-boot ]]; then
    with_boot=true
    shift
    mountpoint -q /boot || { echo "Expected the external installation's mounted /boot." >&2; exit 1; }
fi
[[ $# == 0 && $EUID == 0 ]] || { echo "Run as administrator or use --check." >&2; exit 1; }
if ! [[ /etc/os-release -ef /usr/lib/os-release ]] && ! grep -qx 'ID=ornyx' /etc/os-release; then
    echo "Existing custom OS identity requires review." >&2
    exit 1
fi
# Preserve administrator identity settings before the first application.
backup=/var/backups/ornyx-desktop-identity
if [[ ! -d $backup ]]; then
    install -d -m0700 "$backup"
    cp -a /etc/os-release "$backup/"
    for path in /etc/hostname /etc/machine-info; do
        if [[ -e $path ]]; then cp -a "$path" "$backup/"; fi
    done
fi
install -Dm0644 "$repo/branding/ornyx-linux.svg" /usr/share/icons/hicolor/scalable/apps/ornyx-linux.svg
install -m0644 "$repo/branding/ornyx-linux-desktop.svg" "$pix/"
for name in ornyx-linux ornyx-ink; do
    if ! cmp -s "$stage/$name.png" "$pix/$name.png"; then
        install -m0644 "$stage/$name.png" "$pix/"
    fi
done
bash "$repo/scripts/brand-identity.sh" "$stage"
systemctl daemon-reload
for asset in fedora_whitelogo_med fedora_logo_med; do
    systemctl restart "$(systemd-escape --path --suffix=mount "$pix/$asset.png")"
done
install -m0644 "$repo/config/gnome/$override" "$schemas/"
glib-compile-schemas "$schemas"
restorecon /etc/os-release
hostnamectl hostname ornyx
hostnamectl --pretty hostname 'Ornyx Linux'
cmp "$pix/ornyx-linux.png" "$pix/fedora_whitelogo_med.png"
cmp "$pix/ornyx-ink.png" "$pix/fedora_logo_med.png"
if "$with_boot"; then
    snapshot=$(mktemp -d "$backup/boot-XXXXXXXX")
    cp -a /boot/loader/entries /etc/default/grub "$snapshot/"
    cp -a /etc/plymouth "$snapshot/"
    echo "Saved boot configuration in $snapshot"
    bash "$repo/scripts/brand-boot.sh" "$stage"
    grep '^title' /boot/loader/entries/"$(cat /etc/machine-id)"-*.conf
    plymouth-set-default-theme
fi
hostnamectl status
