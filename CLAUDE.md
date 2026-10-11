# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A chezmoi source repo for Arch Linux machines: dotfiles plus system package management, with a BlackArch pentest toolset. `.chezmoiroot` is set to `home`, so every source path lives under `home/`. `README.md` has the user-facing package/tool lists. Update it when you add or remove packages, scripts or external tools.

Comments, script output and prompts are written in French. Commits use conventional prefixes (`feat:`, `fix:`).

## Commands

```bash
chezmoi diff                       # preview (scripts are excluded from diff via [diff] exclude)
chezmoi apply                      # needs an interactive TTY: sudo prompts, prune confirmation
~/.local/bin/chezmoi-apply         # wrapper: unlocks Bitwarden (exports BW_SESSION) then runs chezmoi apply
chezmoi execute-template < home/path/file.tmpl     # render one template
chezmoi execute-template '{{ template "pkg-list.sh" . }}' | bash -c 'source /dev/stdin && desired_packages'
```

There is no test suite. Validation means rendering templates and running `bash -n` / `shellcheck` on the output.

## Architecture

**Device profiles → flags.** `home/private_dot_config/chezmoi/chezmoi.toml.tmpl` matches on `.chezmoi.hostname` (`vm-dev`, `laptop`, `desktop`, `matrix.home.lan`, or the all-false fallback) and sets the data flags `gui`, `vpn`, `pentest`, `wifi`, `container`, `virtualization`, `has_nvidia`, `has_battery`, `nfs_mount` and `device_type`. Every conditional in templates, scripts and `.chezmoiignore` reads these flags, always through `dig "<flag>" false .` so that a missing key never breaks rendering. The same file registers the `read-source-state.pre` hook (`.chezmoihooks/install-password-manager.sh`), which installs `bw` before chezmoi reads the source. If you move that hook, devices with an old deployed config will hard-fail, so leave a forwarding shim at the old path (see commit 4f80878).

**Package pipeline.**
- `home/.chezmoidata/packages.yaml` holds the data under `packages.arch.<category>`. Non-pentest categories use `pacman:` / `aur:` keys. Pentest subcategories use `blackarch:` / `aur:` keys. Arch-official tools such as nmap also go under `blackarch:`, because `paru` resolves every repo. A `pacman:` key inside a pentest subcategory is **silently ignored**.
- `home/.chezmoitemplates/pkg-list.sh` is the single source for the desired list. It renders a bash `desired_packages()` function that is gated by the flags (WiFi tools need both `pentest` and `wifi`; NVIDIA/laptop packages are hardcoded there). A new category or subcategory must be wired into this template explicitly.
- `run_onchange_after_20-install-packages` runs `paru -Syu --needed` on that list. It re-runs whenever the rendered content changes, which means whenever the list changes.
- `packages.arch.replaces` (old → new) is a migration table: `20-install-packages` runs `paru -Rdd` on the old name first, because a conflict makes `paru --noconfirm` fail the whole script. `pacman -Qq <name>` resolves "provides" (it can return a different package name), so both scripts compare the returned name strictly.
- `run_after_70-prune-packages` compares the list against the previous snapshot in `~/.local/state/chezmoi/desired-packages.txt`. It offers `paru -Rns` only on a TTY and keeps packages that are still `Required By` something.

**Scripts** (`home/.chezmoiscripts/`). Numeric prefixes set the order inside the before and after phases. `run_once_`, `run_onchange_` and `run_` are meant literally: to force a `run_onchange_` script to re-run, change its rendered content (for example `50-deploy-ssh-keys` embeds sha256 hashes of the registry in a comment). chezmoi records a `run_once_`/`run_onchange_` script as done as soon as it exits 0, so a script that skips itself for lack of sudo or a TTY must **not** be `run_once_`/`run_onchange_`. Scripts that write to `/etc` are `run_` scripts that set `STAMP_WANT` (usually `{{ include .chezmoi.sourceFile | sha256sum }}`) and then include `{{ template "sudo-stamp.sh" "<name>" }}`: the script exits early when the stamp in `~/.local/state/chezmoi/stamps/` matches, postpones without sudo/TTY, and calls `stamp_done` on success. `25-system-services` follows the same idea without a stamp: it checks state unprivileged and asks for sudo only when something is missing. Each script is wrapped in `{{ if eq .chezmoi.os "linux" }}` plus its flag guards, so it renders empty, and is skipped, on profiles where it doesn't apply.

