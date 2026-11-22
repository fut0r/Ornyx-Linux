#!/usr/bin/env bash
# Run inside the Fedora target as root, with the browser manifest on stdin.
set -euo pipefail
mapfile -t packages
if (( ${#packages[@]} != 1 )) || [[ ${packages[0]} != brave-browser ]]; then
    echo "Expected the stable brave-browser RPM in the edition manifest." >&2
    exit 1
fi

base=https://brave-browser-rpm-release.s3.brave.com
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
cd "$work"
curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
    "$base/brave-core.asc" -o brave-core.asc
curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
    "$base/brave-browser.repo" -o brave-browser.repo
sha256sum --check <<'SUMS'
bf978bd03e49f6006568d99f620763bf43a6455f6209dff791f52ebc6239f738  brave-core.asc
f5fb17c619f73d4811838cbe85e2fe467511e79eea7fbee8a3a3d6ec37d40ea3  brave-browser.repo
SUMS

repo=/etc/yum.repos.d/brave-browser.repo
if [[ -e $repo ]]; then
    cmp brave-browser.repo "$repo" || { echo "Review existing Brave repository first." >&2; exit 1; }
else
    install -m 0644 brave-browser.repo "$repo"
fi
dnf5 --assumeyes --refresh --repo=fedora --repo=updates --repo=brave-browser \
    --setopt=brave-browser.skip_if_unavailable=False \
    --setopt=brave-browser.gpgcheck=True --setopt="brave-browser.gpgkey=file://$work/brave-core.asc" \
    install --from-repo=brave-browser "${packages[@]}"
rpm -q brave-browser
test -r /usr/share/applications/brave-browser.desktop
