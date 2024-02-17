# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.config/fzf_github/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.config/fzf_github/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.config/fzf_github/shell/key-bindings.zsh"
