# Validation

Run `python tests/check_core.py` from the repository root with Python 3.9 or newer. It checks the release pin, both edition includes, manifest syntax, sorting, duplicates, builder separation and common desktop package names. Review new packages and resolved dependencies for desktop coupling as well.

With pykickstart available in the Fedora VM, run the native grammar check from the directory containing the edition entry points. This working directory lets ksvalidator resolve includes when it stages its input.

```bash
(cd iso && ksvalidator -i -v "F$(cat fedora-release)" gnome.ks kde.ks)
```

In the matching x86_64 Fedora VM, verify availability after each manifest or pin change. Run the following from the repository root with Bash and DNF5. The final comparison must be empty and exit successfully.

```bash
set -euo pipefail
export LC_ALL=C
release=$(cat iso/fedora-release)
mkdir -p build
sort -u packages/common.txt packages/build.txt > build/expected-packages.txt
mapfile -t names < build/expected-packages.txt
dnf5 --releasever="$release" --repo=fedora --repo=updates repoquery \
    --arch=x86_64,noarch --queryformat='%{name}\n' "${names[@]}" |
    sort -u > build/available-packages.txt
diff -u build/expected-packages.txt build/available-packages.txt
```

From the repository root, run `git diff --check` for working changes and `git diff --cached --check` for staged changes. Check relative documentation links and verify that each changed GitHub issue form parses as YAML. Use `git check-ignore build/test.log out/test.iso sample.iso` to confirm artifact exclusions.

When image definitions arrive, test each affected edition on x86_64 and record the input revision and result. Changes to shared inputs require checks on both GNOME and KDE. Keep test output in the ignored build directory.

## GNOME integration

On the Fedora GNOME builder, run `python tests/check_gnome_inputs.py` with pykickstart available. To validate offline, pass `--schemas DIRECTORY` pointing to the combined schema XML from the target Fedora gsettings-desktop-schemas, gnome-shell-common and mutter-common RPMs.

Run the Kickstart grammar check above with includes enabled. Check the browser installer and session check with `shellcheck scripts/install-brave.sh tests/check-gnome-session.sh`. Include `packages/gnome.txt` in the Fedora repoquery check for GNOME changes. Check the browser manifest against Brave's stable repository separately.

Use a disposable Fedora Workstation VM matching the release pin. Apply the GNOME inputs to a clean test target, snapshot before provisioning, and sign in to GNOME as a fresh, unprivileged user. Run `bash tests/check-gnome-session.sh`. Open the overview and launch Brave by name; verify its icon, then close the window. From the same session run `gio open http://example.org/` and `gio open https://example.org/` separately. Confirm both open in Brave, including the HTTP request if Brave upgrades it to HTTPS. Check that clicking a link in another app opens Brave as well. These are interactive acceptance checks.

Verify the wallpaper in both color modes, the overview dash, Super-key navigation, workspace creation, text scaling and high contrast. Change the wallpaper and browser in Settings, sign out and back in, and confirm both choices persist. Record Fedora, GNOME and browser versions with the results.
