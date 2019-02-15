#!/usr/bin/env bash

export _apps='tree lsof jq vim git wget crudini bash-completion git etckeeper glances colordiff telnet sed'

function __install_all {

    # Remove timeout
    sed '/TMOUT/d' file /etc/profile

    # Try to run in both Centos and Ubuntu
    apt-get install -y $_apps || yum install -y $_apps

    cd ~
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.vimrc
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.bashrc
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.functions.sh
    # wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.inputrc

    source ~/.bashrc

}

__install_all
