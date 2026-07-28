git-remote-parse-url() {
    # Variables globales retournées
    GIT_REMOTE_PROTO=""
    GIT_REMOTE_HOST=""
    GIT_REMOTE_PORT=""
    GIT_REMOTE_PATH=""

    local url="$1"
    local tmp

    case "$url" in

        http://*)
            GIT_REMOTE_PROTO="http"
            tmp="${url#http://}"
            ;;

        https://*)
            GIT_REMOTE_PROTO="https"
            tmp="${url#https://}"
            ;;

        git@*)
            GIT_REMOTE_PROTO="ssh"

            tmp="${url#git@}"

            GIT_REMOTE_HOST="${tmp%%:*}"
            GIT_REMOTE_PATH="${tmp#*:}"

            return 0
            ;;

        ssh://*)
            GIT_REMOTE_PROTO="ssh"

            tmp="${url#ssh://}"

            # retire git@
            tmp="${tmp#*@}"

            # host:2222/path
            if [[ "$tmp" == *:*/* ]]; then

                GIT_REMOTE_HOST="${tmp%%:*}"

                tmp="${tmp#*:}"

                GIT_REMOTE_PORT="${tmp%%/*}"

                GIT_REMOTE_PATH="${tmp#*/}"

            else

                GIT_REMOTE_HOST="${tmp%%/*}"

                GIT_REMOTE_PATH="${tmp#*/}"

            fi

            return 0
            ;;

        *)
            return 1
            ;;
    esac

    # retire user:token@
    case "$tmp" in
        *@*)
            tmp="${tmp#*@}"
            ;;
    esac

    GIT_REMOTE_HOST="${tmp%%/*}"
    GIT_REMOTE_PATH="${tmp#*/}"

    return 0
}

git-remote-build-url() {

    local mode="$1"

    case "$mode" in

        ssh)

            if [[ -n "$GIT_REMOTE_PORT" ]]; then
                printf "ssh://git@%s:%s/%s\n" \
                    "$GIT_REMOTE_HOST" \
                    "$GIT_REMOTE_PORT" \
                    "$GIT_REMOTE_PATH"
            else
                printf "git@%s:%s\n" \
                    "$GIT_REMOTE_HOST" \
                    "$GIT_REMOTE_PATH"
            fi
            ;;

        https)

            if [[ -n "$GIT_REMOTE_PORT" ]]; then
                printf "https://%s:%s/%s\n" \
                    "$GIT_REMOTE_HOST" \
                    "$GIT_REMOTE_PORT" \
                    "$GIT_REMOTE_PATH"
            else
                printf "https://%s/%s\n" \
                    "$GIT_REMOTE_HOST" \
                    "$GIT_REMOTE_PATH"
            fi
            ;;

        *)
            return 1
            ;;
    esac
}

git-remote-convert-one() {

    local mode="$1"
    local remote="$2"

    local url
    local new_url

    url=$(git remote get-url "$remote") || {
        echo "❌ Remote '$remote' introuvable."
        return 1
    }

    git-remote-parse-url "$url" || {
        echo "❌ URL non supportée : $url"
        return 1
    }

    new_url=$(git-remote-build-url "$mode")

    if [[ "$url" == "$new_url" ]]; then
        echo "ℹ️ [$remote] Rien à faire."
        return 0
    fi

    git remote set-url "$remote" "$new_url" || {
        echo "❌ Impossible de modifier '$remote'."
        return 1
    }

    echo "✅ [$remote]"
    echo "   Ancien : $url"
    echo "   Nouveau: $new_url"
}

git-remote-convert() {

    local mode=""
    local remote="origin"
    local all=false

    while [[ $# -gt 0 ]]; do

        case "$1" in

            ssh|https|auto)
                mode="$1"
                ;;

            --all)
                all=true
                ;;

            *)
                remote="$1"
                ;;

        esac

        shift

    done

    [[ -z "$mode" ]] && {
        echo "Usage:"
        echo "  git-remote-convert ssh|https|auto [remote]"
        echo "  git-remote-convert ssh --all"
        return 1
    }

    git rev-parse --is-inside-work-tree >/dev/null || {
        echo "❌ Pas dans un dépôt Git."
        return 1
    }

    if [[ "$mode" == auto ]]; then

        local origin

        origin=$(git remote get-url origin) || return 1

        git-remote-parse-url "$origin"

        if ssh \
            -o BatchMode=yes \
            -o ConnectTimeout=2 \
            -T "git@$GIT_REMOTE_HOST" \
            >/dev/null 2>&1
        then
            mode=ssh
        else
            mode=https
        fi

        echo "ℹ️ Mode auto : $mode"

    fi

    if $all; then

        local r

        for r in $(git remote); do
            git-remote-convert-one "$mode" "$r"
        done

    else

        git-remote-convert-one "$mode" "$remote"

    fi

}
