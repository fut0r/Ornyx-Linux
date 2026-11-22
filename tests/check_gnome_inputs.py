"""Validate expanded edition inputs with Fedora's pykickstart and schema XML."""

import argparse
import ast
import configparser
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

from pykickstart.parser import KickstartParser
from pykickstart.version import makeVersion

from check_core import ROOT, read_manifest


def validate_settings(directory):
    schemas = {}
    enums = {}
    for path in directory.glob("*.xml"):
        tree = ET.parse(path)
        schemas.update((node.get("id"), node) for node in tree.findall("schema"))
        for enum in tree.findall("enum"):
            enums[enum.get("id")] = {value.get("nick") for value in enum.findall("value")}
    settings = configparser.ConfigParser()
    with (ROOT / "config/gnome/90-ornyx.gschema.override").open() as stream:
        settings.read_file(stream)
    for section in settings.sections():
        for name, value in settings[section].items():
            key = schemas[section].find(f"key[@name='{name}']")
            if key is None:
                raise ValueError(f"Missing schema key {section}.{name}")
            if key.get("enum"):
                valid = ast.literal_eval(value) in enums[key.get("enum")]
            elif key.get("type") == "b":
                valid = value in ("true", "false")
            else:
                parsed = ast.literal_eval(value)
                valid = (key.get("type") == "s" and isinstance(parsed, str)) or (
                    key.get("type") == "as" and isinstance(parsed, list)
                    and all(isinstance(item, str) for item in parsed)
                )
            if not valid:
                raise ValueError(f"Invalid value for {section}.{name}: {value}")


def validate_editions():
    release = (ROOT / "iso/fedora-release").read_text().strip()
    common = read_manifest("common.txt")
    desktop = read_manifest("gnome.txt")
    if read_manifest("gnome-browser.txt") != {"brave-browser"} or common & desktop:
        raise ValueError("Check edition package ownership")
    for name in ("gnome", "kde"):
        parser = KickstartParser(makeVersion(f"F{release}"), followIncludes=True)
        parser.readKickstart(str(ROOT / f"iso/{name}.ks"))
        packages = set(parser.handler.packages.packageList)
        if name == "gnome":
            if packages != common | desktop or "gnome-desktop" not in {
                group.name for group in parser.handler.packages.groupList
            }:
                raise ValueError("Incomplete GNOME package selection")
            post = "\n".join(script.script for script in parser.handler.scripts)
            for path in ("branding/wallpapers/fold.svg", "config/gnome/wallpapers.xml",
                         "config/gnome/90-ornyx.gschema.override", "config/gnome/gnome-mimeapps.list",
                         "packages/gnome-browser.txt"):
                if (ROOT / path).read_text().strip() not in post:
                    raise ValueError(f"GNOME post section is missing {path}")
        elif "xdg-desktop-portal-gnome" in packages or any(
            "90-ornyx.gschema.override" in script.script for script in parser.handler.scripts
        ):
            raise ValueError("GNOME inputs leaked into KDE")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--schemas", type=Path, default=Path("/usr/share/glib-2.0/schemas"))
    args = cli.parse_args()
    try:
        validate_settings(args.schemas)
        validate_editions()
    except (OSError, KeyError, ValueError) as error:
        sys.exit(f"GNOME input validation failed: {error}")
    print("GNOME schema settings, package composition and embedded desktop files verified.")
