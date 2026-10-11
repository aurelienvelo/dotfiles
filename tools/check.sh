#!/bin/bash
# Vérifications avant push : utilisé en local et par la CI
# (.github/workflows/check.yml). Hors de home/ (.chezmoiroot) : jamais déployé.
#
# Pour deux profils synthétiques, « all » (tous les flags à true) et « none »
# (tous à false) :
#  1. rend chaque script de .chezmoiscripts (état chezmoi vierge)
#  2. bash -n + shellcheck -S warning sur le rendu
#  3. profil all : la liste de paquets rendue doit compter exactement les
#     entrées de packages.yaml + celles codées en dur dans pkg-list.sh
#     (attrape une catégorie oubliée dans le template, ou une clé absente
#     comme le bug vpn.pacman)
# N'utilise ni la config déployée ni Bitwarden.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/home"
# Flags lus par les templates (voir private_dot_config/chezmoi/chezmoi.toml.tmpl)
FLAGS=(gui vpn pentest wifi container virtualization has_nvidia has_intel_gpu has_battery nfs_mount)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
errors=0
err() { echo "ÉCHEC : $*" >&2; errors=$((errors + 1)); }

# Le fichier de config doit déclarer tous les flags : un flag ajouté au
# template mais oublié ici échapperait à la vérification.
while read -r f; do
    [[ " ${FLAGS[*]} " == *" $f "* ]] || err "flag '$f' absent de FLAGS dans tools/check.sh"
done < <(grep -oE '^\s+[a-z_]+ = (true|false)$' "$SRC/private_dot_config/chezmoi/chezmoi.toml.tmpl" \
    | awk '{print $1}' | sort -u)

for profile in all none; do
    value=true
    [ "$profile" = none ] && value=false
    cfg="$work/$profile.toml"
    {
        echo "[data]"
        echo "    device_type = \"check\""
        for f in "${FLAGS[@]}"; do echo "    $f = $value"; done
    } >"$cfg"
    mkdir -p "$work/dest-$profile"
    cz=(chezmoi --config "$cfg" --source "$ROOT" --destination "$work/dest-$profile"
        --persistent-state "$work/state-$profile.boltdb" --cache "$work/cache-$profile"
        --no-pager --color false)

    # 1. Rendu des scripts : un fichier par en-tête « +++ b/.chezmoiscripts/<nom> »
    out="$work/scripts-$profile"
    mkdir -p "$out"
    if ! "${cz[@]}" diff --include scripts --exclude none >"$work/$profile.diff" 2>"$work/$profile.err"; then
        err "[$profile] rendu des scripts impossible :"
        cat "$work/$profile.err" >&2
        continue
    fi
    awk -v dir="$out" '
        /^diff --git/ { file = ""; next }
        /^\+\+\+ b\/\.chezmoiscripts\// { file = dir "/" substr($0, 23); next }
        file != "" && /^\+/ { print substr($0, 2) > file }
    ' "$work/$profile.diff"

    shopt -s nullglob
    scripts=("$out"/*)
    shopt -u nullglob
    echo "[$profile] ${#scripts[@]} script(s) rendu(s)"

    # 2. Syntaxe + shellcheck
    for s in "${scripts[@]}"; do
        bash -n "$s" || err "[$profile] syntaxe : $(basename "$s")"
    done
    if [ ${#scripts[@]} -gt 0 ] && ! shellcheck -S warning "${scripts[@]}"; then
        err "[$profile] shellcheck"
    fi

    # 3. Comptage des paquets (profil all)
    if [ "$profile" = all ]; then
        rendered="$("${cz[@]}" execute-template '{{ template "pkg-list.sh" . }}' \
            | bash -c 'source /dev/stdin && desired_packages' | wc -l)"
        expected="$(python3 - "$SRC/.chezmoidata/packages.yaml" <<'PY'
import sys, yaml
arch = yaml.safe_load(open(sys.argv[1]))["packages"]["arch"]
arch.pop("replaces", None)
def count(node):
    if isinstance(node, list):
        return len(node)
    if isinstance(node, dict):
        return sum(count(v) for v in node.values())
    return 0
print(count(arch))
PY
)"
        hardcoded="$(grep -cE "^\s+'[a-z0-9.+-]+'$" "$SRC/.chezmoitemplates/pkg-list.sh")"
        dupes="$("${cz[@]}" execute-template '{{ template "pkg-list.sh" . }}' \
            | bash -c 'source /dev/stdin && desired_packages' | sort | uniq -d | tr '\n' ' ')"
        echo "[$profile] paquets : rendu=$rendered attendu=$((expected + hardcoded)) (yaml=$expected, en dur=$hardcoded)"
        [ "$rendered" -eq $((expected + hardcoded)) ] || err "[$profile] nombre de paquets incohérent"
        [ -z "$dupes" ] || err "[$profile] paquets en double : $dupes"
    fi
done

if [ "$errors" -gt 0 ]; then
    echo "$errors échec(s)" >&2
    exit 1
fi
echo "OK"
