bwunlock() {
    export BW_SESSION="$(bw unlock --raw)"
}

# Crée un projet Python uv + .envrc (direnv) prêt à l'emploi
uvinit() {
    local name="${1:-$(basename "$PWD")}"

    [[ -d "$name" ]] || uv init --bare "$name"
    cd "$name" || return 1

    uv python pin 3.12 2>/dev/null || true
    uv venv --seed 2>/dev/null || true

    if [[ ! -f .envrc ]]; then
        cat > .envrc <<'ENVRC'
# Active le venv uv dans le shell via direnv
if [ -d .venv ]; then
    VIRTUAL_ENV="$(pwd)/.venv"
    export VIRTUAL_ENV
    export PATH="$VIRTUAL_ENV/bin:$PATH"
    unset PYTHONHOME
fi
ENVRC
    fi

    direnv allow . 2>/dev/null || true
    echo "Projet uv prêt dans $name"
}

for file in ~/.config/zsh/lib/*.zsh; do
    [[ -r $file ]] && source "$file"
done
