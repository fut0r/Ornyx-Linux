# ISO build inputs

[gnome.ks](gnome.ks) and [kde.ks](kde.ks) each import the same shared system definition. They are composition fragments. Installer, storage layout, edition packages and live-media settings belong to later phases. The future compose command must read [fedora-release](fedora-release) for its release version and restrict resolution to the official x86_64 Fedora release and updates repositories. Run the [input checks](../tests/README.md) before composition.

Capture the source revision, Fedora release, architecture, repository snapshot, resolved package versions and build-tool versions for each build. Write intermediate files under repository-root `build/` and export completed images and their metadata under `out/`. See the [release policy](../docs/releases.md).
