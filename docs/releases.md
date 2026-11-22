# Releases

GitHub is the official source repository. Develop on topic branches and merge reviewed work into main. Keep development output under `build/` and `out/` at the repository root. ISO files stay out of ordinary Git history.

For a future official release, tag the reviewed source revision and build both editions from documented inputs. Use distinct filenames containing the version, edition and architecture. From the output directory, generate a SHA256SUMS file with `sha256sum *.iso > SHA256SUMS` in a directory containing only the intended release images. Verify the files with `sha256sum --check SHA256SUMS`.

Attach the verified images and SHA256SUMS to the matching GitHub Release. Include release notes covering the Fedora base, changes, known issues and verification steps. The first release is **Ornyx Linux 1**, built on the [Fedora 45 base](fedora-base.md).
