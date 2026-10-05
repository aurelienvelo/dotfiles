# Auto-complétion moderne : compinit avec cache pour un démarrage rapide
autoload -Uz compinit

_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
# Recompile le dump s'il est absent ou a plus de 24h, sinon utilise le cache
if [[ ! -f "$_zcompdump" ]] || [[ -n "$(find "$_zcompdump" -mmin +1440 2>/dev/null)" ]]; then
    compinit -d "$_zcompdump"
else
    compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zstyle ':completion:*' menu select

# OCI CLI — completion zsh native : sous click>=8, le glue bash d'Oracle
# (_OCI_COMPLETE=complete, ère click7) est silencieusement vide ; la voie
# officielle est le script généré par _OCI_COMPLETE=zsh_source, qui interroge
# le binaire au TAB (zsh_complete + descriptions des services). Généré une
# fois puis mis en cache par run_after_90-oci-cli (1,3 s de génération).
# Doit venir APRÈS compinit : le script appelle compdef.
_oci_comp="${XDG_CACHE_HOME:-$HOME/.cache}/oci-cli-completion.zsh"
[[ -r "$_oci_comp" ]] && source "$_oci_comp"
unset _oci_comp
