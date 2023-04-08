# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source Functions
if [ -f ~/.functions.sh ]; then
    . ~/.functions.sh
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.


# Source alias and exports
if [ -f ~/.alias_exports.sh ]; then
    . ~/.alias_exports.sh
fi

######### HISTORY section #########

# https://www.shellhacks.com/tune-command-line-history-bash/


# append to the history file, don't overwrite it
shopt -s histappend


# export PROMPT_COMMAND='history -a;history -c;history -r'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# localization
export LC_TERMINAL=iTerm2
export LC_TERMINAL_VERSION=3.4.2
export LC_ALL=en_US.UTF-8

PROMPT_COMMAND=__prompt_command # Func to gen PS1 after CMDs

__prompt_command() {
    local EXIT="$?"                      # This needs to be first

    local Red='\[\e[1;31m\]'
    local Gre='\[\e[0;32m\]'
    local LGREY='\[\e[1;30m\]'
    local BLACK='\[\e[0;30m\]'
    local BYel='\[\e[1;33m\]'
    local BBlu='\[\e[1;34m\]'
    local CYAN='\[\e[0;36m\]'
    local Pur='\[\e[0;35m\]'
    local RCol='\[\e[0m\]'

    CHAR="_"
    LINECOLOR=$BLACK
    if [ $EXIT != 0 ]; then
        CHAR="@"
        LINECOLOR=$Red             # Add red if exit code non 0
    fi

    HLINE=$(printf %"$COLUMNS"s | tr " " $CHAR)
    PS1="\n${LINECOLOR}${HLINE}${RCol}\n"
    PS1+="\n${BBlu}\342\226\210\342\226\210 \u @ ${Red}\h ${BBlu}\w\n${CYAN}\342\226\210\342\226\210 jobs:\j \$ ${RCol}"

}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# Color man pages https://www.tecmint.com/view-colored-man-pages-in-linux/
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Disable pager for systemd
# https://unix.stackexchange.com/questions/343168/can-i-prevent-service-foo-status-from-paging-its-output-through-less
export SYSTEMD_PAGER=''


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Source openrc if you have one
if [ -f ~/openrc ]; then
    . ~/openrc
fi

# Load completition fzf-tab https://github.com/lincheney/fzf-tab-completion#bash 
if [ -f ~/fzf-bash-completion.sh ]; then
    . ~/fzf-bash-completion.sh
    bind -x '"\t": fzf_bash_completion'
fi


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
