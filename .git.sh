# Determine the path of the git repo
groot() {
    if [ ! -z "$(gbranch)" ]; then
        git rev-parse --show-toplevel;
    else
        return 1;
    fi
}

# Determine the current relative path inside the git repo
gpath() {
    if [ ! -z "$(gbranch)" ]; then
	    pwd | perl -pe "s|$(groot)||"
    else
        return 1;
    fi
}

# Determine the active git branch
gbranch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Print files that have changed on this branch since we branched from master
gdiff() {
    if [ ! -z "$(gbranch)" ]; then
        GIT_ROOT=$(groot);
        git diff --name-only master...$(gbranch) | sed -e "s|^|$GIT_ROOT/|";
    else
        return 1;
    fi
}

# Add modified files with a prompt
ga() {
    if [ ! -z "$(gbranch)" ]; then
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
    else
        return 1;
    fi
}

# Really fancy git add! Requires git (of course), fzf, and perl.
gadd() {
        if [ ! -z "$(git branch 2> /dev/null | perl -ne 'print $1 if /^\* (.+)$/')" ]; then
                if [ ! -z "$(git status -s --porcelain)" ]; then
                        GIT_ROOT=$(git rev-parse --show-toplevel)
                        FILES=($(
                                git status -s --porcelain |
                                perl -ne "print if s|( M\|\?\?) (.+)|$GIT_ROOT/\$2|" |
                                fzf -0 -m --reverse --ansi --bind pgdn:preview-page-down,pgup:preview-page-up --preview='git diff --color -- {}'
                        ));
                        git add ${FILES[@]};
                        read -p "Commit Message: ";
                        git commit -m "$REPLY";
                else
                        printf 'There is nothing to add.\n'
                fi
        else
                return 1;
        fi
}

