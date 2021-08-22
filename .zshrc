
# Source Functions
if [ -f ~/.functions.sh ]; then
    . ~/.functions.sh
fi

# Alias and exports definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.alias_exports.sh ]; then
    . ~/.alias_exports.sh
fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export PATH="/usr/local/sbin:$PATH"

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.poetry/bin:/usr/local/opt/opencv@2/bin"

# Start pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"



# History configuration
HISTFILE="$HOME/Documents/zsh_history.$(hostname).txt"    # So it gets synced
HISTSIZE=100000000
SAVEHIST=100000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
# setopt EXTENDED_HISTORY           # Write the history file in the ":start:elapsed;command" format.
unsetopt EXTENDED_HISTORY           # NOTE: also duplicated after oh-my-zsh
setopt APPEND_HISTORY               # Append rather than write to history
setopt appendhistory
unsetopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
# setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
# setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
# setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
#setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
#setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.




# Source Functions
if [ -f ~/.functions.sh ]; then
    . ~/.functions.sh
fi

function sync_history() {
    history -a > /dev/null
    cp $HISTFILE $HISTFILE.bak
    echo -e "\e[33mBackup created at $HISTFILE.bak"
    # https://programmersought.com/article/85011433888/
    # Error during sorting
    echo -e "\e[33mMerging:"
    #ls -1 ~/Documents/zsh_history*.txt
    wc -l ~/Documents/zsh_history*.txt
    echo ""
    cat ~/Documents/zsh_history*.txt | LC_ALL=C sort -u | uniq > $HISTFILE
    echo -e "\e[33mSyncronized $(wc -l $HISTFILE) lines"
    history -r > /dev/null
}

function dedup_history() {
    echo "Not yet implemented"
    # https://forum.manjaro.org/t/zsh-history-file-without-duplicates/123317
    # https://www.quora.com/How-do-I-remove-duplicates-and-sort-entries-in-zsh-history
    # https://unix.stackexchange.com/questions/48713/how-can-i-remove-duplicates-in-my-bash-history-preserving-order
    # \cat -n $HISTFILE | LC_ALL=C sort -t ';' -uk2 | LC_ALL=C sort -nk1 | cut -c8- | sort -n
}

# Colored man pages
# https://apple.stackexchange.com/questions/182320/is-there-a-way-to-color-parts-of-the-man-pages-on-the-terminal/182344
# man() {
# 	env \
# 		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
# 		LESS_TERMCAP_md=$(printf "\e[1;31m") \
# 		LESS_TERMCAP_me=$(printf "\e[0m") \
# 		LESS_TERMCAP_se=$(printf "\e[0m") \
# 		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
# 		LESS_TERMCAP_ue=$(printf "\e[0m") \
# 		LESS_TERMCAP_us=$(printf "\e[1;32m") \
# 		man "$@"
# }

export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode - red
export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode - bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode - yellow
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode - cyan


# https://stackoverflow.com/questions/12382499/looking-for-altleftarrowkey-solution-in-zsh
# https://stackoverflow.com/questions/8638012/fix-key-settings-home-end-insert-delete-in-zshrc-when-running-zsh-in-terminat
# To know the code of a key, execute cat, press enter, press the key, then Ctrl+C.
# bindkey "^[^[[D" backward-word  # option + left arrow
# bindkey "^[^[[C" forward-word   # option + right arrow
bindkey "^[[1;5D" backward-word  # control + left arrow
bindkey "^[[1;5C" forward-word   # control + right arrow


function copy_patch() {
    files2patch=($(git ls-files --others --exclude-standard))

    # put all untracked files in the patch
    for file in $files2patch; do git add --intent-to-add $file; done

    git diff HEAD | pbcopy
    echo "==== Generating patch in clipboard for the files below ===="
    git diff HEAD --name-only | cat

    # restore untracked files as untracked
    for file in $files2patch; do git reset HEAD $file; done
}

function copy_patch_no_untracked() {

    git diff HEAD | pbcopy
    echo "==== Generating patch in clipboard for the files below ===="
    git diff HEAD --name-only | cat

}

function paste_patch() {
    pbpaste | git apply
}


alias kc="kubectl"
alias cat='bat --paging=never'
alias ping='prettyping'

alias serve="python -m SimpleHTTPServer &"


# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="iconic"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(poetry git-extras git-flow git-hubflow docker jira dotenv yarn kubectl pip pyenv pylint)

# User configuration

source $ZSH/oh-my-zsh.sh

# Disable extended history
unsetopt extended_history
unsetopt INC_APPEND_HISTORY

# Enable generic colorizer
[[ -s "/usr/local/etc/grc.zsh" ]] && source /usr/local/etc/grc.zsh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Required Multi Byte character.
export LC_ALL="en_US.UTF-8"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# CUSTOM ICONIC CONFIGURATION
export ZSH_POWERLINE_SHOW_USER=false
export PATH="/usr/local/sbin:$PATH"
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Github cli completition
eval "$(gh completion --shell zsh)"

compinit  # Required for poetry autocomplet


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Auto Correct types in commands
# https://scriptingosx.com/2019/06/moving-to-zsh-part-3-shell-options/
# setopt CORRECT

# FZF Color themes
# https://github.com/junegunn/fzf/wiki/Color-schemes
export FZF_DEFAULT_OPTS='
--color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254
--color info:254,prompt:37,spinner:108,pointer:235,marker:235
'

export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"
