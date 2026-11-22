# Ornyx GNOME

Ornyx uses Fedora's GNOME 51 Wayland session and GDM. The [edition input](../../iso/gnome.ks) imports the shared Fedora core and the [GNOME fragment](desktop.ks). The latter selects the mandatory portion of Fedora's `gnome-desktop` group, then adds the [desktop packages](../../packages/gnome.txt). The resulting input still needs the storage and installer configuration from a future compose phase.

## Desktop experience

The native top bar, Activities overview, overview dash, keyboard shortcuts and window controls retain GNOME behavior. Workspaces are dynamic. The dash starts with Brave, Files and Ptyxis. Native motion, reduced-motion preferences, focus indicators, high contrast, scaling and Orca remain available. Ornyx adds zero Shell extensions, custom GTK themes or autostart entries.

The [GSettings override](90-ornyx.gschema.override) selects dark mode, the native red accent, Adwaita icons and cursor, regular Inter Variable at 11 pt, and Fold in both appearance modes. The wallpaper also appears in Settings through [GNOME's wallpaper catalog](wallpapers.xml). See the [visual specification](../../branding/README.md) for colors and licensing.

| Task | Application |
| --- | --- |
| Web browsing | Brave stable |
| Files and archives | Files (Nautilus) and Archive Manager (File Roller) |
| Terminal | Ptyxis |
| Text and images | GNOME Text Editor and Image Viewer (Loupe) |
| Settings and applications | GNOME Settings and GNOME Software |

Users can change wallpaper, appearance and default applications in Settings. `gsettings reset SCHEMA KEY` restores an individual setting to the edition default. User overrides take precedence. To restore vendor defaults in a disposable guest, remove only the Ornyx-installed override and MIME file after confirming ownership, recompile the schema directory and sign in again. For a clean rollback of all guest changes restore its pre-test snapshot.

## Browser source and recovery

The [GNOME browser manifest](../../packages/gnome-browser.txt) is consumed by the [reusable RPM installer](../../scripts/install-brave.sh) during the target system's fatal-on-error Kickstart post section. This separate transaction keeps the third-party repository out of the Fedora base resolution. The installer fetches Brave's official stable repository definition and public key bundle over HTTPS, checks both SHA256 pins, and asks DNF5 to select Brave from that repository with RPM signature checking enabled. Dependencies can come from Fedora. The official repository stays enabled for updates. [Brave's Fedora instructions](https://brave.com/linux/) Â· [Brave's signing keys](https://brave.com/signing-keys/)

An unavailable repository, changed pin, invalid signature or conflicting configuration stops provisioning. Check guest connectivity, DNS and time first. For a key or repository change, compare the official signing-key publication and stable repository, verify a current RPM, and submit updated pins for review. After resolving the cause, retry from the guest snapshot. For the browser transaction alone, an approved guest administrator can rerun `bash scripts/install-brave.sh < packages/gnome-browser.txt` as root. An identical existing repository file is accepted.

The [GNOME MIME defaults](gnome-mimeapps.list) select the RPM's visible `brave-browser.desktop` for web URLs, HTML and XHTML. The browser uses its vendor icon, first-run behavior and privacy controls. Ornyx supplies no browser profile, policies, sync settings or login launcher. Verify effective user associations and actual dispatch using the [session checks](../../tests/README.md).
