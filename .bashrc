# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


######### HISTORY section #########

# https://www.shellhacks.com/tune-command-line-history-bash/


# append to the history file, don't overwrite it
shopt -s histappend


HISTSIZE=                 # the number of commands to remember in the command history (the default value is 500).
HISTFILESIZE=             # the maximum number of lines contained in the history file (the default value is 500).
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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ports='netstat -tulanp'

alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gca='commit --amend'

alias e='exit'
alias c='clear'
alias h='history'


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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# Source Functions
if [ -f ~/.functions.sh ]; then
    . ~/.functions.sh
fi

# Load completition fzf-tab https://github.com/lincheney/fzf-tab-completion#bash 
if [ -f ~/fzf-bash-completion.sh ]; then
    . ~/fzf-bash-completion.sh
    bind -x '"\t": fzf_bash_completion'
fi

# https://medium.com/better-programming/boost-your-command-line-productivity-with-fuzzy-finder-985aa162ba5d
# https://hschne.at/2020/04/25/creating-a-fuzzy-shell-with-fzf-and-friends.html
export FZF_DEFAULT_OPTS="
-i
--ansi
--bold
--reverse
--info=inline
--height=80%
--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
--prompt='∼ ' 
--pointer='▶'
--marker='✓'
--bind '?:toggle-preview'
--bind 'tab:down'
"
