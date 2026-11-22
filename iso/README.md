# ISO build inputs

Keep Fedora Kickstart definitions and image composition inputs here. A future edition entry point should select the shared system configuration and packages, then apply only that desktop's settings and package selection.

Capture the source revision, Fedora release, architecture, repository snapshot, resolved package versions and build-tool versions for each build. Write intermediate files under repository-root `build/` and export completed images and their metadata under `out/`. See the [release policy](../docs/releases.md).
