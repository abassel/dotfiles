#!/usr/bin/env bash

export _apps='tree lsof jq vim git wget crudini'

function _install_all {

    # Try to run in both Centos and Ubuntu
    apt-get install -y $_apps || yum install -y $_apps

    cd ~
    wget https://raw.githubusercontent.com/abassel/utilites/master/.vimrc

}

_install_all
