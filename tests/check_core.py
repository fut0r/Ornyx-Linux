"""Check the shared Kickstart inputs from Windows or Fedora using Python 3."""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read_manifest(name):
    path = ROOT / "packages" / name
    names = path.read_text(encoding="utf-8").splitlines()
    if not names or names != sorted(set(names)):
        raise ValueError(f"{path}: expected sorted, unique package names")
    for package in names:
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9.+_-]*", package):
            raise ValueError(f"{path}: invalid package name {package!r}")
    return set(names)


def includes(path):
    targets = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("%include "):
            target = (path.parent / line.split(maxsplit=1)[1]).resolve()
            if not target.is_relative_to(ROOT) or not target.is_file():
                raise ValueError(f"{path}: invalid include {target}")
            targets.append(target)
    return targets


def check():
    release = (ROOT / "iso/fedora-release").read_text().strip()
    if not re.fullmatch(r"[1-9][0-9]+", release):
        raise ValueError("expected a numeric stable Fedora release")
    common = read_manifest("common.txt")
    build = read_manifest("build.txt")
    if common & build:
        raise ValueError(f"build tools in runtime: {sorted(common & build)}")
    for name in common:
        if name.lower().startswith(("gnome-", "kde-", "plasma-", "kf5-", "kf6-")) or name in {"gdm", "sddm", "kwin", "mutter"}:
            raise ValueError(f"desktop package in shared manifest: {name}")
    system = ROOT / "config/common/system.ks"
    for edition in ("gnome", "kde"):
        if includes(ROOT / f"iso/{edition}.ks").count(system) != 1:
            raise ValueError(f"{edition}: expected one shared system include")
    if includes(system) != [ROOT / "packages/common.txt"]:
        raise ValueError("shared Kickstart must use the common runtime manifest")
    print(f"Fedora {release}: both editions share {len(common)} runtime packages; {len(build)} builder package(s)")


if __name__ == "__main__":
    try:
        check()
    except (OSError, ValueError) as error:
        sys.exit(str(error))
