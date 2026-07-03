#!/bin/sh

set -eu

# Exit if Bitwarden CLI is already installed
command -v bw >/dev/null 2>&1 && exit 0

OS="$(uname -s)"

case "$OS" in
Darwin)
    if command -v brew >/dev/null 2>&1; then
        brew install bitwarden-cli jq
    else
        echo "Homebrew is required to install Bitwarden CLI."
        exit 1
    fi
    ;;
Linux)
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed bitwarden-cli jq

    elif command -v paru >/dev/null 2>&1; then
        paru -S --needed bitwarden-cli jq

    elif command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y jq

        # Installation officielle de Bitwarden CLI
        VERSION="$(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest | jq -r '.tag_name' | sed 's/^cli-v//')"
        curl -L "https://github.com/bitwarden/clients/releases/download/cli-v${VERSION}/bw-linux-${VERSION}.zip" -o /tmp/bw.zip
        unzip -o /tmp/bw.zip -d /tmp
        sudo install /tmp/bw /usr/local/bin/bw
        rm -f /tmp/bw.zip /tmp/bw

    else
        echo "Unsupported package manager."
        exit 1
    fi
    ;;
*)
    echo "Unsupported operating system."
    exit 1
    ;;
esac
