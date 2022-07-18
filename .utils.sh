# Some nice greps
export GREP_CONTEXT_SIZE=3

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

# Perl one-liner to get rid of trailing whitespace
dewhite() {
    perl -i -pe 's|^(.*?)([\t ]*)$|$1|' $*
}

# Alphabetize the import lists of the given files
alphabetize(){
    python3 ~/.alphabetize.py $*
}

# Make ranger cd you to the last directory you were in
alias ranger='ranger --choosedir="$HOME/.lastdir"; cd $(cat ~/.lastdir)'
