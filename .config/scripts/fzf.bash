# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.config/fzf_github/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.config/fzf_github/bin"
fi

# Auto-completion
# ---------------
source "$HOME/.config/fzf_github/shell/completion.bash"

# Key bindings
# ------------
source "$HOME/.config/fzf_github/shell/key-bindings.bash"
