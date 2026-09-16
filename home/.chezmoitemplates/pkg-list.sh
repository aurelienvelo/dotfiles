{{ if eq .chezmoi.os "linux" -}}
desired_packages() {
  local pkgs=(
{{ range .packages.arch.pacman }}{{ "  " }}{{ . | quote }}
{{ end }}{{ range .packages.arch.aur }}{{ "  " }}{{ . | quote }}
{{ end }}  )
{{ if .gui }}
  local gui_pkgs=(
{{ range .packages.gui.plasma }}{{ "  " }}{{ . | quote }}
{{ end }}  )
  pkgs+=("${gui_pkgs[@]}")
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