# Recherche inverse dans l'historique
bindkey '^R' fzf-history-widget

# Insertion d'un fichier
bindkey '^T' fzf-file-widget

# cd rapide (Alt-C)
bindkey '^[c' fzf-cd-widget

# Navigation en ligne de commande
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^U' kill-whole-line
bindkey '^W' backward-kill-word

# Alt-. : dernier argument de la commande précédente
bindkey '^[.' insert-last-word

# Ctrl-X Ctrl-E : édite la ligne courante dans $VISUAL/$EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line