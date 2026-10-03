{{ if eq .chezmoi.os "linux" -}}
{{- $gui := dig "gui" false . -}}
{{- $vpn := dig "vpn" false . -}}
{{- $pentest := dig "pentest" false . -}}
{{- $wifi := dig "wifi" false . -}}
{{- $container := dig "container" false . -}}
{{- $virtualization := dig "virtualization" false . -}}
{{- $device_type := dig "device_type" "unknown" . -}}
{{- $has_nvidia := dig "has_nvidia" false . -}}
{{- $has_battery := dig "has_battery" false . -}}

desired_packages() {
  local pkgs=()

  # BASE - toujours
  local base_pkgs=(
  {{ range dig "pacman" (list) .packages.arch.base }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.base }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${base_pkgs[@]}")

  # GUI
  {{ if $gui }}
  local gui_pkgs=(
  {{ range dig "pacman" (list) .packages.arch.gui }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.gui }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${gui_pkgs[@]}")
  {{ end }}

  # VPN
  {{ if $vpn }}
  local vpn_pkgs=(
  {{ range dig "pacman" (list) .packages.arch.vpn }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.vpn }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${vpn_pkgs[@]}")
  {{ end }}

  # NVIDIA (condition has_nvidia)
  {{ if $has_nvidia }}
  local nv_pkgs=(
    'nvidia-open-dkms'
    'nvidia-utils'
    'nvidia-settings'
    'egl-wayland'
    'libva-nvidia-driver'
  )
  pkgs+=("${nv_pkgs[@]}")
  {{ end }}

  # LAPTOP (condition has_battery)
  {{ if $has_battery }}
  local lap_pkgs=(
    'bluedevil'
    'power-profiles-daemon'
    'brightnessctl'
    'bluez-utils'
  )
  pkgs+=("${lap_pkgs[@]}")
  {{ end }}

  # PENTEST (BlackArch + AUR) — dig : une clé absente rend une liste vide
  # au lieu de casser l'apply sur les appareils où la branche est activée
  {{ if $pentest }}
  local pentest_pkgs=(
  {{ range dig "blackarch" (list) .packages.arch.pentest.osint }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.osint }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.network }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.network }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.vuln_scanners }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.vuln_scanners }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.wordlists }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.wordlists }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.web }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.web }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.ad_windows }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.ad_windows }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ if $wifi }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.wifi }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.wifi }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.container }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.container }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.exploit_post }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.exploit_post }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.cracking }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.cracking }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.re }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.re }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "blackarch" (list) .packages.arch.pentest.reporting }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.pentest.reporting }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${pentest_pkgs[@]}")
  {{ end }}

  # CONTAINER
  {{ if $container }}
  local container_pkgs=(
  {{ range dig "pacman" (list) .packages.arch.container }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.container }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${container_pkgs[@]}")
  {{ end }}

  # VIRTUALIZATION
  {{ if $virtualization }}
  local virt_pkgs=(
  {{ range dig "pacman" (list) .packages.arch.virtualization }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range dig "aur" (list) .packages.arch.virtualization }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${virt_pkgs[@]}")
  {{ end }}

  printf '%s\n' "${pkgs[@]}"
}
{{ end }}
