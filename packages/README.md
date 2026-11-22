# Package manifests

[common.txt](common.txt) lists explicit runtime additions to Kickstart's implicit Fedora core group. DNF resolves their dependencies. Both edition entry points include this file through the shared system definition. Keep each manifest sorted, one RPM name per line. [build.txt](build.txt) contains the Fedora VM's validation tooling only. Select image composition tools when a build method is chosen.

The kernel and linux-firmware supply drivers and device firmware; microcode_ctl supplies Intel CPU updates. Mesa supplies userspace graphics. shim-x64 and grub2-efi-x64 preserve Fedora's x86_64 EFI components. NetworkManager-wifi adds wireless support, and bluez provides Bluetooth. The PipeWire ALSA and PulseAudio compatibility packages serve applications using those APIs on the same audio stack. The filesystem tools cover Btrfs, ext filesystems, FAT EFI partitions and LUKS volumes. pciutils, usbutils, iproute and iputils support device and network diagnosis.

The initial names were checked against the official Fedora Everything release repository, accepting x86_64 and noarch RPMs. Its repomd revision was `1793218669`, with SHA256 `ac48b5bd2c3127d576c86b5756921d4ad02fabb33f2f9c5da89d683231b8f774` for compressed primary metadata. This identifies the availability check; a complete image transaction still needs resolution.

Record the Fedora release, architecture and repository snapshot used to resolve packages alongside the image inputs. Preserve the resolved package versions with each build so a later rebuild can be compared.
