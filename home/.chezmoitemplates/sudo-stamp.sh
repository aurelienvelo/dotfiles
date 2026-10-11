# --- garde sudo + tampon (.chezmoitemplates/sudo-stamp.sh) ---
# Pour les scripts run_ qui écrivent dans /etc. Pourquoi pas run_once_ ou
# run_onchange_ : chezmoi enregistre ces scripts dès qu'ils sortent en 0, donc
# un « pas de TTY, je passe mon tour » serait mémorisé comme fait et jamais
# retenté. Ici, l'état est un tampon que le script n'écrit (stamp_done) qu'en
# cas de succès. L'appelant définit STAMP_WANT avant l'inclusion : un hash de
# tout ce qui doit déclencher un redéploiement.
# Usage : {{ "{{" }} template "sudo-stamp.sh" "nom" {{ "}}" }}
STAMP="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi/stamps/{{ . }}"
if [ "$(cat "$STAMP" 2>/dev/null)" = "$STAMP_WANT" ]; then
    exit 0
fi
if ! sudo -n true 2>/dev/null && [ ! -t 0 ]; then
    echo "[{{ . }}] sudo requis : reporté au prochain 'chezmoi apply' lancé dans un terminal."
    exit 0
fi
stamp_done() {
    mkdir -p "${STAMP%/*}"
    printf '%s\n' "$STAMP_WANT" >"$STAMP"
}
# --- fin garde ---
