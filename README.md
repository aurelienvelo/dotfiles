# Chezmoi Dotfiles with Pentest Setup

Automated dotfiles and package management for Arch Linux workstations with integrated penetration testing toolkit via BlackArch.

## Features

- **Multi-device profiles**: laptop, desktop, vm-dev, server
- **Category-based packages**: base, gui, vpn, pentest, container, virtualization
- **BlackArch + official repos**: 97 pentest packages (BlackArch, core/extra, AUR)
- **External tools**: GitHub binaries for the few tools in no repo
- **KDE Plasma appearance**: same dark theme, lock screen and login screen on every GUI device
- **System services & groups**: cups, bluetooth, libvirt, wireshark... enabled per profile
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

1. **Install BlackArch repository** (requires sudo + TTY): automatic when
   `chezmoi apply` runs interactively. `05-setup-blackarch` only runs
   strap.sh if its sha256 matches the pin in `.chezmoidata/blackarch.yaml`.
   On mismatch, compare the SHA1 with the one published on
   https://blackarch.org/downloads.html, then update the pin.

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

Hardware flags: `has_nvidia` (desktop: driver + OpenCL), `has_intel_gpu` (laptop: VA-API + OpenCL), `has_battery` (laptop), `snapshots` (laptop: snapper, btrfs).

Detection via hostname in `chezmoi.toml.tmpl`. The `wifi` flag gates the WiFi
toolset (no radio in a VM).

## Package Categories

### Base (All Devices)
Essential CLI tools: `git`, `zsh`, `neovim`, `mise`, `direnv`, `uv`, `kubectl`, `helm`, `k9s`, `sops`, `age`, `ripgrep`, `fd`, `bat`, `fzf`, `btop`, `eza`, `yq`, `jq`, `bitwarden-cli`, `python-pipx`, `reflector`, `opencode`, `claude-code`, `zsh-autosuggestions`, `zsh-syntax-highlighting`; DevOps: `github-cli`, `pre-commit`, `gitleaks`, `opentofu`, `ansible`

### GUI (`$gui`)
KDE Plasma desktop: `plasma-meta` (pulls plasma-login-manager, plasma-nm, print-manager, breeze-gtk, kde-gtk-config, kwallet-pam, spectacle...), `dolphin`, `kmail`, `remmina`, `discord`, `brave-bin`, `ghostty`, `ark`, `okular`, `cups`, `mpv`, `kio-admin`, `kdeconnect`

### VPN (`$vpn`)
NetBird mesh VPN: `netbird-bin`, `netbird-ui-bin`

### Pentest (`$pentest`) — 97 packages

| Category | Tools |
|----------|-------|
| OSINT | amass, subfinder, holehe, sherlock, theharvester, dnsrecon, recon-ng, spiderfoot, dnsx |
| Network | nmap, masscan, rustscan, wireshark-cli, wireshark-qt, netdiscover, tcpdump, arp-scan, socat, proxychains-ng, openbsd-netcat, nbtscan, smbclient, testssl.sh, ssh-audit, sslyze, naabu, mitmproxy |
| Vuln Scanners | nikto, nuclei, nuclei-templates |
| Wordlists | seclists |
| Web | burpsuite, zaproxy, sqlmap, ffuf, feroxbuster, gobuster, wpscan, whatweb, wafw00f, arjun, dalfox, httpx, tlsx, uncover, proxify, katana-pd, gowitness, caido-desktop |
| AD/Windows | netexec, responder, impacket, bloodhound-python, bloodhound-ce-python, enum4linux-ng, smbmap, evil-winrm, coercer, bloodyad, kerbrute, pkinittools, certipy, python-ldapdomaindump, mitm6, krbrelayx |
| WiFi (`$wifi`) | aircrack-ng, wifite, hcxdumptool, hcxtools, bettercap, kismet |
| Container | trivy, grype, syft, dive |
| Exploit/Post | metasploit, sliver, chisel, ligolo-ng, pspy, peass, exploitdb |
| Cracking | hashcat, john, hydra, cewl, crunch, patator, medusa, hashcat-utils (+ OpenCL: `opencl-nvidia` with `has_nvidia`, `intel-compute-runtime` with `has_intel_gpu`) |
| RE | ghidra, radare2, gdb, ropper, one_gadget, python-pwntools, pwndbg |

