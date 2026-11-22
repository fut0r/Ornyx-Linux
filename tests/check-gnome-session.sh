#!/usr/bin/env bash
# Run as a fresh, signed-in GNOME test user in the isolated Fedora guest.
set -euo pipefail
case ":${XDG_CURRENT_DESKTOP:-}:" in
    *:GNOME:*) ;;
    *) echo "A running GNOME session is required." >&2; exit 1 ;;
esac

expect() {
    if [[ $1 != "$2" ]]; then
        printf 'Expected %s, got %s\n' "$2" "$1" >&2
        exit 1
    fi
}

expect "$(xdg-settings get default-web-browser)" brave-browser.desktop
for type in x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml; do
    expect "$(xdg-mime query default "$type")" brave-browser.desktop
done
for association in \
    inode/directory=org.gnome.Nautilus \
    text/plain=org.gnome.TextEditor \
    image/jpeg=org.gnome.Loupe \
    image/png=org.gnome.Loupe \
    image/webp=org.gnome.Loupe \
    application/zip=org.gnome.FileRoller \
    application/x-tar=org.gnome.FileRoller \
    application/x-compressed-tar=org.gnome.FileRoller; do
    expect "$(xdg-mime query default "${association%=*}")" "${association#*=}.desktop"
done
desktop=/usr/share/applications/brave-browser.desktop
test -r "$desktop"
grep -qx 'Icon=brave-browser' "$desktop"
test -x /usr/bin/brave-browser-stable
expect "$(gsettings get org.gnome.desktop.interface font-name)" "'Inter Variable 11'"
expect "$(fc-match -f '%{family}' 'Inter Variable')" "Inter Variable"
expect "$(gsettings get org.gnome.desktop.interface accent-color)" "'red'"
expect "$(gsettings get org.gnome.desktop.interface color-scheme)" "'prefer-dark'"
for key in picture-uri picture-uri-dark; do
    expect "$(gsettings get org.gnome.desktop.background "$key")" "'file:///usr/share/backgrounds/ornyx/fold.svg'"
done
test -r /usr/share/backgrounds/ornyx/fold.svg
test -r /usr/share/icons/Adwaita/cursors/left_ptr
test -r /usr/share/icons/Adwaita/index.theme
rpm -q brave-browser gnome-shell
echo "Fresh-session browser associations, wallpaper, typography and appearance checks passed."
