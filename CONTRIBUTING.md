# Contributing to Ornyx Linux

Read the [code of conduct](CODE_OF_CONDUCT.md) before participating. Use the bug form for reproducible failures and the feature form to discuss proposed changes. Include the affected edition, source revision and sanitized evidence. For a possible vulnerability, follow [SECURITY.md](SECURITY.md).

## Pull requests

Branch from current main. Keep each change focused and include any related documentation. Use a short imperative commit subject, for example `branding: document wordmark spacing`. Explain the reason for a change in the body when the diff alone cannot show it.

Open a pull request against main. Link the issue when available, identify affected editions, and list the exact checks run and their results. Explain any checks you could not run. Follow the [validation guide](tests/README.md).

## Engineering conventions

Prefer native Fedora tools, small changes and shared configuration where both editions need the same behavior. Keep desktop-specific settings in their edition directories. Choose native formats such as Kickstart and RPM specs for distribution inputs. Follow EditorConfig and existing file conventions.

Use Bash for small automation tasks and Python for more complex build tooling. Introduce a native utility only for a documented need. For C++, use a modern standard, RAII, standard library facilities and compiler warnings. For Rust, handle errors explicitly and keep dependencies small. Protect personal data in logs and examples.

## Licensing

Submit original code and configuration under GPL-3.0-or-later. Include provenance, license terms and required notices for third-party material. Follow the [branding specification](branding/README.md) for assets. Submit only material you have permission to contribute.
