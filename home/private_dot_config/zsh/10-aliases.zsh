# Alias utiles
# # Replace ls with eza
alias ls='eza'
alias ll='eza -l --header --icons=auto'
alias la='eza -la --header --icons=auto'
alias tree='eza --tree'

alias update='paru -Syu'

alias v='nvim'
alias o='xdg-open'
alias g='git'
alias lg='lazygit'
alias cat='bat --paging=never'

alias git-to-ssh='git-remote-convert ssh'
alias git-to-https='git-remote-convert https'
alias git-to-auto='git-remote-convert auto'

# Raccourcissement de navigation
alias ..='cd ..'
alias ...='cd ../..'

# Git courts (complément de lazygit)
alias gl='git log --oneline --graph --decorate'
alias gs='git status -sb'
alias gd='git diff'
