# zsh-syntax-highlighting : DOIT être chargé en dernier, après la définition
# de tous les widgets et raccourcis (il les enveloppe au moment du source).
# D'où le préfixe 99, après 90-prompt.
_zsh_hl=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r $_zsh_hl ]] && source "$_zsh_hl"
unset _zsh_hl
