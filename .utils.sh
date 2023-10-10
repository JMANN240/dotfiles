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

fuzzy-hist() {
        history -d '-1'
        COMMAND=$(history | perl -pe 's/^( +\d+) +(.+)$/$2/' | fzf --tac --exact);
        if [ ! -z "$COMMAND" ]; then
                eval "$COMMAND";
                eval "$PROMPT_COMMAND";
                printf "${PS1@P}$COMMAND\n";
                history -a;
                printf "fuzzy-hist\n$COMMAND\n" >> ~/.bash_history;
                history -c;
                history -r;
        else
                history -a;
                printf "fuzzy-hist\n" >> ~/.bash_history;
                history -c;
                history -r;
        fi
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
    FOUND_FILES=($(find -L $(groot) ! -name "*.class" -type f | fzf -0 -1 -m --exact --reverse --bind pgdn:preview-page-down,pgup:preview-page-up --preview='cat {}' -q $1 | xargs));

    # If there aren't any, exit with -1
    if [ ${#FOUND_FILES[@]} -eq 0 ]; then
        return -1;
    fi

    code ${FOUND_FILES[@]}
}

infopen() {
    FOUND_FILES=($(grep -rlF "$1" . | xargs));
    code ${FOUND_FILES[@]}
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
alias ranger='ranger --choosedir="$HOME/.lastdir"; cd "$(cat ~/.lastdir)"'

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
	NARGS="$#"
    VIM_PATH=$(which vim 2>/dev/null)

    if [ -z $VIM_PATH ]; then
        echo "$SHELL: vim: command not found";
        return 127;
    fi

	$VIM_PATH --version | grep -q +clientserver;
	HAS_CLIENTSERVER="$?";

	echo $TERM | grep -q tmux;
	IN_TMUX="$?";

    if [ $HAS_CLIENTSERVER -eq 0 ]; then
		$VIM_PATH --serverlist | grep -q VIM;
		SERVER_EXISTS="$?";

        if [ $SERVER_EXISTS -eq 0 ]; then
            VIM_COMMAND="$VIM_PATH --servername vim --remote-tab $@";
			if [ $IN_TMUX -eq 0 ]; then
				$VIM_COMMAND
				tmux select-pane -t $(tmux list-panes -F '#T #P' | grep 'VIM' | sed 's/.*VIM \(.*\)/\1/');
			else
				$VIM_COMMAND
			fi
        else
            VIM_COMMAND="$VIM_PATH --servername vim $@";
			if [ $IN_TMUX -eq 0 ]; then
				tmux split-window -bv -l 80% "tmux select-pane -T VIM && $VIM_COMMAND"
			else
				$VIM_COMMAND
			fi
        fi
    else
		VIM_COMMAND="$VIM_PATH $@";
		$VIM_COMMAND
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
            vim $(echo $OUTPUT | sed -E "s|[^ ]+|$SEARCH_ROOT&|g")
        fi
    done
}

ytdl () {
    youtube-dl -f "best,[height<=1080]" -o "~/Videos/%(title)s.%(ext)s" $1
}

ytdlpl () {
    youtube-dl -f "best,[height<=1080]" -o "~/Videos/%(title)s.%(ext)s" https://www.youtube.com/playlist?list=PLMejUA9a8sUPT80FaT8GPP9_agfF2ELzi
}

ytdlm () {
    youtube-dl -x --audio-format mp3 -o "~/Music/%(title)s.%(ext)s" https://www.youtube.com/playlist?list=PLMejUA9a8sUOyjcGkA4tEK-ZAg-hCZaNX
}

up () {
    sudo apt update -y
    sudo apt upgrade -y
}

alias i3conf="vim ~/.config/i3/config"

alias ard="arduino-cli"

ardnano () {
	ard compile --fqbn arduino:avr:nano $1 &&
	ard upload -p /dev/ttyUSB0 --fqbn arduino:avr:nano:cpu=atmega328old $1
}

arduno () {
	ard compile --fqbn arduino:avr:uno $1 &&
	ard upload -p /dev/ttyUSB0 --fqbn arduino:avr:uno $1
}

esp () {
	ard compile --fqbn esp8266:esp8266:generic $1 &&
	ard upload -p /dev/ttyUSB0 --fqbn esp8266:esp8266:generic $1
}

opencm () {
	ard compile --fqbn OpenCM904:OpenCM904:OpenCM904 $1 &&
	ard upload -p /dev/ttyACM0 --fqbn OpenCM904:OpenCM904:OpenCM904 $1
}

pinout () {
	if [ "$1" = "nano" ]; then
		cat ~/.nano.pinout
	fi
}

act () {
	if [ $# -eq 0 ]; then
		source env/bin/activate
	else
		source $1/bin/activate
	fi
}

gpu () {
	if [ $# -eq 1 ]; then
		if [ $1 = "on" ]; then
			sudo system76-power graphics power on
			sudo modprobe nvidia
			sudo modprobe nvidia_uvm
			sudo modprobe nvidia_modeset
			sudo modprobe nvidia_drm
		elif [ $1 = "off" ]; then
			sudo rmmod nvidia_drm
			sudo rmmod nvidia_modeset
			sudo rmmod nvidia_uvm
			sudo rmmod nvidia
			sudo system76-power graphics power off
		fi
	fi
}

copyfile () {
	cat $1 | xclip -sel c
}

savepaste () {
	xclip -o -sel c > $1
}

export TRASH_DIR="$HOME/.trash"

trash () {
	for FILE in $@; do
		FILE_PATH=$(realpath "$FILE")
		FILE_TRASH_DIR=$(echo "$FILE_PATH" | sed -n "s|\(.*\)\/[^\/]\+|$TRASH_DIR\1|p")
		mkdir -p $FILE_TRASH_DIR
		mv $(realpath "$FILE") "$FILE_TRASH_DIR"
		echo "Trashed $FILE"
	done
}

restore () {
	for FILE in $(find "$TRASH_DIR" -type f | fzf -m); do
		NEW_FILE=$(echo "$FILE" | sed -n "s|$TRASH_DIR||p")
		mv "$FILE" "$NEW_FILE"
		echo "Restored $NEW_FILE"
	done
}

empty () {
	rm -rf $TRASH_DIR/*
	echo "Emptied the trash"
}

aur () {
	PACKAGE_NAME=$(echo "$1" | perl -pe 's|.*/([^/]+?)\.git|$1|')
	git clone --depth 1 $1
	cd $PACKAGE_NAME
	makepkg -si
	cd ..
	rm -rf $PACKAGE_NAME
}

rerun () {
        clear; eval $(history | tail -n2 | head -n1 | perl -pe 's| +\d+ +(.+)|$1|');
}

colorize() {
        perl -pe 's|#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})|\x1b[38;2;${\(hex($1))};${\(hex($2))};${\(hex($3))}m#$1$2$3\x1b[0m|g'
}

be() {
        if [ "$#" -eq 0 ]; then
                echo "Dotfile not provided!" >&2;
                return 1;
        fi
        FILEPATH="$HOME/.$1.sh";
        vim $FILEPATH;
        source $FILEPATH;
}

jbuild() {
        SUB="${2:-j}"
        perl -0777pe "s|<$SUB:(.+?)=(.+?)>(.*?)<\/$SUB>|\${\\(\$2 eq \$ENV{\$1} ? \$3 : \"\")}|gs" $1
}
