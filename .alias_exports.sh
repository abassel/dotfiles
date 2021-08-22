
#Get OS name via uname
# https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
_myos=$(uname)

# General
alias e='exit'
alias c='clear'
alias h=' cat $HISTFILE | grep '
alias d='__debug'

# https://unix.stackexchange.com/questions/83342/how-to-keep-dotfiles-system-agnostic
case $_myos in
  'Linux')   alias u='apt update -y; apt upgrade -y; echo "\n"' ;;
  'FreeBSD') alias u='echo NOT IMPLEMENTED' ;;
  'Darwin')  alias u='brew update; brew upgrade; brew upgrade --cask' ;;
esac

# LS
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# network
alias ports='netstat -tulanp'

# Git
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gca='git commit --amend'

########################################
# EXPORTS
########################################

# history configuration
# BASH
export HISTSIZE=                 # the number of commands to remember in the command history (the default value is 500).
export HISTFILESIZE=             # the maximum number of lines contained in the history file (the default value is 500).
# ZSH https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
#export HISTSIZE=100000000
export SAVEHIST=100000000