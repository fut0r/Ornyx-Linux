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
