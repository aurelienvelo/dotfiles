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
  {{ range .packages.arch.base.pacman }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.base.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${base_pkgs[@]}")

  # GUI
  {{ if $gui }}
  local gui_pkgs=(
  {{ range .packages.arch.gui.pacman }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.gui.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${gui_pkgs[@]}")
  {{ end }}

  # VPN
  {{ if $vpn }}
  local vpn_pkgs=(
  {{ range .packages.arch.vpn.pacman }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.vpn.aur }}{{ "  " }}{{ . | quote }}{{ end }}
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

  # PENTEST (BlackArch + AUR)
  {{ if $pentest }}
  local pentest_pkgs=(
  {{ range .packages.arch.pentest.osint.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.osint.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.network.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.network.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.vuln_scanners.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.vuln_scanners.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.wordlists.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.wordlists.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.web.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.web.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.ad_windows.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.ad_windows.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ if $wifi }}
  {{ range .packages.arch.pentest.wifi.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.wifi.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ end }}
  {{ range .packages.arch.pentest.container.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.container.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.exploit_post.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.exploit_post.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.cracking.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.cracking.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.re.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.re.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.reporting.blackarch }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.pentest.reporting.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${pentest_pkgs[@]}")
  {{ end }}

  # CONTAINER
  {{ if $container }}
  local container_pkgs=(
  {{ range .packages.arch.container.pacman }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.container.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${container_pkgs[@]}")
  {{ end }}

  # VIRTUALIZATION
  {{ if $virtualization }}
  local virt_pkgs=(
  {{ range .packages.arch.virtualization.pacman }}{{ "  " }}{{ . | quote }}{{ end }}
  {{ range .packages.arch.virtualization.aur }}{{ "  " }}{{ . | quote }}{{ end }}
  )
  pkgs+=("${virt_pkgs[@]}")
  {{ end }}

  printf '%s\n' "${pkgs[@]}"
}
{{ end }}