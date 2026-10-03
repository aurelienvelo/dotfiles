# Chezmoi Dotfiles with Pentest Setup

Automated dotfiles and package management for Arch Linux workstations with integrated penetration testing toolkit via BlackArch.

## Features

- **Multi-device profiles**: laptop, desktop, vm-dev, server
- **Category-based packages**: base, gui, vpn, pentest, container, virtualization
- **BlackArch + official repos**: 78 pentest packages (BlackArch, core/extra, AUR)
- **External tools**: pipx and GitHub binaries for the few tools in no repo
- **Automated scripts**: explicit before/after phases with numbered execution order

## Quick Start

### Prerequisites
- Arch Linux (or Arch-based)
- `chezmoi` installed
- `paru` AUR helper (installed by bootstrap script)

### Installation

```bash
# Clone and apply
chezmoi init https://github.com/USER/chezmoi.git
chezmoi apply   # dans un terminal (sudo/TTY requis)
```

### Manual Steps (Required)

1. **Install BlackArch repository** (requires sudo + TTY) — automatic when
   `chezmoi apply` runs interactively, otherwise:
   ```bash
   curl -fsSL https://blackarch.org/strap.sh | sudo bash
   ```

2. **Re-apply to install packages**:
   ```bash
   chezmoi apply
   ```

Everything else (packages, external tools, aliases) is applied automatically.

## Device Profiles

| Profile | GUI | VPN | Pentest | WiFi | Container | Virtualization |
|---------|-----|-----|---------|------|-----------|----------------|
| **laptop** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **desktop** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **vm-dev** | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **server** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

Detection via hostname in `chezmoi.toml.tmpl`. The `wifi` flag gates the WiFi
toolset (no radio in a VM).

## Package Categories

### Base (All Devices)
Essential CLI tools: `git`, `zsh`, `neovim`, `mise`, `direnv`, `uv`, `kubectl`, `helm`, `k9s`, `sops`, `age`, `ripgrep`, `fd`, `bat`, `fzf`, `btop`, `eza`, `yq`, `jq`, `bitwarden-cli`, `python-pipx`, `reflector`, `opencode`

### GUI (`$gui`)
KDE Plasma desktop: `plasma-meta`, `dolphin`, `kmail`, `remmina`, `discord`, `brave-bin`, `ghostty`, `ark`, `okular`, `cups`, `mpv`

### VPN (`$vpn`)
NetBird mesh VPN: `netbird-bin`, `netbird-ui-bin`

### Pentest (`$pentest`) — 78 packages

| Category | Tools |
|----------|-------|
| OSINT | amass, subfinder, holehe, sherlock |
| Network | nmap, masscan, rustscan, wireshark-cli, wireshark-qt, netdiscover, tcpdump, arp-scan, socat, proxychains-ng, openbsd-netcat, nbtscan, smbclient, testssl.sh, ssh-audit |
| Vuln Scanners | nikto, nuclei |
| Wordlists | seclists |
| Web | burpsuite, zaproxy, sqlmap, ffuf, feroxbuster, gobuster, wpscan, whatweb, wafw00f, arjun, dalfox, httpx, tlsx, uncover, proxify, katana-pd |
| AD/Windows | netexec, responder, impacket, bloodhound-python, bloodhound-ce-python, enum4linux-ng, smbmap, evil-winrm, coercer, bloodyad, kerbrute, pkinittools |
| WiFi (`$wifi`) | aircrack-ng, wifite, hcxdumptool, hcxtools, bettercap, kismet |
| Container | trivy, grype |
| Exploit/Post | metasploit, sliver, chisel, ligolo-ng, pspy, peass-ng, exploitdb-git |
| Cracking | hashcat, john, hydra, cewl, crunch, patator, medusa |
| RE | ghidra, radare2, gdb, ropper, one_gadget, python-pwntools |

Sources: BlackArch repository, Arch official repos (core/extra) and AUR —
resolved transparently by `paru`. Package origins are documented in
`.chezmoidata/packages.yaml`.

### Container (`$container`)
Podman stack: `podman`, `podman-compose`, `podman-docker`

### Virtualization (`$virtualization`)
Full KVM/libvirt: `libvirt`, `qemu-desktop`, `virt-manager`, `dnsmasq`, `bridge-utils`

