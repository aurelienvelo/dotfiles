bwunlock() {
    export BW_SESSION="$(bw unlock --raw)"
}

for file in ~/.config/zsh/lib/*.zsh; do
    [[ -r $file ]] && source "$file"
done
