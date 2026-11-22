#!/usr/bin/env bash
set -euo pipefail
stage=${1:?expected staging directory}
# shellcheck disable=SC1091
source /etc/os-release
[[ $ID == ornyx ]]
if [[ -f /etc/default/grub ]]; then
    sed -i '/^GRUB_DISTRIBUTOR=/d' /etc/default/grub
    printf 'GRUB_DISTRIBUTOR="%s"\n' "$PRETTY_NAME" >> /etc/default/grub
fi
# Future Fedora BLS entries read NAME from /etc/os-release.
for entry in /boot/loader/entries/"$(cat /etc/machine-id)"-*.conf; do
    [[ -f $entry ]] || continue
    sed -i -E "s/^title([[:space:]]+)(Fedora( Linux)?|Ornyx Linux( [0-9]+)?) (\([^)]*\))( (45|$VERSION_ID))?( \(Workstation Edition\))?/title\1$PRETTY_NAME \5/" "$entry"
done

themes=/usr/share/plymouth/themes
install -d "$themes/ornyx"
cp "$themes/spinner/"*.png "$themes/ornyx/"
install -m0644 "/usr/share/pixmaps/ornyx-linux.png" "$themes/ornyx/watermark.png"
sed -e '/^Name\[/d' -e 's/^Name=.*/Name=Ornyx Linux/' \
    -e "s|^ImageDir=.*|ImageDir=$themes/ornyx|" \
    "$themes/spinner/spinner.plymouth" > "$themes/ornyx/ornyx.plymouth"
plymouth-set-default-theme ornyx
# Keep the rescue image available throughout. Replace normal images only
# after dracut succeeds and the new archive contains the branded artwork.
for modules in /usr/lib/modules/*; do
    version=${modules##*/}
    image=/boot/initramfs-$version.img
    [[ -f /boot/vmlinuz-$version ]] || continue
    temporary=$(mktemp "/boot/.ornyx-initramfs.XXXXXXXX")
    trap 'rm -f -- "$temporary"' EXIT
    dracut --force --add plymouth "$temporary" "$version"
    lsinitrd "$temporary" usr/share/plymouth/themes/ornyx/watermark.png > "$stage/embedded.png"
    cmp "$themes/ornyx/watermark.png" "$stage/embedded.png"
    if [[ -f $image ]]; then
        chcon --reference="$image" "$temporary"
    fi
    mv -fT "$temporary" "$image"
    restorecon "$image"
    trap - EXIT
done
