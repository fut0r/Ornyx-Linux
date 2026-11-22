# Fedora base and maintenance

The target is x86_64. The only release pin is [iso/fedora-release](../iso/fedora-release). On 22 November 2026 Fedora listed the selected release as stable and Bodhi reported its state as `current`. Recheck support before each release. [Fedora downloads](https://fedoraproject.org/workstation/download/) · [Bodhi verification record](https://bodhi.fedoraproject.org/releases/F45)

Use the official `fedora` and `updates` binary repositories with Fedora's RPM signature checks. On an installed system, review the transaction from `dnf upgrade --refresh` before approving it with administrator privileges. Reboot after kernel updates. The shared layer adds no unattended updater, repository override or major-version upgrade trigger.

## Release migration

Open a reviewed change to the pin. Confirm the candidate is stable and supported, review Fedora's release notes and retirement list, and verify both manifests against the candidate's x86_64 repositories. Run the shared and Kickstart checks with the new grammar. Before shipping, resolve the full transactions, capture repository metadata checksums, exact RPM versions and build tool versions, then test both editions on UEFI and Secure Boot VMs. Test an explicit Fedora system upgrade separately from fresh installs. The pin selects a major release; rolling updates require a recorded snapshot to reproduce a particular build.

## Builder and hardware coverage

Use a disposable x86_64 Fedora VM matching the pin. A dedicated Fedora VM on the existing hypervisor is sufficient. QEMU/KVM on a Linux builder with UEFI firmware also supports boot testing. A container can run input checks, but image assembly and firmware tests belong in the VM. Keep the writable checkout, scratch disk and build output in the guest; keep host disks detached. Provide outbound access to Fedora repositories and enough scratch space for package caches and image output. Provision build tools only after approval for guest administration.

The shared manifest selects Fedora's kernel, firmware, Mesa and signed x86_64 UEFI boot packages. Preserve the Fedora boot chain when choosing image tooling. No partition layout, bootloader edits or signing keys are part of these inputs. Verify Secure Boot with enrolled Fedora-compatible trust keys and the actual composed media. Test Intel and AMD graphics, Wi-Fi, Ethernet, Bluetooth, PipeWire audio, SATA and NVMe separately. NVIDIA support depends on the upstream kernel, Mesa, device generation and firmware. Proprietary NVIDIA drivers require separate evaluation. These selections have not been boot-tested.
