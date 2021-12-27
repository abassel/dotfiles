#!/usr/bin/env bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function debug() {
    echo -e "Running Strace for command --> ${YELLOW} $@ ${NC}\n"
    strace -f -t -e trace=file $@
}


function gb() {
    echo -e "${YELLOW} Creating a new branch ${NC} $1 \n"
    hub sync all
    git checkout -b $1
    git push -u origin $1
}

function review() {
    echo -e "${YELLOW} getting PR ${NC} $1 \n"
    gh pr checkout $1
    # https://newbedev.com/is-there-a-quick-way-to-git-diff-from-the-point-or-branch-origin
    git diff main...HEAD | lint-diffs > REVIEW.txt
    cat REVIEW.txt
}

# https://justin.abrah.ms/dotfiles/zsh.html
function extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)        tar xjf $1        ;;
            *.tar.gz)         tar xzf $1        ;;
            *.bz2)            bunzip2 $1        ;;
            *.rar)            unrar x $1        ;;
            *.gz)             gunzip $1         ;;
            *.tar)            tar xf $1         ;;
            *.tar.xz)         tar xf $1         ;;
            *.tbz2)           tar xjf $1        ;;
            *.tgz)            tar xzf $1        ;;
            *.zip)            unzip $1          ;;
            *.Z)              uncompress $1     ;;
            *.7z)             7zr e $1          ;;
            *)                echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# https://github.com/jessfraz/dotfiles/blob/master/.aliases
# Linux specific aliases, work on both MacOS and Linux.
#function pbcopy() {
#	stdin=$(</dev/stdin);
#	pbcopy="$(which pbcopy)";
#	if [[ -n "$pbcopy" ]]; then
#		echo "$stdin" | "$pbcopy"
#	else
#		echo "$stdin" | xclip -selection clipboard
#	fi
#}
#
#function pbpaste() {
#	pbpaste="$(which pbpaste)";
#	if [[ -n "$pbpaste" ]]; then
#		"$pbpaste"
#	else
#		xclip -selection clipboard
#	fi
#}

# Git patch functions
function copy_patch() {
    files2patch=($(git ls-files --others --exclude-standard))

    # put all untracked files in the patch
    for file in $files2patch; do git add --intent-to-add $file; done

    git diff HEAD | pbcopy
    echo "==== Generating patch in clipboard for the files below ===="
    git diff HEAD --name-only | cat

    # restore untracked files as untracked
    for file in $files2patch; do git reset HEAD $file; done
}

function copy_patch_no_untracked() {

    git diff HEAD | pbcopy
    echo "==== Generating patch in clipboard for the files below ===="
    git diff HEAD --name-only | cat

}

function paste_patch() {
    pbpaste | git apply
}

# Log manipulation functions
function __end_note() {
    echo ""
#    echo "type __help to list all commands"
    echo ""
}

function __wipe_all_logs() {

    echo "Before: $(find /var/log -type f | wc -l) files ($(du /var/log -h -s | awk '{ print $1 }'))"

    journalctl --vacuum-time=1s
    dmesg -c

    #https://unix.stackexchange.com/questions/184488/command-to-clean-up-old-log-files
    find /var/log/ -type f -regex '.*\.[0-9]+\.gz$' -delete
    find /var/log -type f -name "*.log" | xargs -i{} truncate -s 0 {}

    echo "After: $(find /var/log -type f | wc -l) files ($(du /var/log -h -s | awk '{ print $1 }'))"

    __end_note
}

#function __track_etc() {
#
#    pushd /etc
#    etckeeper init
#    etckeeper commit "commit at $(date '+%Y-%m-%d %H:%M:%S')"
#    popd
#    __end_note
#}


function __any_errors() {

    grep -rins --include="*.log" "error\|warn\|critical\|fatal\|fail\|panic" /var/log
    dmesg | egrep -i "error\|warn\|critical\|fatal\|fail\|panic"
    __end_note
}


function __update() {

    curl https://raw.githubusercontent.com/abassel/dotfiles/master/boot.sh | bash

}


function __help() {

    echo "USE-AS-IS"
    echo ""
    echo "__update - update rc scripts"
    echo "__any_errors - grep for errors"
    echo "__wipe_all_logs - wipe all your logs"
    echo "__track_etc - git init the /etc"
    echo ""
}


# Openstack lxc functions for AIO
export LXC_LOGS="True"

function l-barbican() {
    lxc-attach -n $(lxc-ls -1 | grep barbican | sort | head -${1:-1} | tail -1)
}

function l-nova() {
    lxc-attach -n $(lxc-ls -1 | grep noval | sort | head -${1:-1} | tail -1)
}

function l-util() {
    lxc-attach -n $(lxc-ls -1 | grep util | sort | head -${1:-1} | tail -1)
}
