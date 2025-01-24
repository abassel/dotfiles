


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

# https://wiki.archlinux.org/title/XDG_Base_Directory
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc

# https://wiki.archlinux.org/title/XDG_Base_Directory
export GVIMINIT='let $MYGVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/gvimrc" : "$XDG_CONFIG_HOME/nvim/init.gvim" | so $MYGVIMRC'
export VIMINIT='let $MYVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/vimrc" : "$XDG_CONFIG_HOME/nvim/init.vim" | so $MYVIMRC'


# https://unix.stackexchange.com/questions/83342/how-to-keep-dotfiles-system-agnostic
# Get OS name via uname
# https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
# Remove whitespace and convert to lowercase for matching
_myos=$(echo "$(uname -a)" | tr '[:upper:]' '[:lower:]')

# Define aliases based on OS
case $_myos in
  *"ubuntu"*|*"debian"* ) alias u='sudo apt update -y && sudo apt upgrade -y && echo -e "Consider ${YELLOW}apt dist-upgrade -y${NC}"' ;;
  *"arch"*|*"manjaro"* ) alias u='sudo pacman -Syuu --noconfirm && yay -Syuu --noconfirm' ;;
  *"darwin"* ) alias u='brew update; brew upgrade; brew upgrade --cask --greedy; brew cleanup; rm -rf $(brew --cache)' ;;
  * ) echo "(Unknown OS) -> $_myos" ;;
esac

case $_myos in
  *'linux'* )  alias open='xdg-open' && alias pbcopy='wl-copy' && alias pbpaste='wl-paste';;
esac

case $_myos in
  *'linux'* )  alias code='vscodium' ;;
  *'darwin'* ) alias code='/Applications/VSCodium.app/Contents/MacOS/Electron' ;;
esac


case $_myos in
  *'linux'* ) alias o='xdg-open $(git remote get-url origin | sed "s,git@,https://," | sed "s,:2222,," | sed "s,:2233,," | sed "s,.com:,.com/," | sed "s,ssh://,,")' ;;
  *'freebsd'* ) alias o='echo NOT IMPLEMENTED' ;;
  *'darwin'* ) alias o='open -a "Safari" $(git remote get-url origin | sed "s,git@,https://," | sed "s,:2222,," | sed "s,:2233,," | sed "s,.com:,.com/," | sed "s,ssh://,,")' ;;
esac


# https://github.com/danielmiessler/fabric/tree/main#environment-variables
# Golang environment variables for fabric ai/go/goproxy
case $_myos in
  *"darwin"* ) # Mac
    export GOROOT=$(brew --prefix go)/libexec
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
    ;;

  *'linux'* ) # Linux
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
    ;;

  *)
    echo "Unsupported go configuration for OS: $_myos" >&2
    ;;
esac


# Dot file management
# https://www.youtube.com/watch?v=tBoLDpTWVOM
# https://www.atlassian.com/git/tutorials/dotfiles
# make sure you have -> git init --bare $HOME/dotfiles
# alias config='git --git-dir=$HOME/dotfiles --work-tree=$HOME'
# see functions.sh
# then -> config config --local status.showUntrackedFiles no

# /etc managed by git
#alias etc='sudo git --git-dir=/etc/.git --work-tree=/etc'
# see functions.sh

# ~/notes managed by git
# see functions.sh


# Youtube download - requires `sudo pacman -S yt-dlp` or `brew install yt-dlp`
alias ydl='yt-dlp -o "%(playlist_index)s-%(title)s by %(uploader)s on %(upload_date)s in %(playlist)s.%(ext)s" --format "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" '
alias ydl_audio='yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 ' # extracted audio (between 0 (best) and 10 (worst), default = 5):


# LS
alias ll='ls -alF'
alias la='ls -A'
alias l='lsd --group-directories-first'
alias ls='lsd -la --group-directories-first'
alias lt='lsd -la --tree --depth 2 --group-directories-first'
alias ltt='lsd -la --tree --depth 3 --group-directories-first'
alias lttt='lsd -la --tree --depth 4 --group-directories-first'
alias ltttt='lsd -la --tree --depth 5 --group-directories-first'

# tldr help (sudo pacman -S tealdeer)
alias help='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'


# pacman
alias pacman_cache_delete_older_than_3='sudo paccache -r'
alias pacman_delete_prog_and_dependnecies='sudo pacman -Rscn'
alias pacman_download_updates='sudo pacman -Syuw --noconfirm'  # TODO: add to cron
alias pacman_find_file='pacman -F'
alias pacman_find_file_regex='pacman -Fx'
alias pacman_info='pacman -Si'
alias pacman_orphan_list='pacman -Qdtq'
alias pacman_orphan_delete='sudo pacman -Qdtq | xargs -I{} sudo pacman -Rscn {} --noconfirm'
alias pacman_search_package='pacman -Ss'
alias pacman_update='sudo pacman -Suuy'
alias pacman_owned_by='pacman -Qoq'   # https://wiki.archlinux.org/title/Python
alias pacman_find_browser="pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"


