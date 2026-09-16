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