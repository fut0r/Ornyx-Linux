services --enabled=gdm

%packages
@gnome-desktop --nodefaults
%include ../../packages/gnome.txt
%end

%post --interpreter=/usr/bin/bash --erroronfail
set -euo pipefail
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT

# Feed the edition manifest to the same installer that another edition can use.
cat > "$stage/install-brave.sh" <<'BRAVE_SCRIPT'
%include ../../scripts/install-brave.sh
BRAVE_SCRIPT
bash "$stage/install-brave.sh" <<'BROWSER_PACKAGES'
%include ../../packages/gnome-browser.txt
BROWSER_PACKAGES

install_default() {
    local destination=$1
    cat > "$stage/default"
    if [[ -e $destination ]]; then
        cmp "$stage/default" "$destination" || { echo "Existing file differs: $destination" >&2; return 1; }
    else
        install -D -m 0644 "$stage/default" "$destination"
    fi
}
install_default /usr/share/backgrounds/ornyx/fold.svg <<'SVG'
%include ../../branding/wallpapers/fold.svg
SVG
install_default /usr/share/gnome-background-properties/ornyx.xml <<'WALLPAPERS'
%include wallpapers.xml
WALLPAPERS
install_default /usr/share/glib-2.0/schemas/90-ornyx.gschema.override <<'SETTINGS'
%include 90-ornyx.gschema.override
SETTINGS
install_default /etc/xdg/gnome-mimeapps.list <<'ASSOCIATIONS'
%include gnome-mimeapps.list
ASSOCIATIONS
glib-compile-schemas --strict /usr/share/glib-2.0/schemas
systemctl set-default graphical.target
%end
