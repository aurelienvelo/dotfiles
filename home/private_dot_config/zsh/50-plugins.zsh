# Smart cd
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"
fi

# fzf
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

# Tmux automatique, sauf :
#  - session SSH (on ne veut pas imbriquer avec un tmux local ou distant)
#  - terminaux embarqués (Dolphin/Kate via KONSOLE_DBUS_SESSION, VS Code,
#    Neovim :terminal)
# `tmux` sans `exec` si le serveur ne démarre pas : un tmux cassé ne doit
# pas fermer le terminal instantanément.
if (( ${+commands[tmux]} )) && [[ -o interactive && -z $TMUX && -z $SSH_CONNECTION \
      && -z $KONSOLE_DBUS_SESSION && $TERM_PROGRAM != vscode && -z $NVIM ]]; then
    ~/.local/bin/tmux-bootstrap || true
    tmux new-session && exit
fi

# mise
if command -v mise >/dev/null; then
    eval "$(mise activate zsh)"
fi

# direnv
if command -v direnv >/dev/null; then
    eval "$(direnv hook zsh)"
fi
