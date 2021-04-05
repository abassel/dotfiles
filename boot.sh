#!/usr/bin/env bash

export _apps='tree lsof jq vim git wget crudini bash-completion git telnet sed screen tmux man-db' # glances colordiff python3-pip python3 python-pygments'

function __install_all {

    # Try to run in both Centos and Ubuntu
    apt-get install -y $_apps || yum install -y $_apps || apk add $_apps

    # Remove timeout
    sed --in-place '/TMOUT/d' /etc/profile

    cd ~
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.vimrc
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.bashrc
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.functions.sh
    wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.screenrc
    # wget --backups=3 https://raw.githubusercontent.com/abassel/dotfiles/master/.inputrc
    wget --backups=3 https://raw.githubusercontent.com/lincheney/fzf-tab-completion/master/bash/fzf-bash-completion.sh

    ##########################################################
    # BAT https://github.com/sharkdp/bat/releases
    ##########################################################
    wget https://github.com/sharkdp/bat/releases/download/v0.18.0/bat-musl_0.18.0_amd64.deb
    apt install ./bat-musl_0.18.0_amd64.deb
    rm bat-musl_0.18.0_amd64.deb
    
    ##########################################################
    # FZF - https://github.com/junegunn/fzf#using-git
    ##########################################################
    rm -rf  ~/.fzf
    git clone  https://github.com/junegunn/fzf.git ~/.fzf
    cd ~/.fzf
    git fetch --all --tags
    tag=$(git describe --tags `git rev-list --tags --max-count=1`)
    echo FZF v. $tag
    git checkout $tag
    ./install

    source ~/.bashrc

    # vim plugin install
    # git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    # vim -c 'PluginInstall' -c 'qa!'  # https://coderwall.com/p/etzycq/vundle-plugininstall-from-shell
    # Also vim +PluginInstall +qall  # https://www.reddit.com/r/bash/comments/8vw0t0/how_to_automatically_install_vundle_and_plugins/

}

__install_all;

