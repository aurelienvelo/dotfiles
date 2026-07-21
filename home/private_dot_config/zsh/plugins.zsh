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

# Tmux
if command -v tmux >/dev/null &&
  [ -z "$TMUX" ] && [ -n "$PS1" ]; then
    ~/.local/bin/tmux-bootstrap
    exec tmux
fi
