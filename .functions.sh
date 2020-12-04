#!/usr/bin/env bash

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

function __track_etc() {

    pushd /etc
    etckeeper init
    etckeeper commit "commit at $(date '+%Y-%m-%d %H:%M:%S')"
    popd
    __end_note
}


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
