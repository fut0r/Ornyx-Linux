#!/usr/bin/env bash
# Run inside the x86_64 installation target.
set -euo pipefail
stage=${1:?expected staging directory}
key=/etc/pki/rpm-gpg/ornyx-microsoft.asc
curl -fsSL --proto '=https' --proto-redir '=https' https://packages.microsoft.com/keys/microsoft.asc -o "$stage/microsoft.asc"
echo "2fa9c05d591a1582a9aba276272478c262e95ad00acf60eaee1644d93941e3c6  $stage/microsoft.asc" | sha256sum -c -
install -Dm0644 "$stage/microsoft.asc" "$key"
cat > "$stage/vscode.repo" <<REPO
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=file://$key
includepkgs=code
REPO
repo=/etc/yum.repos.d/vscode.repo
if [[ -e $repo ]]; then cmp "$stage/vscode.repo" "$repo"; else install -m0644 "$stage/vscode.repo" "$repo"; fi
dnf5 -y --repo=fedora --repo=updates --repo=code install --from-repo=code code

flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --system --no-filter flathub
flatpak install --system --noninteractive flathub \
    app/com.valvesoftware.Steam/x86_64/stable \
    runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE/x86_64/stable \
    app/com.mattjakeman.ExtensionManager/x86_64/stable \
    app/org.videolan.VLC/x86_64/stable
