
# General
alias e='exit'
alias c='clear'
# alias h='history' # replaced by function
alias d='__debug'

# https://unix.stackexchange.com/questions/83342/how-to-keep-dotfiles-system-agnostic
case $(uname) in
  'Linux')   alias u='apt update -y; apt upgrade -y' ;;
  'FreeBSD') LS_OPTIONS='-Gh -D "%F %H:%M"' ;;
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
alias gca='commit --amend'

