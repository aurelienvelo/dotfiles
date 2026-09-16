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