**Secrets.** The private templates under `private_dot_ssh`, `private_dot_oci`, `private_dot_kube` and `private_dot_config/sops` read from Bitwarden through `bitwarden` / `bitwardenFields`. Rendering them, and so any full `chezmoi apply` or `diff`, needs an unlocked `bw`.

**KDE Plasma.** Appearance is declared in `home/.chezmoidata/kde.yaml`. KDE rc files (`kdeglobals`, `kwinrc`, `kscreenlockerrc`, `dolphinrc`...) must **not** be added as chezmoi files: Plasma rewrites them (the full `[Colors:*]` palette, window state), so a managed copy wipes that state on every apply. `45-kde-theme` converges key by key with `kreadconfig6`/`kwriteconfig6` and the `plasma-apply-*` tools (no sudo). `46-plasmalogin` mirrors the login-screen KCM "Apply Plasma Settings" button: it copies the wallpaper package into `/var/lib/plasmalogin/wallpapers`, edits `/etc/plasmalogin.conf` with `sudo kwriteconfig6` (never overwrite it, because the KCM stores `PreselectedUser` there), and copies the user rc files into `/var/lib/plasmalogin/.config`, writing out explicit values that normally live in `~/.config/kdedefaults`. To add a forced key, add it under `kde.settings` instead of writing a file.

**Neovim.** `exact_nvim` removes untracked files from `~/.config/nvim`, except `lazy-lock.json`, which is in `.chezmoiignore` and owned by lazy.nvim. LSP uses the Neovim 0.11+ API (`vim.lsp.config` + `LspAttach`). mason-lspconfig v2 ignores the old `handlers` option.

**zsh.** `ZDOTDIR=~/.config/zsh` (set in `dot_zshenv`). `.zshrc` sources `~/.config/zsh/*.zsh` in numeric order, and `.zprofile` (login shells: the Plasma session and every tmux pane) puts `~/.local/bin` on `PATH` with `typeset -U path`, then sources `env/*.zsh`. `EDITOR=nvim` is set in `dot_zshenv`, and `60-keybindings` forces `bindkey -e` because an EDITOR containing "vi" would switch zsh to the vi keymap. `pentest-docker.zsh` is excluded through `.chezmoiignore` when `pentest` is false. Removed or renamed target files go in `.chezmoiremove`.

**Other data.** `home/.chezmoidata.yaml` holds the SSH host list (rendered into `private_dot_ssh/config.tmpl`) and the NFS server IP. `ssh_pubkeys_registry/` collects per-host pubkeys for `50-deploy-ssh-keys` and is not deployed.

## Validation before pushing

The dev machine (`vm-dev`) has most flags set to false, so branches gated by `vpn`, `wifi`, `container`, `virtualization`, `has_nvidia` and `has_battery` never render there. A missing `vpn.pacman` key once shipped this way and broke apply on other devices. After you edit `packages.yaml`, `pkg-list.sh` or any script that uses them:

1. Copy the deployed `~/.config/chezmoi/chezmoi.toml` to `/tmp/allflags.toml` and set every flag to true, then render:
   `chezmoi --config /tmp/allflags.toml execute-template '{{ template "pkg-list.sh" . }}' | bash -c 'source /dev/stdin && desired_packages' | wc -l`
2. Check that count against an independent `yq` sum over `packages.yaml`, plus the hardcoded NVIDIA/laptop entries.
3. Run `bash -n` and `shellcheck` on every rendered script. To get the rendered scripts, run `chezmoi diff --include scripts --exclude none` (add `--config /tmp/allflags.toml` for the all-flags render; `--exclude none` overrides the `[diff] exclude = ["scripts"]` setting) and split the output per `+++ b/.chezmoiscripts/<name>` header. `chezmoi execute-template` alone fails on scripts that use `.chezmoi.sourceFile`.
4. When you add packages, check for conflicts. BlackArch `*-ba` forks conflict with their Arch counterparts: `targetedkerberoast` pulls `impacket-ba`, which conflicts with `impacket` from extra, and `paru --noconfirm` aborts the whole install. `pacman -Sp` resolves dependencies but does **not** check conflicts, so cross-check the `Conflicts With` field of every resolved package (`LC_ALL=C pacman -Si $(pacman -Sp --print-format %n <repo pkgs>)`) against the resolved set and against what is installed.
5. Test a script that changes system or desktop state without changing it: run the rendered copy with `PATH` pointing to stubs for `sudo`, `kwriteconfig6` and `plasma-apply-*`.
