
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
  'Linux')   alias u='apt update -y; apt upgrade -y; echo "Consider apt dist-upgrade -y"' ;;
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
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
# https://medium.com/@prasincs/hiding-secret-keys-from-shell-history-part-1-5875eb5556cc

export HISTSIZE=                 # the number of commands to remember in the command history (the default value is 500).
export HISTFILESIZE=             # the maximum number of lines contained in the history file (the default value is 500).
#export HISTSIZE=100000000
export SAVEHIST=100000000
export HISTORY_IGNORE="(ls|ll|exit|clear|history|gs|rm|whois|e|c|u|h)"


## Compiler exports

# For compilers to find sqlite:
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/sqlite/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/sqlite/include"

# For compilers to find zlib:
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/zlib/include"

# For pkg-config to find zlib:
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"

# For compilers to find openssl@1.1:
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/openssl@1.1/include"

# For pkg-config to find openssl@1.1:
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/openssl@1.1/lib/pkgconfig"

# For compilers to find opencv@2:
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/opencv@2/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/opencv@2/include"

# For pkg-config to find opencv@2:
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/opencv@2/lib/pkgconfig"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion
