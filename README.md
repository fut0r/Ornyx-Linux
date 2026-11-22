# Ornyx Linux

Ornyx Linux is a Fedora-based desktop project for x86_64 with a minimal, privacy-conscious default configuration. Ornyx GNOME is the default edition. Ornyx KDE is the alternative. Phase 01 establishes the repository and contributor workflow. Installable images and build instructions will follow in later phases.

## Source layout

| Directory | Contents |
| --- | --- |
| [config](config/README.md) | Shared system settings and separate GNOME and KDE settings |
| [packages](packages/README.md) | Package selection rules for common and edition manifests |
| [branding](branding/README.md) | Wordmark specification and asset licensing |
| [iso](iso/README.md) | Fedora image definitions and build input policy |
| [scripts](scripts/README.md) | Automation conventions |
| [tests](tests/README.md) | Foundation checks and edition test expectations |
| [docs](docs/releases.md) | Release and artifact policy |
| [.github](.github/) | Issue forms and pull request template |

Start with the [contribution guide](CONTRIBUTING.md). Report sensitive findings through the [security policy](SECURITY.md).

## License

Original project code and configuration are available under GPL-3.0-or-later. Recipients may use version 3 of the GNU General Public License or any later version. See [LICENSE](LICENSE) and the [asset licensing guidance](branding/README.md).
