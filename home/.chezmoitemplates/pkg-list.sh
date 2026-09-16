{{ if eq .chezmoi.os "linux" -}}
desired_packages() {
  local pkgs=(
{{ range .packages.arch.pacman }}{{ "  " }}{{ . | quote }}
{{ end }}{{ range .packages.arch.aur }}{{ "  " }}{{ . | quote }}
{{ end }}  )
{{ if ne .device_type "server" }}
  local netbird_pkgs=(
{{ range .packages.netbird.aur }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${netbird_pkgs[@]}")
{{ end }}
{{ if .gui }}
  local gui_pkgs=(
{{ range .packages.gui.plasma }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${gui_pkgs[@]}")
{{ end }}
{{ if .workstation }}
  local ws_pkgs=(
{{ range .packages.gui.workstation }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${ws_pkgs[@]}")
{{ end }}
{{ if eq .device_type "desktop" }}
  local desktop_pkgs=(
{{ range .packages.gui.desktop }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${desktop_pkgs[@]}")
{{ end }}
{{ if .has_nvidia }}
  local nv_pkgs=(
{{ range .packages.gui.nvidia }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${nv_pkgs[@]}")
{{ end }}
{{ if .has_battery }}
  local lap_pkgs=(
{{ range .packages.gui.laptop }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${lap_pkgs[@]}")
{{ end }}
  printf '%s\n' "${pkgs[@]}"
}
{{ end }}