# Change worktrees with a prompt
wt() {
    if [ ! -z "$(gbranch)" ]; then
        WORKTREE_PATHS=($(git worktree list --porcelain | sed -n 's/worktree \(.*\)/\1/gp' | xargs));
        echo ${WORKTREE_PATHS[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
        echo -n "Switch to worktree: ";
        read WORKTREE_NUMBER;
        WORKTREE_PATH=${WORKTREE_PATHS[WORKTREE_NUMBER-1]};
        WORKING_PATH_COMPONENTS=($(gpath | sed -E -n 's/\/([^/]+)/\1 /gp' | xargs));
        cd $WORKTREE_PATH
        for COMPONENT in ${WORKING_PATH_COMPONENTS[@]}; do
            cd $COMPONENT 2> /dev/null
        done
    else
        return 1;
    fi
}

wtc() {
	WORKTREE_PATH="$(groot)/../$1"
	git worktree add -b $1 $WORKTREE_PATH && cd $WORKTREE_PATH
}

# Remove dead worktrees and branches
wtr() {
    if [ ! -z "$(gbranch)" ]; then
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
    else
        return 1;
    fi
}

# Remove dead branches
gbr() {
    if [ ! -z "$(gbranch)" ]; then
        DEAD_BRANCHES=($(git branch -vv | perl -ne 'print if s/^..(\S+) +[0-9a-f]{9} (?:\(.+\) )?\[.+: gone\].+$/$1/' | xargs));
        for DEAD_BRANCH in ${DEAD_BRANCHES[@]}; do
            git branch -D $DEAD_BRANCH;
        done
    else
        return 1;
    fi
}

# Remove branches with a prompt (I should probably make this work with worktrees too)
gbrm() {
    if [ ! -z "$(gbranch)" ]; then
        BRANCHES=($(git branch | sed -n -E 's/^..([[:alnum:]_-]*)/\1/gp' | xargs));
        echo ${BRANCHES[@]} | sed 's/ /\n/g' | sed '=' | sed 'N; s/\n/ /' | sed 's/^\(.*\) /(\1) /g';
        echo -n "Remove branches: ";
        read -a REMOVE_BRANCH_INDICES;
        for BRANCH_INDEX in ${REMOVE_BRANCH_INDICES[@]}; do
            git branch -D ${BRANCHES[BRANCH_INDEX-1]}
        done
    else
        return 1;
    fi
}

# Pretty printing of branch info
gb() {
    if [ ! -z "$(gbranch)" ]; then
        UNTRACKED_COLOR=7
        ALIVE_COLOR=2
        BEHIND_COLOR=3
        DEAD_COLOR=1

        UNTRACKED_BRANCHES=($(git branch -vv | perl -ne 'print if s/^..(\S+) +[0-9a-f]{9} (?!\(.+\))(?!\[.+\]).+$/$1/' | xargs));
        ALIVE_BRANCHES=($(git branch -vv | perl -ne 'print if not (/^..\S+ +[0-9a-f]{9} (?:\(.+\) )?\[.+: behind\].+$/ or /^..(\S+) +[0-9a-f]{9} (?:\(.+\) )?\[.+: gone\].+$/)' | perl -ne 'print if s/^..(\S+) +[0-9a-f]{9} (?:\(.+\) )?\[.+\].+$/$1/' | xargs));
        BEHIND_BRANCHES=($(git branch -vv | perl -ne 'print if s/^..(\S+) +[0-9a-f]{9} (?:\(.+\) )?\[.+: behind\].+$/$1/' | xargs));
        DEAD_BRANCHES=($(git branch -vv | perl -ne 'print if s/^..(\S+) +[0-9a-f]{9} (?:\(.+\) )?\[.+: gone\].+$/$1/' | xargs));

        if [ ${#UNTRACKED_BRANCHES[@]} -gt 0 ]; then
            printf "\n"
            tput setaf $UNTRACKED_COLOR
            tput bold
            printf "  UNTRACKED\n"
            tput sgr0
            tput setaf $UNTRACKED_COLOR
            for BRANCH in ${UNTRACKED_BRANCHES[@]}; do
                printf "    $BRANCH\n"
            done
        fi

        if [ ${#ALIVE_BRANCHES[@]} -gt 0 ]; then
            printf "\n"
            tput setaf $ALIVE_COLOR
            tput bold
            printf "  ALIVE\n"
            tput sgr0
            tput setaf $ALIVE_COLOR
            for BRANCH in ${ALIVE_BRANCHES[@]}; do
                printf "    $BRANCH\n"
            done
        fi

        if [ ${#BEHIND_BRANCHES[@]} -gt 0 ]; then
            printf "\n"
            tput setaf $BEHIND_COLOR
            tput bold
            printf "  BEHIND\n"
            tput sgr0
            tput setaf $BEHIND_COLOR
            for BRANCH in ${BEHIND_BRANCHES[@]}; do
                printf "    $BRANCH\n"
            done
        fi

        if [ ${#DEAD_BRANCHES[@]} -gt 0 ]; then
            printf "\n"
            tput setaf $DEAD_COLOR
            tput bold
            printf "  DEAD\n"
            tput sgr0
            tput setaf $DEAD_COLOR
            for BRANCH in ${DEAD_BRANCHES[@]}; do
                printf "    $BRANCH\n"
            done
        fi

        printf "\n"
    else
        return 1;
    fi
}

# Remove white lines and trailing whitespace from the files than have changed since master
gdw() {
    if [ ! -z "$(gbranch)" ]; then
        DIFF_FILES=$(gdiff | xargs)
        dewhite $DIFF_FILES
    fi
}

# Alphabetize the import lists of the files than have changed since master
gaz() {
    if [ ! -z "$(gbranch)" ]; then
        DIFF_FILES=$(gdiff | xargs)
        alphabetize $DIFF_FILES
    else
        return 1;
    fi
}

# Selectively alphabetize the import lists of the files than have changed since master
gazm() {
    if [ ! -z "$(gbranch)" ]; then
        DIFF_FILES=($(gdiff | xargs));
        promptify ${DIFF_FILES[@]} "Alphabetize: ";
        for DIFF_FILE_INDEX in ${PROMPT_INDICES[@]}; do
            alphabetize ${DIFF_FILES[DIFF_FILE_INDEX-1]}
        done
    else
        return 1;
    fi
}

# Fetch all behind branches
gpb() {
    if [ ! -z "$(gbranch)" ]; then
        BEHIND_BRANCHES=($(git branch -vv | perl -ne 'print if s/^..(\S+) +[0-9a-f]{9} (?:\(.+\) )?\[.+: behind\].+$/$1/' | xargs));
        for BEHIND_BRANCH in ${BEHIND_BRANCHES[@]}; do
            git fetch origin $BEHIND_BRANCH:$BEHIND_BRANCH --quiet;
            echo "Fetched $BEHIND_BRANCH";
        done;
    else
        return 1;
    fi
}

# Print My Lines: print the lines that you have changed in this branch
pml() {
	if [ ! -z "$(gbranch)" ]; then
        export GIT_USERNAME=$(git config user.name);
        GIT_ROOT=$(groot);
        DIFF_FILES=($(git diff --name-status master.. | perl -ne "print if s|^M\s(.+)|$GIT_ROOT/\$1|" | xargs));
        for DIFF_FILE in ${DIFF_FILES[@]}; do
            git blame --line-porcelain master.. $DIFF_FILE | perl -0777 -pe 's/[[:xdigit:]]{40} [[:digit:]]+ ([[:digit:]]+)(?: [[:digit:]]+)?\nauthor (.*)\n(?:.*\n){7,8}(?!boundary).*\nfilename (.*)\n(?:\t| {8})(.*)/$2:$3:$1: $4/g' | sed -n "s|$GIT_USERNAME:|$GIT_ROOT/|p"
        done;
    else
        return 1;
    fi
}

# Search My Lines: grep for a pattern in files that you have changed in this branch
sml() {
    if [ ! -z "$(gbranch)" ]; then
        export GIT_USERNAME=$(git config user.name);
        DIFF_FILES=($(gdiff | xargs));
        GIT_ROOT=$(groot)
        OLD_GREP_CONTEXT_SIZE=$GREP_CONTEXT_SIZE;
        GREP_CONTEXT_SIZE=0;
        for DIFF_FILE in ${DIFF_FILES[@]}; do
            git blame --line-porcelain master $DIFF_FILE | perl -0777 -pe 's/[[:xdigit:]]{40} [[:digit:]]+ ([[:digit:]]+)(?: [[:digit:]]+)?\nauthor (.*)\n(?:.*\n){8,9}filename (.*)\n(?:\t| {8})(.*)/$2:$3:$1: $4/g' | sed -n "s|$GIT_USERNAME:| $GIT_ROOT/|p" | sgrep "$*"
        done;
        GREP_CONTEXT_SIZE=$OLD_GREP_CONTEXT_SIZE;
    else
        return 1;
    fi
}

gdm() {
	if [ ! -z "$(gbranch)" ]; then
		git diff master..$(gbranch)
	else
		return 1;
	fi
}
