
#Get OS name via uname
# https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
_myos=$(uname)

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# General
alias e='exit'
alias c='clear'
alias kc="kubectl"
if $(which bat >& /dev/null); then alias cat='bat --paging=never'; fi
alias ping='prettyping'
alias serve="python -m SimpleHTTPServer &"

# https://unix.stackexchange.com/questions/83342/how-to-keep-dotfiles-system-agnostic
case $_myos in
  'Linux')   alias u='apt update -y; apt upgrade -y; echo -e "Consider ${YELLOW}apt dist-upgrade -y${NC}"' ;;
  'FreeBSD') alias u='echo NOT IMPLEMENTED' ;;
  'Darwin')  alias u='brew update; brew upgrade; brew upgrade --cask --greedy; brew cleanup; rm -rf $(brew --cache)' ;;
esac

# Dot file management
# https://www.youtube.com/watch?v=tBoLDpTWVOM
# https://www.atlassian.com/git/tutorials/dotfiles
# make sure you have -> git init --bare $HOME/dotfiles
alias config='git --git-dir=$HOME/dotfiles --work-tree=$HOME'
# then -> config config --local status.showUntrackedFiles no

# LS
alias ll='ls -alF'
alias la='ls -A'
alias l='lsd --group-directories-first'
alias ls='lsd -la --group-directories-first'
alias lt='lsd -la --tree --depth 2 --group-directories-first'
alias ltt='lsd -la --tree --depth 3 --group-directories-first'
alias lttt='lsd -la --tree --depth 4 --group-directories-first'
alias ltttt='lsd -la --tree --depth 5 --group-directories-first'

# network
alias ports='netstat -tulanp'

# IP addresses
alias ip_pub="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip_local="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ips="ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias myip=ip_pub

# Git
alias ga='git add'
alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gl2="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gl3="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias branches="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --simplify-by-decoration --all"
alias branches2="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit --simplify-by-decoration --all"
alias branches3="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --abbrev-commit --simplify-by-decoration --all"
alias gdangling='git log --oneline --graph $(git fsck --no-reflog | grep "dangling commit" | cut -d " " -f 3)'  # https://stackoverflow.com/questions/89332/how-do-i-recover-a-dropped-stash-in-git
alias gwipe='DANGER git reflog expire --expire=30.days.ago --expire-unreachable=now --all; git gc --prune=now --aggressive'
alias gs='git status'
alias gd='git diff'
alias gca='git commit --amend'
# gb (git branch create) is defined as function
# alias branch='gb'
#alias b='gh browse'
alias b='open -a "Safari" $(git remote get-url origin | sed "s,git@,https://," | sed "s,.com:,.com/," )'
alias pr='gh pr create'
alias p='git push'
alias pf='git push --force-with-lease'
alias s='hub sync all'
alias m='git checkout main'
alias mm='git checkout -'
alias stash='git stash save --include-untracked "🚧 WIP 🚧 $(date +%b/%d_%H:%M:%S)"'
alias gpop='git stash pop'
# https://softwaredoug.com/blog/2022/11/09/idiot-proof-git-aliases.html
alias gp="git remote show origin | sed -n '/HEAD branch/s/.*: //p'"
alias rebasei='git rebase -v -i $(gp)'

# alias gp='git show-branch \
# | sed "s/].*//" \
# | grep "\*" \
# | grep -v "$(git rev-parse --abbrev-ref HEAD)" \
# | head -n1 \
# | sed "s/^.*\[//"'

# Modified from the above:
# https://gist.github.com/joechrysler/6073741

########################################
# EXPORTS
########################################

# HISTORY
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
# https://medium.com/@prasincs/hiding-secret-keys-from-shell-history-part-1-5875eb5556cc

export HISTSIZE=                 # the number of commands to remember in the command history (the default value is 500).
export HISTFILESIZE=             # the maximum number of lines contained in the history file (the default value is 500).
export HISTSIZE=100000000
export SAVEHIST=100000000
export HISTORY_IGNORE="(ls|ll|l|config|review|exit|clear|history|man|tldr|bro|gs|rm|whois|bat|cp|cd|cdf|w|e|c|u|h|s|m|pr|b|d|gb|gl|gl1|gl2|gl3|glf|__help)"

# PIP - https://stackoverflow.com/questions/27410821/how-to-prevent-pip-install-without-virtualenv
export PIP_REQUIRE_VIRTUALENV=true
# to install globally use gpip OR --> PIP_REQUIRE_VIRTUALENV="" pip

# MAN/LESS
export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode - red
export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode - bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode - yellow
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode - cyan

# FZF
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

# # OLD FZF Color themes
# # https://github.com/junegunn/fzf/wiki/Color-schemes
# export FZF_DEFAULT_OPTS='
# --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254
# --color info:254,prompt:37,spinner:108,pointer:235,marker:235
# '

# Tools and utilities
# Start pyenv
#export PYENV_ROOT="$HOME/.pyenv"
#export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion



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

# For bson (binary json) to be found by other tools:
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/bison/lib"

# For nodejs 18
export LDFLAGS="-L/opt/homebrew/opt/node@18/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@18/include"