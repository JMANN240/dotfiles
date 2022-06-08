# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <https://creativecommons.org/publicdomain/zero/1.0/>. 

# /etc/bash.bashrc: executed by bash(1) for interactive shells.

# System-wide bashrc file

# Check that we haven't already been sourced.
([[ -z ${CYG_SYS_BASHRC} ]] && CYG_SYS_BASHRC="1") || return

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# If started from sshd, make sure profile is sourced
if [[ -n "$SSH_CONNECTION" ]] && [[ "$PATH" != *:/usr/bin* ]]; then
    source /etc/profile
fi

# Warnings
unset _warning_found
for _warning_prefix in '' ${MINGW_PREFIX}; do
    for _warning_file in ${_warning_prefix}/etc/profile.d/*.warning{.once,}; do
        test -f "${_warning_file}" || continue
        _warning="$(command sed 's/^/\t\t/' "${_warning_file}" 2>/dev/null)"
        if test -n "${_warning}"; then
            if test -z "${_warning_found}"; then
                _warning_found='true'
                echo
            fi
            if test -t 1
                then printf "\t\e[1;33mwarning:\e[0m\n${_warning}\n\n"
                else printf "\twarning:\n${_warning}\n\n"
            fi
        fi
        [[ "${_warning_file}" = *.once ]] && rm -f "${_warning_file}"
    done
done
unset _warning_found
unset _warning_prefix
unset _warning_file
unset _warning

# Fixup git-bash in non login env
shopt -q login_shell || . /etc/profile.d/git-prompt.sh

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Determine active Python virtualenv details.

if test -z "$VIRTUAL_ENV" ; then
    PYTHON_VIRTUALENV=""
else
    PYTHON_VIRTUALENV="[`basename \"$VIRTUAL_ENV\"`] "
fi

# Set a custom propmt
PROMPT_COMMAND=prompt_cmd

prompt_cmd() {
    local EXIT="$?"

    PS1=""

    if [ $EXIT -eq 0 ]; then 
        PS1+="\[$(tput setaf 2)\]✓ "; 
    else 
        PS1+="\[$(tput setaf 1)\]✗ "; 
    fi

    BRANCH=$(parse_git_branch)

    PS1+="\[$(tput setaf 2)\]\u@\h\[$(tput sgr0)\] "
    PS1+="[\[$(tput setaf 6)\]\w\[$(tput sgr0)\]] "
    if [[ $BRANCH != "" ]]; then 
        PS1+="("
        if [[ $BRANCH = "master" ]]; then 
            PS1+="\[$(tput bold)\]"; 
            PS1+="\[$(tput setaf 1)\]"; 
        else 
            PS1+="\[$(tput setaf 3)\]"; 
        fi
        PS1+="$BRANCH\[$(tput sgr0)\]) "
    fi
    PS1+="\[$(tput setaf 3)\]\$\[$(tput sgr0)\] "
}

act () {
    if [ "$#" -eq 0 ]
    then
        source env/Scripts/activate
    elif [ "$#" -eq 1 ]
    then
        source $1/Scripts/activate
    fi
}

add-key () {
    eval `ssh-agent`
    ssh-add ~/.ssh/$1
}

ytdl () {
    youtube-dl -f "best,[height<=1080]" -o "D:\ytdl\%(title)s.%(ext)s" https://www.youtube.com/playlist?list=PLMejUA9a8sUPT80FaT8GPP9_agfF2ELzi
}

ytdlm () {
    youtube-dl -x --audio-format mp3 -o "C:\Users\JT\Music\%(title)s.%(ext)s" https://www.youtube.com/playlist?list=PLMejUA9a8sUOyjcGkA4tEK-ZAg-hCZaNX
}

# Aliases for editing bashrc
alias rebash="source ~/.bashrc"
alias bashrc="code ~/.bashrc"

rcode () {
    cargo new ~/Code/$1 & code ~/Code/$1
}

4to3 () {
    FILENAME=$(basename "$1" | sed 's/\(.*\)\..*/\1/')
    echo "$FILENAME.mp3"
    ffmpeg -i "$1" "$FILENAME.mp3" && rm "$1"
}

# Some nice greps
export GREP_CONTEXT_SIZE=3

sgrep() {
    grep -n --color -C $GREP_CONTEXT_SIZE "$*"
}

rgrep() {
    grep -Rn --color -C $GREP_CONTEXT_SIZE "$*"
}

hist() {
    history | sgrep $*
}

wt() {
    WORKTREE_PATHS=($(git worktree list --porcelain | sed -n 's/worktree \(.*\)/\1/gp' | xargs));
    echo ${WORKTREE_PATHS[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "Switch to worktree: ";
    read WORKTREE_NUMBER;
    WORKTREE_PATH=${WORKTREE_PATHS[WORKTREE_NUMBER-1]};
    cd $WORKTREE_PATH;
}

ga() {
    GIT_ROOT=$(git rev-parse --show-toplevel);
    FILES=($(git status -s --porcelain | sed -n 's/ . \(.*\)/\1/gp' | xargs));
    echo ${FILES[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "Add files: ";
    read -a ADD_FILE_INDICES;
    ADD_FILES=();
    for FILE_INDEX in ${ADD_FILE_INDICES[@]}; do
        ADD_FILES+=($GIT_ROOT/${FILES[FILE_INDEX-1]})
    done
    git add ${ADD_FILES[@]}
}

ffind() {
    BRANCH=$(parse_git_branch)

    if [[ $BRANCH != "" ]]; then 
        SEARCH_ROOT=$(git rev-parse --show-toplevel)
    else
        SEARCH_ROOT="."
    fi

    find $SEARCH_ROOT -type f -iname "*$1*"
}

fopen() {
    FOUND_FILES=($(ffind $1 | xargs));
    echo ${FOUND_FILES[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "Open files: ";
    read -a OPEN_FILE_INDICES;
    OPEN_FILES=();
    for FILE_INDEX in ${OPEN_FILE_INDICES[@]}; do
        OPEN_FILES+=(${FOUND_FILES[FILE_INDEX-1]})
    done
    code ${OPEN_FILES[@]}
}

export HISTCONTROL=ignoreboth
