# Determine the path of the git repo
groot() {
    git rev-parse --show-toplevel
}

# Determine the current relative path inside the git repo
gpath() {
	pwd | perl -pe "s|$(groot)||"
}

# Determine the active git branch
gbranch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Print files that have changed on this branch since we branched from master
gdiff() {
    GIT_ROOT=$(groot);
    git diff --name-only master...$(gbranch) | sed -e "s|^|$GIT_ROOT/|"
}

# Add modified files with a prompt
ga() {
    GIT_ROOT=$(groot)
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

# Change worktrees with a prompt
wt() {
    WORKTREE_PATHS=($(git worktree list --porcelain | sed -n 's/worktree \(.*\)/\1/gp' | xargs));
    echo ${WORKTREE_PATHS[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "Switch to worktree: ";
    read WORKTREE_NUMBER;
    WORKTREE_PATH=${WORKTREE_PATHS[WORKTREE_NUMBER-1]};
    WORKING_PATH=$(gpath)
    cd "$WORKTREE_PATH$WORKING_PATH";
}

# Remove dead worktrees and branches
wtr() {
    WORKTREE_BRANCHES=($(git worktree list --porcelain | sed -E -n 's/branch refs\/heads\/(.*)/\1/p' | xargs))
    WORKTREE_PATHS=($(git worktree list --porcelain | sed -E -n 's/worktree (.*)/\1/p' | xargs))
    DEAD_BRANCHES=($(git branch -vv | sed -n -E 's/^.*\[origin\/(.*): gone\].*$/\1/p' | xargs));
    for DEAD_BRANCH in ${DEAD_BRANCHES[@]}; do
        for INDEX in ${!WORKTREE_BRANCHES[@]}; do
            if [ "${DEAD_BRANCH}" = "${WORKTREE_BRANCHES[$INDEX]}" ]; then
                git worktree remove -f ${WORKTREE_PATHS[$INDEX]};
                git branch -D $DEAD_BRANCH;
                break;
            fi
        done
    done
}

# Remove dead branches
gbr() {
    DEAD_BRANCHES=($(git branch -vv | sed -n -E 's/^.*\[origin\/(.*): gone\].*$/\1/p' | xargs));
    for DEAD_BRANCH in ${DEAD_BRANCHES[@]}; do
        git branch -D $DEAD_BRANCH;
    done
}

# Remove branches with a prompt (I should probably make this work with worktrees too)
gbrm() {
    BRANCHES=($(git branch | sed -n -E 's/^..([[:alnum:]_-]*)/\1/gp' | xargs));
    echo ${BRANCHES[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
    echo -n "Remove branches: ";
    read -a REMOVE_BRANCH_INDICES;
    for BRANCH_INDEX in ${REMOVE_BRANCH_INDICES[@]}; do
        git branch -D ${BRANCHES[BRANCH_INDEX-1]}
    done
}

# Pretty printing of branch info
gb() {
    UNTRACKED_BRANCHES=($(git branch -vv | sed -n -E 's/^..([[:graph:]]*) +[[:xdigit:]]{9} [^\[].*$/\1/p' | xargs));
    ALIVE_BRANCHES=($(git branch -vv | sed -n -E 's/^.*\[origin\/(.*)\].*$/\1/p' | xargs));
    BEHIND_BRANCHES=($(git branch -vv | sed -n -E 's/^.*\[origin\/(.*): behind.*\].*$/\1/p' | xargs));
    DEAD_BRANCHES=($(git branch -vv | sed -n -E 's/^.*\[origin\/(.*): gone\].*$/\1/p' | xargs));

    if [ ${#UNTRACKED_BRANCHES[@]} -gt 0 ]; then
        tput setaf 7
        for BRANCH in ${UNTRACKED_BRANCHES[@]}; do
            echo "  $BRANCH"
        done
    fi

    if [ ${#ALIVE_BRANCHES[@]} -gt 0 ]; then
        tput setaf 2
        for BRANCH in ${ALIVE_BRANCHES[@]}; do
            echo "  $BRANCH"
        done
    fi

    if [ ${#BEHIND_BRANCHES[@]} -gt 0 ]; then
        tput setaf 3
        for BRANCH in ${BEHIND_BRANCHES[@]}; do
            echo "  $BRANCH"
        done
    fi

    if [ ${#DEAD_BRANCHES[@]} -gt 0 ]; then
        tput setaf 1
        for BRANCH in ${DEAD_BRANCHES[@]}; do
            echo "  $BRANCH"
        done
    fi
}

# Remove white lines and trailing whitespace from the files than have changed since master
gdw() {
    DIFF_FILES=$(gdiff | xargs)
    dewhite $DIFF_FILES
}

# Alphabetize the import lists of the files than have changed since master
gaz() {
    DIFF_FILES=$(gdiff | xargs)
    alphabetize $DIFF_FILES
}

# Selectively alphabetize the import lists of the files than have changed since master
gazm() {
    DIFF_FILES=($(gdiff | xargs));
    promptify ${DIFF_FILES[@]} "Alphabetize: ";
    for DIFF_FILE_INDEX in ${PROMPT_INDICES[@]}; do
        alphabetize ${DIFF_FILES[DIFF_FILE_INDEX-1]}
    done
}

# Fetch all behind branches
gpb() {
    BEHIND_BRANCHES=($(git branch -vv | sed -n -E 's/^.*\[origin\/(.*): behind.*\].*$/\1/p' | xargs));
    for BEHIND_BRANCH in ${BEHIND_BRANCHES[@]}; do
        git fetch origin $BEHIND_BRANCH:$BEHIND_BRANCH --quiet;
        echo "Fetched $BEHIND_BRANCH";
    done;
}

# Search My Lines: grep for a pattern in files that you have changed in this branch
sml() {
    export GIT_USERNAME=$(git config user.name);
    DIFF_FILES=($(gdiff | xargs));
    GIT_ROOT=$(groot)
    OLD_GREP_CONTEXT_SIZE=$GREP_CONTEXT_SIZE;
    GREP_CONTEXT_SIZE=0;
    for DIFF_FILE in ${DIFF_FILES[@]}; do
        git blame --line-porcelain $DIFF_FILE | perl -0777 -pe 's/[[:xdigit:]]{40} [[:digit:]]+ ([[:digit:]]+)(?: [[:digit:]]+)?\nauthor (.*)\n(?:.*\n){8,9}filename (.*)\n(?:\t| {8})(.*)/$2:$3:$1: $4/g' | sed -n "s|$GIT_USERNAME:| $GIT_ROOT/|p" | sgrep "$*"
    done;
    GREP_CONTEXT_SIZE=$OLD_GREP_CONTEXT_SIZE;
}
