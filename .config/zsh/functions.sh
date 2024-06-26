#!/usr/bin/env bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
MAGENTABRIGHT='\u001b[35;1m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

function debug() {
    echo -e "Running Strace for command --> ${YELLOW} $@ ${NC}\n"
    strace -f -t -e trace=file $@
}

# global install pip
# https://stackoverflow.com/questions/27410821/how-to-prevent-pip-install-without-virtualenv
function gpip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

function ai() {
    local model
    local question

    # If only one parameter is specified, assume the other one is default
    if [[ $# == 1 ]]; then
        model="codellama"
        question=$1
    else
        model=$1
        question=$2
    fi

    echo "${YELLOW}==============================${NC}"
    echo -e "Running model ${YELLOW}${model}${NC} for question:\n${MAGENTABRIGHT}$question${NC}"
    echo ""
    ollama run $model $question
}

function ai_all() {

    local question

    # If only one parameter is specified, assume the other one is default
    if [[ $# == 1 ]]; then
        question=$1
    else
        echo "Provide only one parameter - question surrounded with quotes."
        exit 1
    fi

    ollama list | awk 'NR>1 {print $1}' | sort -t ':' -k 2 -n | xargs -I% zsh -c "source ~/.config/zsh/.zshrc && ai % '$question'"

}

function ai_code() {

    local question

    # If only one parameter is specified, assume the other one is default
    if [[ $# == 1 ]]; then
        question=$1
    else
        echo "Provide only one parameter - question surrounded with quotes."
        exit 1
    fi

    ollama list | awk 'NR>1 {print $1}' | grep "code" | sort -t ':' -k 2 -n | xargs -I% zsh -c "source ~/.config/zsh/.zshrc && ai % '$question'"

}


function ai_nocode() {

    local question

    # If only one parameter is specified, assume the other one is default
    if [[ $# == 1 ]]; then
        question=$1
    else
        echo "Provide only one parameter - question surrounded with quotes."
        exit 1
    fi

    ollama list | awk 'NR>1 {print $1}' | grep -v "code" | sort -t ':' -k 2 -n | xargs -I% zsh -c "source ~/.config/zsh/.zshrc && ai % '$question'"

}


# select branch via fzf
function __branch() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254 \
        --color info:254,prompt:37,spinner:108,pointer:235,marker:235 \
        --layout=default \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'" | sed 's/origin\///g') || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

function gb() {
    if [[ "$#" == 0 ]]; then
        __branch;
        return
    fi
    echo -e "${YELLOW} Creating a new branch ${NC} $1 \n"
    hub sync all
    git checkout -b $1
    git push -u origin $1
    git commit --allow-empty -m "🏁 Starting $1 $(date +%b/%d_%H:%M:%S)"
}

function ggrep() {
    echo -e "${YELLOW} Searching for ${NC} $1 \n"
    git grep $1 $(git rev-list --all)
}

function gauthor() {
    # Git Extras - brew install git-extras
    if [[ "$#" == 0 ]]; then
        git authors --list | sort -u;
        return
    fi
    # git files modified by a user
    git log --no-merges --author=$1 --name-only --pretty=format:"" | sort -u
}


function wip() {
    # Do WIP without description
    if [[ "$#" == 0 ]]; then
        git add -A; git commit --no-verify -m "🚧 WIP 🚧 $(date +%b/%d_%H:%M:%S)"
        return
    fi
    # Do WIP with custom description
    git add -A; git commit --no-verify -m "🚧 WIP 🚧 $1 $(date +%b/%d_%H:%M:%S)"
}


function review() {
    echo -e "${YELLOW} getting PR ${NC} $1 \n"
    gh pr checkout $1
    # https://newbedev.com/is-there-a-quick-way-to-git-diff-from-the-point-or-branch-origin
    git diff main...HEAD | lint-diffs > REVIEW.txt
    cat REVIEW.txt
}


function git_add_repo() {
    # Define your repository URL and target directory
    local repo_url="$1"
    local target_dir="$2"

    # TODO: support sha when it is provided.

    rm -rf $target_dir

    # Clone the repository with depth 1
    git clone --depth 1 "$repo_url" "$target_dir"

    # Navigate to the cloned repository
    pushd "$target_dir"

    # Get the SHA reference of the current commit
    local sha_ref=$(git log --pretty=format:"%h" -n 1)

    # Remove the .git directory
    rm -rf .git

    # Add all files in the repository
    git add .

    # Commit the content with the SHA reference in the message
    git commit -m "Content: git_add_repo $repo_url $target_dir @ $sha_ref"

    # return back to original directory
    popd

    echo "Repository cloned and content committed with SHA reference: $sha_ref"
}

# Example usage
# git_add_repo "https://github.com/example/repo.git" "my_repo"


# Support functions for glf
alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

function glf_old() {
    glNoGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
            --header "enter to view, ctrl-c to copy hash" \
            --bind "enter:execute:$_viewGitLogLine   | less -R" \
            --bind "ctrl-c:execute:$_gitLogLineToHash | pbcopy"
}

function glf() {
    git log --color=always --graph --format="%C(auto)%h%d %s %C(black)%C(bold)%cr%  %C(bold blue)<%an>%Creset" $@ |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
            --header "enter to view, ctrl-c to copy hash" \
            --bind "enter:execute:$_viewGitLogLine   | less -R" \
            --bind "ctrl-c:execute:$_gitLogLineToHash | pbcopy"
}

# NOT WORKING - need to try - https://softwaredoug.com/blog/2022/11/09/idiot-proof-git-aliases.html
function squash() {
    # https://stackoverflow.com/questions/25356810/git-how-to-squash-all-commits-on-branch
    if [[ "$#" == 0 ]]; then
        echo -e "${RED} Need commit message between quotes ${NC} \n"
        return
    fi
    # if no pending changes, one stash is droped
    #git stash save --include-untracked "save before squash"
    git reset --soft $(git merge-base $(gp) $(git branch --show-current))
    git commit -m $1
    #git stash pop
}

# git multi repo that support alias defined in rc files
function gm() {
    command_to_execute="$@"
    if [ -z "$command_to_execute" ]; then
        echo "Please provide a command to execute as an argument."
        exit 1
    fi

    echo "Executing ${YELLOW}$command_to_execute${NC} in all repos under ${MAGENTABRIGHT}$PWD${NC}"

    for repo in $(find . -name .git -type d  -exec dirname {} \;); do
        echo "${YELLOW} $repo ${NC}"
        bash -i -c "cd '$repo' && source ~/.bashrc && $command_to_execute"
        echo "${BLUE}===========${NC}"
    done
}

# same as above but git multi repo with -maxdepth 2
function gm1() {
    command_to_execute="$@"
    if [ -z "$command_to_execute" ]; then
        echo "Please provide a command to execute as an argument."
        exit 1
    fi

    echo "Executing ${YELLOW}$command_to_execute${NC} in repos one level under ${MAGENTABRIGHT}$PWD${NC}"

    for repo in $(find . -maxdepth 2 -name .git -type d  -exec dirname {} \;); do
        echo "${YELLOW} $repo ${NC}"
        bash -i -c "cd '$repo' && source ~/.bashrc && $command_to_execute"
        echo "${BLUE}===========${NC}"
    done
}

# same as above but git multi repo with -maxdepth 3
function gm2() {
    command_to_execute="$@"
    if [ -z "$command_to_execute" ]; then
        echo "Please provide a command to execute as an argument."
        exit 1
    fi

    echo "Executing ${YELLOW}$command_to_execute${NC} in repos two levels under ${MAGENTABRIGHT}$PWD${NC}"

    for repo in $(find . -maxdepth 3 -name .git -type d  -exec dirname {} \;); do
        echo "${YELLOW} $repo ${NC}"
        bash -i -c "cd '$repo' && source ~/.bashrc && $command_to_execute"
        echo "${BLUE}===========${NC}"
    done
}

function notes() {
    if [[ "$#" == 0 ]]; then
        vscodium ~/notes
        return
    fi
    echo -e "Executing git command in notes repo ${YELLOW} $@ ${NC}"
    git --git-dir=$HOME/notes/.git --work-tree=$HOME/notes $@
}


# https://github.com/junegunn/fzf/wiki/examples#cd
function cdf() {
    local dir
    dir=$(find ${1:-~} -path '*/\.*' -prune -maxdepth 4 \
                    -o -type d -print 2> /dev/null | fzf +m -i --exact) &&
    cd "$dir"
}

function cd() {
    if [[ "$#" != 0 ]]; then
        builtin cd "$@";
        return
    fi
    while true; do
        local lsd=$(echo ".." && \ls -p | grep '/$' | sed 's;/$;;')
        local dir="$(printf '%s\n' "${lsd[@]}" |
            fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                echo $__cd_path;
                echo;
                \ls -p --color=always "${__cd_path}";
        ')"
        [[ ${#dir} != 0 ]] || return 0
        builtin cd "$dir" &> /dev/null
    done
}

function h() {
    # Read from a shared command history with other computers
    # Requires sed (GNU sed) 4.9 installed and in the path
    # and HISTFILE="$HOME/Documents/zsh_history.$(hostname -s).txt" defined in .zshrc
    # awk is removing duplicates because sort -u | uniq are failing
    \cat ~/Documents/zsh_history.* | sed --binary 's/^[^;]*;//'  | awk '!a[$0]++' | fzf --tac -i --exact | tr -d '\n' | pbcopy
}

function h2() {
    # NO AWK VERSION - DO NOT REMOVE DUPLICATE
    # Read from a shared command history with other computers
    # Requires sed (GNU sed) 4.9 installed and in the path
    # and HISTFILE="$HOME/Documents/zsh_history.$(hostname -s).txt" defined in .zshrc
    \cat ~/Documents/zsh_history.* | sed --binary 's/^[^;]*;//' | fzf --tac -i --exact | tr -d '\n' | pbcopy
}

function pw() {
    local local_size=20
    if [ $# != 0 ]; then
        local_size=$1
    fi
    echo "Generating passwords with size $local_size"
    openssl rand -base64 $local_size
    # https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
    LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c $local_size ; echo
}

# https://justin.abrah.ms/dotfiles/zsh.html
function extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)        tar xjf $1        ;;
            *.tar.gz)         tar xzf $1        ;;
            *.bz2)            bunzip2 $1        ;;
            *.rar)            unrar x $1        ;;
            *.gz)             gunzip $1         ;;
            *.tar)            tar xf $1         ;;
            *.tar.xz)         tar xf $1         ;;
            *.tbz2)           tar xjf $1        ;;
            *.tgz)            tar xzf $1        ;;
            *.zip)            unzip $1          ;;
            *.Z)              uncompress $1     ;;
            *.7z)             7zr e $1          ;;
            *)                echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# https://github.com/jessfraz/dotfiles/blob/master/.aliases
