# Some nice greps
export GREP_CONTEXT_SIZE=3

# Basic mkcd
mkcd() {
	mkdir -p "$1" && cd "$1";
}

# Super GREP
sgrep() {
    grep -nI --color -C $GREP_CONTEXT_SIZE -- "$*"
}

# Recursive GREP
rgrep() {
    grep -RnI --color -C $GREP_CONTEXT_SIZE -- "$*"
}

# Search history with Super GREP
hist() {
    history | sgrep $*
}

# File extensions to ignore with ffind
export FFIND_IGNORED_EXTENSIONS=( class )

# Fuzzy Find, search files by fuzzy name
ffind() {
    BRANCH=$(gbranch)

    if [[ $BRANCH != "" ]]; then 
        SEARCH_ROOT=$(git rev-parse --show-toplevel)
    else
        SEARCH_ROOT="."
    fi

    IGNORE_LIST=$(echo ${FFIND_IGNORED_EXTENSIONS[@]} | sed 's/ /\\\|/')

    find $SEARCH_ROOT -type f -iname "*$1*" | sed "/\.\($IGNORE_LIST\)/d"
}

# Fuzzy Open, ffind and open with prompt
fopen() {
    # An array of all of the files which match the argument given
    FOUND_FILES=($(ffind $1 | xargs));

    # If there aren't any, exit with -1
    if [ ${#FOUND_FILES[@]} -eq 0 ]; then
        return -1;
    fi
    
    # If there is only one, exit with 0
    if [ ${#FOUND_FILES[@]} -eq 1 ]; then
        code ${FOUND_FILES[0]}
        return 0;
    fi

    # Otherwise, prompt the use about which ones they want to open
    echo ${FOUND_FILES[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "Open files: ";
    read -a OPEN_FILE_INDICES;
    OPEN_FILES=();
    for FILE_INDEX in ${OPEN_FILE_INDICES[@]}; do
        OPEN_FILES+=(${FOUND_FILES[FILE_INDEX-1]})
    done
    code ${OPEN_FILES[@]}
}

# An implementation of fopen that uses fzf and opens in vim
vopen() {
    FILES=$(fzf -m --exact --query="$1" --select-1)
    if [[ $FILES != "" ]]; then
        vim -p $FILES
    fi
}

# Perl one-liner to get rid of trailing whitespace
dewhite() {
    perl -i -pe 's|^(.*?)([\t ]*)$|$1|' $*
}

# Alphabetize the import lists of the given files
alphabetize(){
    python3 /home/jt/.alphabetize.py $*
}

# Make ranger cd you to the last directory you were in
alias ranger='ranger --choosedir="$HOME/.lastdir"; cd $(cat ~/.lastdir)'

# Prompt for the indices from an array
promptify() {
    ARGV=($@);
    ARGC=${#ARGV[@]}
    ARRAY=${ARGV[@]:0:ARGC-1}
    PROMPT_TEXT=${ARGV[ARGC-1]}
    echo ${ARRAY[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "$PROMPT_TEXT ";
    read -a PROMPT_INDICES;
}

# Super Fuzzy Find
sffind() {
    BRANCH=$(gbranch)

    if [[ $BRANCH != "" ]]; then 
        SEARCH_ROOT=$(git rev-parse --show-toplevel)
    else
        SEARCH_ROOT="."
    fi

    grep -RnI --color -C 0 -- "$*" $SEARCH_ROOT
}

# If clientserver is enabled, use it
vim () {
    VIM_PATH=$(which vim 2>/dev/null)

    if [ -z $VIM_PATH ]; then
        echo "$SHELL: vim: command not found"
        return 127;
    fi
    
    $VIM_PATH --serverlist | grep -q VIM

    if [ $? -eq 0 ]; then
        if [ $# -eq 0 ]; then
            $VIM_PATH
        else
            $VIM_PATH --servername vim --remote-tab "$@"
            tmux select-pane -t $(cat ~/.vim_pane_id)
        fi
    else
        $VIM_PATH --servername vim "$@"
    fi
}

# Vim file explorer
vfe () {
    if [ -z "$(gbranch)" ]; then
        SEARCH_ROOT="$(pwd)"
    else
        SEARCH_ROOT="$(groot)"
    fi

    FILES=$(find $SEARCH_ROOT | sed -nE "s|$SEARCH_ROOT(.*)|\1|p")

    while true
    do
        OUTPUT=$(echo "$FILES" | sed 's/ /\n/' | fzf --exact --multi)
        if [ -z "$OUTPUT" ];  then
            break;
        else
            /usr/bin/vim $(echo $OUTPUT | sed -E "s|[^ ]+|$SEARCH_ROOT&|g")
        fi
    done
}
