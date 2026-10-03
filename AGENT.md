# AGENT.md - Chezmoi Pentest Configuration

## Overview
This chezmoi configuration manages dotfiles and system packages for multiple device profiles with a focus on penetration testing workstations.

## Device Profiles

| Hostname | Device Type | GUI | VPN | Pentest | WiFi | Container | Virtualization |
|----------|-------------|-----|-----|---------|------|-----------|----------------|
| vm-dev | vm | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| laptop | laptop | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| desktop | desktop | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| matrix.home.lan | server | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

Flags live in `private_dot_config/chezmoi/chezmoi.toml.tmpl` (`pentest`, `wifi`, ...).

## Package Categories

### Base (Always)
Core system packages: base-devel, tmux, npm, git, zsh, neovim, mise, direnv, uv, kubectl, helm, k9s, sops, age, ripgrep, fd, bat, fzf, btop, fastfetch, eza, yq, jq, bitwarden-cli, python-pipx, reflector, opencode

### GUI ($gui)
KDE Plasma: plasma-meta, plasma-nm, kdeplasma-addons, dolphin, kmail, remmina, discord, brave-bin, ghostty, ark, okular, gwenview, filelight, cups, mpv

### VPN ($vpn)
NetBird: netbird-bin, netbird-ui-bin

### Pentest ($pentest) — 78 packages
Resolved by `paru` across three repos (BlackArch, Arch official, AUR) — origins
per package in `.chezmoidata/packages.yaml`:

**OSINT:** amass, subfinder, holehe, sherlock
**Network:** nmap, masscan, rustscan, wireshark-cli, wireshark-qt, netdiscover, tcpdump, arp-scan, socat, proxychains-ng, openbsd-netcat, nbtscan, smbclient, testssl.sh, ssh-audit
**Vuln Scanners:** nikto, nuclei
**Wordlists:** seclists
**Web:** burpsuite, zaproxy, sqlmap, ffuf, feroxbuster, gobuster, wpscan, whatweb, wafw00f, arjun, dalfox, httpx, tlsx, uncover, proxify, katana-pd (BlackArch — NOT AUR `katana`, which is a Foundry VFX tool)
**AD/Windows:** netexec, responder, impacket, bloodhound-python, bloodhound-ce-python, enum4linux-ng, smbmap, evil-winrm, coercer, bloodyad, kerbrute, pkinittools
**WiFi ($wifi only):** aircrack-ng, wifite, hcxdumptool, hcxtools, bettercap, kismet
**Container:** trivy, grype
**Exploit/Post:** metasploit, sliver, chisel, ligolo-ng, pspy, peass-ng (AUR), exploitdb-git (AUR)
**Cracking:** hashcat, john, hydra, cewl, crunch, patator, medusa
**RE:** ghidra, radare2, gdb, ropper, one_gadget, python-pwntools

Not used: Greenbone/OpenVAS suite (removed — heavy AUR builds, feed sync), legacy
BloodHound v4 GUI (replaced by BloodHound CE).

### Container ($container)
Podman: podman, podman-compose, podman-docker

### Virtualization ($virtualization)
libvirt, qemu-desktop, virt-manager, dnsmasq, bridge-utils, ebtables, vde2

## External Tools (run_onchange_after_40-pentest-extras.sh)

Installed via pipx/binaries — only tools absent from ALL repos:

| Tool | Method | Purpose |
|------|--------|---------|
| ldapdomaindump | pipx | AD LDAP dumper |
| syft | binary | SBOM generator |
| hadolint | binary | Dockerfile linter |
| dive | binary | Docker image layer inspector |
| docker-bench-security | binary | CIS Docker benchmark |

Everything else lives in `packages.yaml` (theharvester, dnsrecon, recon-ng,
sslyze, enum4linux-ng, certipy, bloodhound-ce-python, evil-winrm, grype and
searchsploit/exploitdb-git are all packaged).

