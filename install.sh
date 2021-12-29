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

MODULES="tmux"
MODULES_INSTALL=""

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
    cp -vsf "$CURDIR/$1" "${HOME}/.$1"
}

add_module()
{
    echo "$MODULES" | grep "$1" || echo_err "Unknown module $1"
    echo "$MODULES_INSTALL" | grep "$1" || MODULES_INSTALL="$MODULES_INSTALL $1"
}

list_modules()
{
    echo "Support modules:"
    for mod in $MODULES
    do
        echo "  $mod"
    done
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
Usage: $0 [ options ] [ modules... ]
    -f, --force        Force install, replace the exist files.
    -h, --help         Show this messages.
    -l, --list         List modules.
EOF
}

while [ $# -ne 0 ]
do
    case $1 in
        -f|--force)
            FORCE=1
            ;;
        -l|--list)
            list_modules
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            add_module $1
            ;;
    esac
    shift
done

if [ -z "$MODULES_INSTALL" ]; then
    MODULES_INSTALL="$MODULES"
fi

for mod in ${MODULES_INSTALL}
do
    echo_info "Install $mod ..."
    eval "install_$mod"
done

echo_info "All finish!"
