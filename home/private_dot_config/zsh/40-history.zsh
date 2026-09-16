# Configuration de base de l'historique

# Emplacement
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
#mkdir -p "${HISTFILE:h}"

# Taille
HISTSIZE=100000
SAVEHIST=100000

# Sauvegarde
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Nettoyage
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