# Linux specific aliases, work on both MacOS and Linux.
#function pbcopy() {
#	stdin=$(</dev/stdin);
#	pbcopy="$(which pbcopy)";
#	if [[ -n "$pbcopy" ]]; then
#		echo "$stdin" | "$pbcopy"
#	else
#		echo "$stdin" | xclip -selection clipboard
#	fi
#}
#
#function pbpaste() {
#	pbpaste="$(which pbpaste)";
#	if [[ -n "$pbpaste" ]]; then
#		"$pbpaste"
#	else
#		xclip -selection clipboard
#	fi
#}

# Git patch functions
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

# Log manipulation functions
function __end_note() {
    echo ""
    # echo "type __help to list all commands"
    echo ""
}

function __wipe_all_logs() {

    echo "Before: $(find /var/log -type f | wc -l) files ($(du /var/log -h -s | awk '{ print $1 }'))"

    journalctl --vacuum-time=1s
    dmesg -c

    #https://unix.stackexchange.com/questions/184488/command-to-clean-up-old-log-files
    find /var/log/ -type f -regex '.*\.[0-9]+\.gz$' -delete
    find /var/log -type f -name "*.log" | xargs -i{} truncate -s 0 {}

    echo "After: $(find /var/log -type f | wc -l) files ($(du /var/log -h -s | awk '{ print $1 }'))"

    __end_note
}

