# Shared settings

[system.ks](system.ks) explicitly requests SELinux enforcing mode and an enabled firewall for both editions. Fedora supplies the targeted policy, firewalld zones and rules. The shared layer introduces no rule exceptions or additional listening services.

Use Fedora's account creation, PAM, file modes, shell environment and service presets. Credentials and user identities belong to the eventual installer flow. NetworkManager manages Ethernet and Wi-Fi; PipeWire and WirePlumber use Fedora's user-session defaults. Ornyx adds no analytics, personal-data collection, user-profile scripts or privileged background agents. Review upstream defaults again when selecting desktop packages.