# network
alias ports='netstat -tulanp'

# IP addresses
alias ip_pub="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip_local="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ips="ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias myip=ip_pub

# AI
# Requires entry for ollama.server in /etc/hosts -> sudo vi /etc/hosts
alias aider_ollama="OLLAMA_API_BASE=http://127.0.0.1:11434 aider --analytics-disable --model=ollama/llama3.1:8b --no-auto-commits"
alias aider_qwen="OLLAMA_API_BASE=http://127.0.0.1:11434 aider --analytics-disable --model=ollama/qwen2.5-coder:14b --no-auto-commits"
# Using ssh tunnel instead of ollama.server
export OLLAMA_HOST=127.0.0.1:11434 # for OLLAMA cli
export OLLAMA_API_URL=http://127.0.0.1:11434 # for fabric
alias ai_proxy_ollama="ssh -L 11434:localhost:11434 nvidia journalctl -f -u ollama"
alias ai_create_pattern='fabric --pattern create_pattern'

# Git
alias ga='git add'
alias gl="git log --color --graph --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gl2="git log --color --graph --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gl3="git log --color --graph --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias branches_all="git branch -r  | grep -v HEAD | xargs -L1 git show -s --oneline --pretty=format:'-%C(auto)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset - %s%n'"  # https://stackoverflow.com/questions/36026374/is-there-a-script-to-list-git-branches-created-by-me
alias branches2_all="git branch -r | grep -v HEAD | xargs -L1 git show -s --oneline --pretty=format:'-%C(auto)%d%Creset %Cgreen(%ci) %C(bold blue)<%an>%Creset - %s%n'"
alias branches3_all="git branch -r | grep -v HEAD | xargs -L1 git show -s --oneline --pretty=format:'-%C(auto)%d%Creset %Cgreen(%cD) %C(bold blue)<%an>%Creset - %s%n'"
alias branches="git branch -r --no-merge  | grep -v HEAD | xargs -L1 git show -s --oneline --pretty=format:'-%C(auto)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset - %s%n'"  # https://stackoverflow.com/questions/36026374/is-there-a-script-to-list-git-branches-created-by-me
alias branches2="git branch -r --no-merge | grep -v HEAD | xargs -L1 git show -s --oneline --pretty=format:'-%C(auto)%d%Creset %Cgreen(%ci) %C(bold blue)<%an>%Creset - %s%n'"
alias branches3="git branch -r --no-merge | grep -v HEAD | xargs -L1 git show -s --oneline --pretty=format:'-%C(auto)%d%Creset %Cgreen(%cD) %C(bold blue)<%an>%Creset - %s%n'"
alias b="git log --color --graph --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --simplify-by-decoration --all"
alias b2="git log --color --graph --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit --simplify-by-decoration --all"
alias b3="git log --color --graph --pretty=format:'%C(yellow)%h%C(reset) -%C(auto)%d%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --abbrev-commit --simplify-by-decoration --all"
alias gdangling='git log --oneline --graph $(git fsck --no-reflog | grep "dangling commit" | cut -d " " -f 3)'  # https://stackoverflow.com/questions/89332/how-do-i-recover-a-dropped-stash-in-git
alias gwipe='DANGER git reflog expire --expire=30.days.ago --expire-unreachable=now --all; git gc --prune=now --aggressive'
alias gs='git status'
alias gsi='git status --ignored'
alias i='git status --ignored'
alias gd='git diff'
alias gds='git diff --staged'
alias gds_unified10='git diff --staged --unified=10'
alias gds_unified20='git diff --staged --unified=20'
alias gds_funct_context='git diff --staged --function-context'
alias gca='git commit --amend'
alias gls='git ls-files'
alias git_ai="sed 's/{{/{ {/g'  | fabric --model 'qwen2.5-coder:7b' --pattern summarize_git_diff --temperature 0 --modelContextLength 32000"
alias ai_git=git_ai
# gb (git branch create) is defined as function
# alias branch='gb'
#alias b='gh browse'
# alias o='open -a "Safari" $(git remote get-url origin | sed "s,git@,https://," | sed "s,:2222,," | sed "s,.com:,.com/," | sed "s,ssh://,,")'
alias git_config='git config --list --show-origin'
alias git_show_merged_branches='git branch --merged | grep -v "\*"'
alias git_delete_merged_branches='git branch --merged | grep -v "\*" | xargs git branch -d'
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
alias git_rebase='git rebase --rebase-merges --committer-date-is-author-date'
alias rebase='git_rebase'
alias r='git_rebase'
alias prs="gh pr list --json number,title,author,updatedAt,mergeStateStatus,url --template '{{range .}}{{tablerow (printf \"#%v\" .number | autocolor \"green\") .title .author.login (timeago .updatedAt) .mergeStateStatus .url}}{{end}}'"

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
--color=fg+:bright-yellow
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