Container aliases (bloodhound-gui, spiderfoot, dradis, faraday) are a managed
file: `private_dot_config/zsh/env/pentest-docker.zsh`.

## Scripts Execution Order

`chezmoi` runs `before` scripts, then the file state, then `after` scripts,
alphabetically within each phase:

1. `00-create-folders.sh` - Create directories (before)
2. `01-bootstrap-paru.sh` - Install paru AUR helper (before)
3. `05-setup-blackarch.sh` - Add BlackArch repo, needs sudo + TTY (before)
4. `10-generate-ssh-key.sh` - SSH key + pubkey registry (before)
5. *(file state applied)*
6. `20-install-packages.sh` - paru install of the full list (after, onchange)
7. `30-pacman-cleanup.sh` - Deploy weekly pacman cleanup timer (after, once)
8. `40-pentest-extras.sh` - External pentest tools (after, onchange)
9. `50-deploy-ssh-keys.sh` - Propagate pubkeys (after, onchange)
10. `60-setup-nfs.sh` - NFS mount units (after, once)
11. `70-prune-packages.sh` - Offer removal of packages dropped from lists (after)
12. `80-mirror-optimize.sh` - Deploy reflector + BlackArch mirror optimizer (after, onchange)

## Mirror Management

`80-mirror-optimize.sh` deploys two systemd timers covering ALL repos:

- **Arch official** → `reflector.timer` (daily): rewrites
  `/etc/pacman.d/mirrorlist` with the 15 fastest HTTPS mirrors
  (conf: `/etc/xdg/reflector/reflector.conf`, managed by the script)
- **BlackArch** → `blackarch-mirror-optimize.timer` (weekly): probes all 123
  candidates (latency + 256 KiB speed test on `blackarch.db`, 8-way parallel),
  rewrites `/etc/pacman.d/blackarch-mirrorlist` (top 3 active, living mirrors
  sorted by speed, dead ones commented at the end; original preserved as
  `*.strap-backup`)

Both run once immediately at deploy.

## Key Files

| File | Purpose |
|------|---------|
| `.chezmoidata/packages.yaml` | Package definitions by category (blackarch/aur/pacman keys) |
| `.chezmoitemplates/pkg-list.sh` | Template generating package list (flags: gui, vpn, pentest, wifi, ...) |
| `private_dot_config/chezmoi/chezmoi.toml.tmpl` | Device profile detection + hooks |
| `.chezmoiscripts/run_once_before_05-setup-blackarch.sh.tmpl` | BlackArch repo setup |
| `.chezmoiscripts/run_onchange_after_40-pentest-extras.sh.tmpl` | pipx + GitHub binaries |
| `.chezmoiscripts/run_onchange_after_80-mirror-optimize.sh.tmpl` | reflector + BlackArch mirror optimizer timers |
| `.chezmoihooks/install-password-manager.sh` | pre-read-source-state hook (bw CLI) |
| `.chezmoiscripts/.install-password-manager.sh` | Compat shim forwarding to the real hook — keeps stale deployed configs (old hook path) from blocking chezmoi; remove once all devices re-applied |
| `private_dot_config/zsh/env/pentest-docker.zsh` | Pentest container aliases |

## Manual Steps Required

1. **BlackArch repo** (requires TTY for sudo, automatic on interactive apply):
   ```bash
   curl -fsSL https://blackarch.org/strap.sh | sudo bash
   ```

2. **Apply chezmoi** (interactive terminal):
   ```bash
   chezmoi apply
   ```

## Troubleshooting

- **BlackArch keyring errors**: Re-run strap.sh
- **pipx missing**: `paru -S python-pipx`
- **Extras not re-run**: the script is `run_onchange_` — edit it and apply again
- **Aliases missing**: they need `docker` or `podman` on the machine
- **Prune refuses to remove a package**: expected — packages still required by
  an installed package are kept automatically (e.g. `aircrack-ng` stays on
  wifi-less machines while `katana-framework` depends on it)
