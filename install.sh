#!/usr/bin/env bash

set -e

CURDIR="$(cd "$(dirname $BASH_SOURCE[0])" && pwd)"
FORCE=0

WHITE=$(tput setaf 7)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo_info()
{
    echo "${BLUE}INFO : $@ ${RESET}"
}

echo_err()
{
    echo "${RED}ERROR: $@ ${RESET}"
    return 1
}

backup_file()
{
    local cnt=1
    local newfile="$1.bak"

    while [ -e "$newfile" ]
    do
        newfile="$1.bak${cnt}"
        cnt=$((cnt + 1))
    done

    echo_info "Backup $1 to $newfile ..."
    mv -v "$1" "$newfile"
}

install_file()
{
    echo_info "Install $1 to ~/.$1 ..."

    if [ -e "${HOME}/.$1" ]; then
        if [ -L "${HOME}/.$1" -a "`readlink -f "${HOME}/.$1"`" == "$CURDIR/$1" ]; then
            # already installed
            return
        fi

        echo_info "File ${HOME}/.$1 already exist!"

        # backup
        if [ $FORCE -eq 0 ]; then
            backup_file "${HOME}/.$1"
        fi
    fi

    mkdir -vp "$(dirname "${HOME}/.$1")"
    ln -vs "$CURDIR/$1" "${HOME}/.$1"
}

install_tmux()
{
    if [ -e '${HOME}/.tmux/plugins/tpm' ]; then
        git clone --depth 1 https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
    fi

    install_file 'tmux.conf'
}

usage()
{
    cat <<EOF
Usage: $0 [ options ]
    -f, --force        Force install, replace the exist files.
    -h, --help         Show this messages.
EOF
}

while [ $# -ne 0 ]
do
    case $1 in
        -f|--force)
            FORCE=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: invalid argument $1"
            exit 1
            ;;
    esac
done

install_tmux