#function __track_etc() {
#
#    pushd /etc
#    etckeeper init
#    etckeeper commit "commit at $(date '+%Y-%m-%d %H:%M:%S')"
#    popd
#    __end_note
#}


function __any_errors() {

    grep -rins --include="*.log" "error\|warn\|critical\|fatal\|fail\|panic" /var/log
    dmesg | egrep -i "error\|warn\|critical\|fatal\|fail\|panic"
    __end_note
}


function __update() {

    curl https://raw.githubusercontent.com/abassel/dotfiles/master/boot.sh | bash

}


function __help() {

    echo "USE-AS-IS"
    echo ""
    echo "c -> clear"
    echo "cd -> fuzzy navigate directories"
    echo "cdf [<DIR>] -> fuzzy navigate ALL directories or "
    echo "d -> fuzzy find directory"
    echo "e -> exit"
    echo "extract -> expand tar, zip etc."
    echo "h -> fuzzy find history"
    echo "sync_history -> merge all history"
    echo "u -> update(brew or apt)"
    echo ""
    echo "-GIT/GITHUB FUNCTIONS-"
    echo "copy_patch -> copy pending changes to clipboard"
    echo "copy_patch_no_untracked -> copy pending changes to clipboard WITHOUT untracked files"
    echo "paste_patch -> apply patch"
    echo "gb -> switch to branch"
    echo "gb <BRANCH> -> create remote branch and checkout it"
    echo "gl -> show git log history"
    echo "glX -> variants to show log history"
    echo "glf -> fuzzy find git history"
    echo "pr -> create pull request"
    echo "s -> sync all branches"
    echo "m -> git checkout main"
    echo "review <PR_NUM> -> checkout given pr number"
    echo ""
    echo "-LINUX FUNCTIONS-"
    echo "debug             - run strace for command"
    echo "__update          - update rc scripts"
    echo "__any_errors      - grep for errors"
    echo "__wipe_all_logs   - wipe all your logs"
    # echo "__track_etc - git init the /etc"
    echo ""
}


# Openstack lxc functions for AIO
export LXC_LOGS="True"

function l-barbican() {
    lxc-attach -n $(lxc-ls -1 | grep barbican | sort | head -${1:-1} | tail -1)
}

function l-nova() {
    lxc-attach -n $(lxc-ls -1 | grep noval | sort | head -${1:-1} | tail -1)
}

function l-util() {
    lxc-attach -n $(lxc-ls -1 | grep util | sort | head -${1:-1} | tail -1)
}
