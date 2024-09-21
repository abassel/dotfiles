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
function pip_global() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

function ai_list_models(){
    # OLLAMA_HOST=192.168.111.30:11434 ollama list
    echo "** NOTE: Using ${YELLOW}OLLAMA_HOST=$OLLAMA_HOST${NC}"
    ollama list
}


function ai() {
    local model
    local question

    # If only one parameter is specified, assume the other one is default
    if [[ $# == 1 ]]; then
        model="llama3.1"
        question=$1
    else
        model=$1
        question=$2
    fi

    echo "${YELLOW}==============================${NC}"
    echo -e "Running model ${YELLOW}${model}${NC} for question:\n${MAGENTABRIGHT}$question${NC}"
    echo "** NOTE: Using ${YELLOW}OLLAMA_HOST=$OLLAMA_HOST${NC}"
    echo ""
    OLLAMA_HOST=192.168.111.30:11434 ollama run $model $question
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

    ai_list_models | awk 'NR>1 {print $1}' | sort -t ':' -k 2 -n | xargs -I% zsh -c "source ~/.config/zsh/.zshrc && ai % '$question'"

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

    ai_list_models | awk 'NR>1 {print $1}' | grep "code" | sort -t ':' -k 2 -n | xargs -I% zsh -c "source ~/.config/zsh/.zshrc && ai % '$question'"

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

    ai_list_models | awk 'NR>1 {print $1}' | grep -v "code" | sort -t ':' -k 2 -n | xargs -I% zsh -c "source ~/.config/zsh/.zshrc && ai % '$question'"

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

# TODO: Merge with function below to autodetect master or main
function git_merge_external_repo_in_subdir_from_master(){
    echo "${YELLOW}Based on: https://josh.fail/2022/merging-git-repos-with-git-filter-repo/${NC}"
    echo "${BLUE}===========${NC}"
    local repo_path="$1"
    local target_dir="$2"

    # Clone the repository with depth 1
    git clone --depth 1 "$repo_path" "__$target_dir"

    pushd "__$target_dir"

    git filter-repo --force --to-subdirectory "$target_dir"/

    popd

    git remote add "__$target_dir" "__$target_dir"

    git fetch "__$target_dir"

    # Support multiple branches
    git merge "__$target_dir"/master --allow-unrelated-histories --no-ff -m "Add $target_dir"

    git remote rm "__$target_dir"

    rm -rf "__$target_dir"

    gl | head -n 10

    echo "${MAGENTABRIGHT}Do not call git pull - it will rebase the new content${NC}"
    echo "${MAGENTABRIGHT}Instead call git push to keep the structure${NC}"
}


# TODO: Merge with function above to autodetect master or main
function git_merge_external_repo_in_subdir_from_main(){
    echo "${YELLOW}Based on: https://josh.fail/2022/merging-git-repos-with-git-filter-repo/${NC}"
    echo "${BLUE}===========${NC}"
    local repo_path="$1"
    local target_dir="$2"

    # Clone the repository with depth 1
    git clone --depth 1 "$repo_path" "__$target_dir"

    pushd "__$target_dir"

    git filter-repo --force --to-subdirectory "$target_dir"/

    popd

    git remote add "__$target_dir" "__$target_dir"

    git fetch "__$target_dir"

    # Support multiple branches
    git merge "__$target_dir"/main --allow-unrelated-histories --no-ff -m "Add $target_dir"

    git remote rm "__$target_dir"

    rm -rf "__$target_dir"

    gl | head -n 10

    echo "${MAGENTABRIGHT}Do not call git pull - it will rebase the new content${NC}"
    echo "${MAGENTABRIGHT}Instead call git push to keep the structure${NC}"
}


function git_show_deleted_files(){
    echo "* ${YELLOW}Show deleted files in two formats${NC}"
    echo "* ${YELLOW}Reference:${NC}"
    echo "*- https://waylonwalker.com/git-find-deleted-files/"
    echo "*- https://stackoverflow.com/questions/6017987/how-can-i-list-all-the-deleted-files-in-a-git-repository"
    echo "*${BLUE}===========${NC}"

    git log --all --diff-filter D --name-only

    git log --all --diff-filter D --pretty="format:" --name-only | sed '/^$/d' | sort -u
}


function git_show_largest_10_files(){
    echo "* ${YELLOW}Show top 10 file in repo${NC}"
    echo "* ${YELLOW}Reference:${NC}"
    echo "*- https://stackoverflow.com/questions/9456550/how-can-i-find-the-n-largest-files-in-a-git-repository"
    echo "*${MAGENTABRIGHT}NOTE: Might need ${YELLOW}brew install coreutils${MAGENTABRIGHT} to install numfmt in macOS${NC}"
    echo "*${BLUE}===========${NC}"

    git rev-list --objects --all \
    | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
    | sed -n 's/^blob //p' \
    | sort --numeric-sort --key=2 \
    | tail -n 10 \
    | cut -c 1-12,41- \
    | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}


function git_move_folder_to_root(){
    if [[ "$#" == 0 ]]; then
        echo "${YELLOW}Move subfolder to root in repo${NC}"
        echo "${YELLOW}Reference:${NC}"
        echo "- https://www.google.com/search?q=git+filter+branch+move+subdirectory+to+root"
        echo "- https://stackoverflow.com/questions/3142419/how-can-i-move-a-directory-in-a-git-repo-for-all-commits"
        echo "${BLUE}$(whence -v git_move_folder_to_root)${NC}"
        echo "${BLUE}=====Implementation details======${NC}"
        whence -f git_move_folder_to_root | bat --language=bash
        echo "${MAGENTABRIGHT} >>> ERROR: Folder name is required parameter${NC}";
        echo "${MAGENTABRIGHT} >>> ERROR: You would not see all this output if you had given a parameter${NC}"
        return
    fi

    git filter-repo --subdirectory-filter $1 -- --all
}


function git_remove_file_from_history(){
    if [[ "$#" == 0 ]]; then
        echo "${YELLOW}Remove/Wipe/Purge file from repo history${NC}"
        echo "${YELLOW}Reference:${NC}"
        echo "- https://www.google.com/search?q=git-filter-repo+remove+file+from+history"
        echo "- https://marcofranssen.nl/remove-files-from-git-history-using-git-filter-repo"
        echo "- https://blog.gitguardian.com/rewriting-git-history-cheatsheet/"
        echo "${MAGENTABRIGHT} >>> NOTE: DO NOT RUN IF YOU HAVE STASHES${NC}"
        echo "${MAGENTABRIGHT} >>> NOTE: Need to install `git-filter-repo`${NC}"
        echo "${BLUE}$(whence -v git_remove_file_from_history)${NC}"
        echo "${BLUE}=====Implementation details======${NC}"
        whence -f git_remove_file_from_history | bat --language=bash
        echo "${MAGENTABRIGHT} >>> ERROR: Folder/File name is required parameter${NC}";
        echo "${MAGENTABRIGHT} >>> ERROR: You would not see all this output if you had given a parameter${NC}"
        return
    fi

    if [ $(git stash list | wc -l) -gt 0 ]; then
        echo "${MAGENTABRIGHT} >>> ERROR: CANNOT RUN IF YOU HAVE STASHES${NC}";
        return
    fi

    echo "${BLUE}==You might need this to roll back==${NC}"
    gl | head -n 10

    echo "${BLUE}==You might need this to add a remote==${NC}"
    git remote -v

    echo "${BLUE}=============================${NC}"
    git filter-repo --force --invert-paths --path $1

    echo "${BLUE}==You might need this to compare with previous tree==${NC}"
    gl | head -n 10

    echo "${BLUE}==You might need to add remote again==${NC}"
}


function git_checkout_all_branches(){

    echo "${YELLOW}Checkout all branches to help mirroring a git repo${NC}"
    echo "${YELLOW}Reference:${NC}"
    echo "- https://stackoverflow.com/questions/37884832/git-push-all-branches-from-one-remote-to-another-remote"


    echo "${BLUE}=============================${NC}"
    for remote in `git branch -r | grep -v master `; do git checkout --track $remote ; done

    echo "${BLUE}==Here is the branch list==${NC}"
    git branch -a
    git branch -a | wc -l
}


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
        # see code alias in alias_exports.sh
        code ~/notes
        return
    fi

    # Escape the double quotes in the command arguments
    local command_to_execute=$(printf "%q " "$@" | sed 's/"/\\"/g')
    echo -e "Executing command ${YELLOW}$command_to_execute${NC} in ${MAGENTABRIGHT}$HOME/notes${NC}"
    #git --git-dir=$HOME/notes/.git --work-tree=$HOME/notes $@
    bash -i -c "cd '$HOME/notes' && source ~/.bashrc && $command_to_execute"
}
alias n=notes


function etc() {
    # https://unix.stackexchange.com/questions/91384/how-is-sudo-set-to-not-change-home-in-ubuntu-and-how-to-disable-this-behavior
    # Requires config changes to sudo in order preserver $HOME
    # sudo visudo
    #   -# Defaults env_keep += "HOME"
    #   +Defaults env_keep += "HOME"
    #
    if [[ "$#" == 0 ]]; then
        cd /etc
        return
    fi

    # Escape the double quotes in the command arguments
    local command_to_execute=$(printf "%q " "$@" | sed 's/"/\\"/g')
    echo -e "Executing command ${YELLOW}$command_to_execute${NC} in ${MAGENTABRIGHT}/etc${NC}"
    #git --git-dir=/etc/.git --work-tree=/etc $@
    sudo bash -i -c "cd /etc && source $HOME/.bashrc && $command_to_execute"
}


function config() {
    if [[ "$#" == 0 ]]; then
        # see code alias in alias_exports.sh
        code ~/
        return
    fi

    # Escape the double quotes in the command arguments
    local command_to_execute=$(printf "%q " "$@" | sed 's/"/\\"/g')
    echo -e "Executing command ${YELLOW}$command_to_execute${NC} in ${MAGENTABRIGHT}$HOME/.git_dotfiles${NC}"
    #git --git-dir=$HOME/notes/.git --work-tree=$HOME/notes $@
    bash -i -c "cd ~ && source ~/.bashrc && export GIT_DIR=~/.git_dotfiles; $command_to_execute"
}


config_cmd() {
    if [ $# -eq 0 ]; then
        echo "Error: config_cmd requires at least one argument." >&2
        return 1
    fi

    config $@
    echo "${YELLOW}======================${NC}"
    config_private $@
    echo "${YELLOW}======================${NC}"
    notes $@
    # etc $@
}

function config_sync(){
    config_cmd s
}


function config_status(){
    config_cmd gs
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
function git_copy_patch() {
    files2patch=($(git ls-files --others --exclude-standard))

    # put all untracked files in the patch
    for file in $files2patch; do git add --intent-to-add $file; done

    git diff HEAD | pbcopy
    echo "==== Generating patch in clipboard for the files below ===="
    git diff HEAD --name-only | cat

    # restore untracked files as untracked
    for file in $files2patch; do git reset HEAD $file; done
}

function git_copy_patch_no_untracked() {

    git diff HEAD | pbcopy
    echo "==== Generating patch in clipboard for the files below ===="
    git diff HEAD --name-only | cat

}

function git_paste_patch() {
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