Sources: BlackArch repository, Arch official repos (core/extra) and AUR —
resolved transparently by `paru`. Package origins are documented in
`.chezmoidata/packages.yaml`. Renamed packages go in `packages.arch.replaces`
(old → new): `20-install-packages` removes the old one first, otherwise the
conflict makes `paru --noconfirm` fail.

### Container (`$container`)
Podman stack: `podman`, `podman-compose`, `podman-docker`

### Virtualization (`$virtualization`)
Full KVM/libvirt: `libvirt`, `qemu-desktop`, `virt-manager`, `dnsmasq`, `swtpm` (TPM for Windows 11 guests)

## External Tools (Not in Any Repo)

Installed by `run_onchange_after_40-pentest-extras.sh` (re-runs whenever the
script changes):

| Tool | Method | Description |
|------|--------|-------------|
| hadolint | binary (`~/.local/bin`) | Dockerfile linter |
| docker-bench-security | git clone + launcher | CIS Docker benchmark |

Container helpers live in the chezmoi-managed file
`~/.config/zsh/env/pentest-docker.zsh` and are only defined when docker or
podman is available: `bloodhound-ce` (official SpecterOps compose: app +
PostgreSQL + neo4j, UI on http://localhost:8080; `bloodhound-ce down` to stop)
and `dradis` (bound to 127.0.0.1).

## Scripts Execution Order

`chezmoi` runs `before` scripts first, then the file state, then `after`
scripts — each phase in alphabetical order. Numbered prefixes make the order
explicit:

```
BEFORE (alphabetical)
  00-create-folders.sh     (once)     # base directories
  01-bootstrap-paru.sh     (once)     # AUR helper
  05-setup-blackarch.sh    (every)    # BlackArch repo, pentest profiles (sudo + TTY)
  10-generate-ssh-key.sh   (once)     # SSH key + pubkey registry

STATE
  dotfiles, configs, wallpaper...

AFTER (alphabetical)
  20-install-packages.sh   (onchange) # replaces migration + paru -Syu --needed of the full list
  25-system-services.sh    (every)    # services + groups per profile (sudo only if something is missing)
  30-pacman-cleanup.sh     (every*)   # weekly systemd cleanup timer
  40-pentest-extras.sh     (onchange) # GitHub binaries
  27-firewall.sh           (every*)   # ufw: deny incoming + declared rules (gui profiles)
  28-snapper.sh            (every*)   # snapper root config + timers (flag snapshots, btrfs)
  45-kde-theme.sh          (every)    # KDE appearance (kwriteconfig6, no sudo)
  46-plasmalogin.sh        (every*)   # login screen: wallpaper + Plasma settings
  50-deploy-ssh-keys.sh    (onchange) # propagate pubkeys over SSH (one connection per host)
  60-setup-nfs.sh          (every*)   # NFS automount units
  70-prune-packages.sh     (every)    # uninstall packages removed from the list
  80-mirror-optimize.sh    (every*)   # reflector + BlackArch mirror optimizer
  90-oci-cli.sh            (every)    # official Oracle installer + zsh completion cache (AUR pkg broken on py3.14)
  95-git-hooks.sh          (every)    # pre-commit hooks of this repo (gitleaks + tools/check.sh)
```

`onchange` scripts re-run automatically when their content changes, so editing
the extras list or the package list is enough — no manual step.

`every*` scripts write to `/etc` and use `.chezmoitemplates/sudo-stamp.sh`:
they exit immediately when their stamp in `~/.local/state/chezmoi/stamps/`
matches, and without sudo/TTY they postpone to the next interactive apply
instead of being recorded as done (which is what `run_once_`/`run_onchange_`
would do).

## Firewall (ufw)

GUI profiles only (on the server, `deny incoming` would cut SSH). Rules are in
`.chezmoidata/firewall.yaml` and are only ever added: to drop one, remove it
from the YAML and then run `sudo ufw status numbered && sudo ufw delete <N>`.

Pentest: listeners (responder, ntlmrelayx, reverse shells) need a temporary
rule scoped to the target, for example
`sudo ufw allow in on <iface> from <target>`. Delete it after the engagement.

## Btrfs Snapshots (snapper)

Flag `snapshots` (laptop). `28-snapper` creates the `root` config: snap-pac
takes a pre/post snapshot around every pacman/paru transaction, so around
every `chezmoi apply`, and the timeline keeps 5 hourly + 7 daily snapshots.
`/home`, the pacman cache and `/var/log` are separate subvolumes and are not
included.

```bash
snapper -c root list                          # no sudo for the wheel group
sudo snapper -c root status <pre>..<post>     # what a transaction changed
sudo snapper -c root undochange <pre>..<post> # revert it
```

systemd-boot cannot boot a snapshot. If the system no longer boots, boot a live
USB, mount the btrfs volume and restore the `@` subvolume from
`@/.snapshots/<N>/snapshot`.

## KDE Plasma Appearance

Declared in `.chezmoidata/kde.yaml` (global theme, color scheme, icons, cursor,
splash, wallpaper, lock timeout, extra keys). KDE rc files are **not** managed
as chezmoi files: Plasma rewrites them constantly (full color palette, window
states...), so a managed `kdeglobals` would wipe that state on every apply.
Instead:

- `45-kde-theme.sh` reads each key and only writes the ones that differ
  (`kwriteconfig6`, `plasma-apply-lookandfeel/colorscheme/cursortheme`,
  `plasma-apply-wallpaperimage` when a Plasma session is running). Automatic
  light/dark switching is disabled so the theme stays dark.
- `46-plasmalogin.sh` aligns Plasma Login Manager like the "Apply Plasma
  Settings" button of the login screen KCM: wallpaper copied to
  `/var/lib/plasmalogin/wallpapers`, `/etc/plasmalogin.conf` edited key by key
  (other keys such as `PreselectedUser` are kept), and the user's
  `kdeglobals`, `kcminputrc`, `kxkbrc`, `plasma-localerc`, `plasmarc`,
  `fontconfig/fonts.conf` copied to `/var/lib/plasmalogin/.config`.

To change the look on every device: edit `kde.yaml` (or drop a new wallpaper
package in `dot_local/share/wallpapers/`) and `chezmoi apply`.

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
| `.chezmoidata/kde.yaml` | KDE Plasma appearance |
| `.chezmoitemplates/sudo-stamp.sh` | sudo/TTY guard + stamp for scripts writing to `/etc` |
| `private_dot_config/chezmoi/chezmoi.toml.tmpl` | Device detection + hooks |
| `.chezmoiscripts/*.sh(.tmpl)` | Lifecycle scripts |
| `.chezmoihooks/install-password-manager.sh` | pre-read-source-state hook |
| `private_dot_config/zsh/env/pentest-docker.zsh` | Pentest container aliases |

## Checks (local, pre-commit, CI)

```bash
tools/check.sh             # render every script for all-flags / no-flags profiles, bash -n, shellcheck, package count
pre-commit run --all-files # same + gitleaks on staged changes
```

The pre-commit hook is installed by `95-git-hooks` (needs `pre-commit` and
`gitleaks`, both in the base packages). GitHub Actions runs `tools/check.sh` and
gitleaks over the full history on every push.

## Troubleshooting

### BlackArch Keyring Issues
```bash
sudo pacman -Sy archlinux-keyring blackarch-keyring
sudo pacman-key --populate archlinux blackarch
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
