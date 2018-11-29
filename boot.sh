#!/usr/bin/env bash

export _apps='tree lsof jq vim git wget crudini bash-completion git etckeeper glances'

function _install_all {

    # Try to run in both Centos and Ubuntu
    apt-get install -y $_apps || yum install -y $_apps

    cd ~
    wget https://raw.githubusercontent.com/abassel/utilites/master/.vimrc

    cd /etc/
    etckeeper init
    etckeeper commit -m "Initial checkin"

}

_install_all
