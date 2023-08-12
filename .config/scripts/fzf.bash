# Setup fzf
# ---------
if [[ ! "$PATH" == */home/alex/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/alex/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/alex/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/alex/.fzf/shell/key-bindings.bash"