## External Tools (Not in Any Repo)

Installed by `run_onchange_after_40-pentest-extras.sh` (re-runs whenever the
script changes):

| Tool | Method | Description |
|------|--------|-------------|
| ldapdomaindump | pipx | AD LDAP dumper |
| syft | binary | SBOM generator |
| hadolint | binary | Dockerfile linter |
| dive | binary | Docker image layer inspector |
| docker-bench-security | binary | CIS Docker benchmark |

Docker/Podman aliases (BloodHound CE GUI, SpiderFoot, Dradis, Faraday) live in
the chezmoi-managed file `~/.config/zsh/env/pentest-docker.zsh` — they are only
defined when a container runtime is available and never shadow an installed
binary.

## Scripts Execution Order

`chezmoi` runs `before` scripts first, then the file state, then `after`
scripts — each phase in alphabetical order. Numbered prefixes make the order
explicit:

```
BEFORE (alphabetical)
  00-create-folders.sh                # base directories
  01-bootstrap-paru.sh                # AUR helper
  05-setup-blackarch.sh               # BlackArch repo (sudo + TTY)
  10-generate-ssh-key.sh              # SSH key + pubkey registry

STATE
  dotfiles, configs, ...

AFTER (alphabetical)
  20-install-packages.sh   (onchange) # paru -Syu -needed of the full list
  30-pacman-cleanup.sh     (once)     # weekly systemd cleanup timer
  40-pentest-extras.sh     (onchange) # pipx + GitHub binaries
  50-deploy-ssh-keys.sh    (onchange) # propagate pubkeys over SSH
  60-setup-nfs.sh          (once)     # NFS mount units
  70-prune-packages.sh     (every)    # uninstall packages removed from the list
  80-mirror-optimize.sh    (onchange) # reflector + BlackArch mirror optimizer
```

`onchange` scripts re-run automatically when their content changes, so editing
the extras list or the package list is enough — no manual step.

## Mirror Management (All Repos)

Deployed by `80-mirror-optimize.sh`, which enables two systemd timers:

| Repo | Tool | Schedule | What it does |
|------|------|----------|--------------|
| Arch official (core/extra) | `reflector` | daily | Replaces `/etc/pacman.d/mirrorlist` with the 15 fastest HTTPS mirrors (rate test on the last 30). Config: `/etc/xdg/reflector/reflector.conf` (managed by this script). |
| BlackArch | `blackarch-mirror-optimize` | weekly | Probes all 123 candidates (latency + 256 KiB speed test on `blackarch.db`, 8-way parallel), rewrites the mirrorlist: top 3 active, living mirrors sorted by speed (commented), dead ones pushed to the end. Original kept as `blackarch-mirrorlist.strap-backup`. |

Both also run once immediately at deploy. Manual run:
```bash
sudo reflector @/etc/xdg/reflector/reflector.conf
sudo blackarch-mirror-optimize
```

## Configuration Files

| File | Purpose |
|------|---------|
| `.chezmoidata/packages.yaml` | Package definitions (origins: blackarch/aur/pacman) |
| `.chezmoitemplates/pkg-list.sh` | Package list generator |
| `private_dot_config/chezmoi/chezmoi.toml.tmpl` | Device detection + hooks |
| `.chezmoiscripts/*.sh(.tmpl)` | Lifecycle scripts |
| `.chezmoihooks/install-password-manager.sh` | pre-read-source-state hook |
| `private_dot_config/zsh/env/pentest-docker.zsh` | Pentest container aliases |

## Troubleshooting

### BlackArch Keyring Issues
```bash
sudo pacman -Sy archlinux-keyring blackarch-keyring
sudo pacman-key --populate archlinux blackarch
```

### Missing pipx
```bash
paru -S python-pipx
```

### Docker Aliases Not Working
They only activate with `docker` or `podman` installed and running:
```bash
sudo systemctl enable --now podman.socket   # provides docker CLI compat
```

### Removed Tools Still Installed
`chezmoi apply` detects packages you removed from `packages.yaml` and offers to
uninstall them (interactive prompt, see `70-prune-packages.sh`). Packages still
**required by another installed package** are automatically kept — e.g.
`aircrack-ng` stays on machines without WiFi as long as `katana-framework`
depends on it.

## License

Personal configuration - adapt for your own use.
