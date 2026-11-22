#!/usr/bin/env bash
# Install the OS identity and persistent About artwork bindings.
set -euo pipefail
stage=${1:?expected staging directory}
# Replace the target's /etc symlink atomically, preserving the RPM's vendor file.
# shellcheck disable=SC1091
source /usr/lib/os-release
[[ $ID == fedora && $VERSION_ID == 45 ]]
ornyx_version=1
cat > "$stage/os-release" <<RELEASE
NAME="Ornyx Linux"
PRETTY_NAME="Ornyx Linux $ornyx_version"
ID=ornyx
ID_LIKE="fedora"
VERSION="$ornyx_version"
VERSION_ID="$ornyx_version"
PLATFORM_ID="platform:f$VERSION_ID"
DEFAULT_HOSTNAME=ornyx
LOGO=ornyx-linux
HOME_URL="https://github.com/fut0r/Ornyx-Linux"
BUG_REPORT_URL="https://github.com/fut0r/Ornyx-Linux/issues"
RELEASE
install -Dm0644 "$stage/os-release" /etc/ornyx/os-release
# fedora-release-common owns the public symlink. Restore our local selection
# at boot even if an RPM update has reinstated the vendor link.
install -d /etc/tmpfiles.d
printf '%s\n' 'L+ /etc/os-release - - - - ornyx/os-release' > /etc/tmpfiles.d/00-ornyx-identity.conf
systemd-tmpfiles --create /etc/tmpfiles.d/00-ornyx-identity.conf
cmp /etc/ornyx/os-release /etc/os-release
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
