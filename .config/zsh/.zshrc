

# TODO: continue here: https://www.arp242.net/zshrc.html

export ZSH_DISABLE_COMPFIX="true"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.poetry/bin:/usr/local/opt/opencv@2/bin"
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH" # Support new gnu make 4.3 (brew install make) rather than default 3.8
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"  # point to gnu-sed so h alias does not break with: sed: RE error: illegal byte sequence
export PATH="/opt/homebrew/bin/:$PATH"

# Require -> sudo pacman -S extra/zsh-completions
# https://stackoverflow.com/questions/29196718/zsh-highlight-on-tab
zstyle ':completion:*' menu select
autoload -Uz compinit
compinit

# Alias and exports definitions.
. ~/.config/zsh/alias_exports.sh

# Source Functions
. ~/.config/zsh/functions.sh


# CUSTOM History configuration
HISTFILE="$HOME/Documents/zsh_history.$(hostname -s).txt"    # So it gets synced

# https://zsh.sourceforge.io/Doc/Release/Options.html
setopt BANG_HIST                # Treat the '!' character specially during expansion.
unsetopt EXTENDED_HISTORY       # NOTE: also duplicated after oh-my-zsh
setopt SHARE_HISTORY            # Share history between all sessions.
setopt HIST_IGNORE_SPACE        # Don't record an entry starting with a space.
unsetopt APPEND_HISTORY         # Append rather than write to history
unsetopt appendhistory
unsetopt INC_APPEND_HISTORY     # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history.
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY              # Don't execute immediately upon history expansion.
setopt HIST_BEEP                # Beep when accessing nonexistent history.
# setopt EXTENDED_HISTORY       # Write the history file in the ":start:elapsed;command" format.
# setopt SHARE_HISTORY          # Share history between all sessions.
# setopt HIST_IGNORE_DUPS       # Don't record an entry that was just recorded again.
# setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded entry if new entry is a duplicate.
# setopt HIST_IGNORE_SPACE      # Don't record an entry starting with a space.
# setopt HIST_SAVE_NO_DUPS      # Don't write duplicate entries in the history file.

unsetopt extended_history       # Disable extended history
unsetopt INC_APPEND_HISTORY     # Disable extended history

function sync_history() {
    history -a > /dev/null
    cp $HISTFILE $HISTFILE.bak
    echo -e "\e[33mBackup created at $HISTFILE.bak"
    # https://programmersought.com/article/85011433888/
    # Error during sorting
    echo -e "\e[33mMerging:"
    wc -l ~/Documents/zsh_history*.txt
    echo ""
    \cat ~/Documents/zsh_history*.txt | sed --binary 's/^[^;]*;//'  | awk '!a[$0]++' | LC_ALL=C sort -u > $HISTFILE
    echo -e "\e[33mSyncronized $(wc -l $HISTFILE) lines"
    history -r > /dev/null
}

function dedup_history() {
    # Dedup and filter history
    cp $HISTFILE $HISTFILE.dedupe.bak
    echo -e "\e[33mBefore dedup -> $(wc -l $HISTFILE) lines"
    # cat $HISTFILE | LC_ALL=C sed 's/.*:0;//' | LC_ALL=C sort -u > $HISTFILE.dedup
    cat $HISTFILE | LC_ALL=C sort -t ';' -uk2 | LC_ALL=C sort -nk1 | LC_ALL=C cut -f2- > $HISTFILE.dedup
    cat $HISTFILE.dedup | grep -vE "\-\-help|\-\-version|function|mkdir|mkdir|yarn add|yarn instal|npm install|gitinit|git commit -m|git add|git checkout|brew info|brew install|brew search|brew cask install|brew cask info|cd " > $HISTFILE
    echo -e "\e[33mAfter dedup $(wc -l $HISTFILE) lines"
    # https://forum.manjaro.org/t/zsh-history-file-without-duplicates/123317
    # https://www.quora.com/How-do-I-remove-duplicates-and-sort-entries-in-zsh-history
    # https://unix.stackexchange.com/questions/48713/how-can-i-remove-duplicates-in-my-bash-history-preserving-order
    # \cat -n $HISTFILE | LC_ALL=C sort -t ';' -uk2 | LC_ALL=C sort -nk1 | cut -c8- | sort -n
}


# https://stackoverflow.com/questions/12382499/looking-for-altleftarrowkey-solution-in-zsh
# https://stackoverflow.com/questions/8638012/fix-key-settings-home-end-insert-delete-in-zshrc-when-running-zsh-in-terminat
# To know the code of a key, execute cat, press enter, press the key, then Ctrl+C.
bindkey "^[[1;5D" backward-word  # control + left arrow
bindkey "^[[1;5C" forward-word   # control + right arrow

# Enable generic colorizer
[[ -s "/usr/local/etc/grc.zsh" ]] && source /usr/local/etc/grc.zsh


# Required Multi Byte character.
export LC_ALL="en_US.UTF-8"

if type brew &>/dev/null; then
    eval "$($(brew --prefix)/bin/brew shellenv)"
fi

# Load powerlevel 10k
source ~/.config/powerlevel10k_github/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.config/zsh/p10k.zsh


# Github cli completition
eval "$(gh completion --shell zsh)"


# Requires -> brew install zsh-completions
# compinit  # Required for poetry autocomplet
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    #FPATH=~/zsh-completions:$FPATH
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

source ~/.config/scripts/fzf.zsh


if [ -f ~/.config/private/secrets.sh ]; then
    . ~/.config/private/secrets.sh
fi

export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"

export PATH="/opt/homebrew/opt/node@18/bin:$PATH"

# https://github.com/danielmiessler/fabric/tree/main#environment-variables
# Golang environment variables for fabric
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
# Update PATH to include GOPATH and GOROOT binaries
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH