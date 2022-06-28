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

    BRANCH=$(gbranch)

    PS1+="\[$(tput setaf 2)\]\u@\h\[$(tput sgr0)\] "
    PS1+="[\[$(tput setaf 6)\]\W\[$(tput sgr0)\]] "
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