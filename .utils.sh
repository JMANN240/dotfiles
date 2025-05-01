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

eval-string() {
	COMMAND=$1;
	eval "$PROMPT_COMMAND";
	printf "${PS1@P}$COMMAND\n";
	eval "$COMMAND";
	history -a;
	printf "$COMMAND\n" >> ~/.bash_history;
	history -c;
	history -r;
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
    # An array of all of the files which match the argument given
    FOUND_FILES=($(find -L $(groot) ! -name "*.class" -type f | fzf -0 -1 -m --exact --reverse --bind pgdn:preview-page-down,pgup:preview-page-up --preview='cat {}' -q $1 | xargs));

    # If there aren't any, exit with -1
    if [ ${#FOUND_FILES[@]} -eq 0 ]; then
        return -1;
    fi
	tvim -p $FOUND_FILES
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
tvim () {
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
            VIM_COMMAND="$VIM_PATH --servername VIM $@";
			if [ $IN_TMUX -eq 0 ]; then
				tmux split-window -bv -e "DISPLAY=$DISPLAY" -l 80% "tmux select-pane -T VIM && $VIM_COMMAND"
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
            tvim $(echo $OUTPUT | sed -E "s|[^ ]+|$SEARCH_ROOT&|g")
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
	xclip -sel c $1
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

msg () {
	if [ ! -f ~/.userips ]
	then
		nmap -sn 10.21.98.1-255 | perl -ne 'print if s|^Nmap scan report for (.+)\.ddm\.local \((.+)\)$|$1: $2|' > ~/.userips
	fi
	IP=$(cat ~/.userips | fzf | perl -pe 's|.+: (.+)|$1|')
	if [ -z "$IP" ]
	then
		return 0
	fi
	if [ -z "$1" ]
	then
		read MESSAGE
	else
		MESSAGE="$1"
	fi
	powershell.exe "Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList \"msg * /TIME:0 $USER: $MESSAGE\" -ComputerName $IP" > /dev/null
}

rerun () {
	clear; eval $(history | tail -n2 | head -n1 | perl -pe 's| +\d+ +(.+)|$1|');
}

colorize() {
	perl -pe 's|#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})|\x1b[38;2;${\(hex($1))};${\(hex($2))};${\(hex($3))}m#$1$2$3\x1b[0m|g'
}

split() {
	perl -pe "s|(\S.{1,$1})\s|\$1\n|g"
}

showsplit() {
	git show --color $1 | split 80
}

printfunc() {
	declare | perl -0777 -ne "print if s|.*($1)\s*\(\)\s*\{ (.+?)\n\}.*|\$1() {\$2\n}|gs"
}

copyfunc() {
	copyfile <(printfunc $1)
}

rmhere() {
	find -maxdepth 1 | fzf -m --reverse --ansi --preview 'if [ -f {} ]; then cat {}; elif [ -d {} ]; then ls -la --color {}; fi;' | xargs rm -rf
}

bhash() {
	perl -ne "print if s|$2: (.+)|\$1|" $1
}

bhash2() {
	MFPATH="/opt/tomcat/webapps/$1/META-INF/MANIFEST.MF";
	BRANCH="$(bhash $MFPATH Build-GitBranch)";
	HASH="$(bhash $MFPATH Build-GitHash)";
	echo "$BRANCH $HASH" | perl -pe 's|\r||';
}

be() {
	if [ "$#" -eq 0 ]; then
		echo "Dotfile not provided!" >&2;
		return 1;
	fi
	FILEPATH="$HOME/.$1.sh";
	nvim $FILEPATH;
	source $FILEPATH;
}

jbuild() {
	SUB="${2:-j}"
	perl -0777pe "s|<$SUB:(.+?)=(.+?)>(.*?)<\/$SUB>|\${\\(\$2 eq \$ENV{\$1} ? \$3 : \"\")}|gs" $1
}

ctl() {
	sudo systemctl $1 $2
}

cstart() {
	ctl start $1
}

cstop() {
	ctl stop $1
}

crestart() {
	ctl restart $1
}

cstatus() {
	ctl status $1
}

naptime() {
	powershell.exe "Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList \"msg * /TIME:0 Naptime!\" -ComputerName $1"
	sleep 1
	powershell.exe "Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList \"rundll32.exe powrprof.dll,SetSuspendState sleep\" -ComputerName $1"
}

coderegex()
{
	results=$(grep --color -rlP "$1")
	if [ -z "$results" ]
	then
		echo "Couldn't anything that matches \"$1\""
	else
		selection=$(grep --color -riIl "$1" | fzf -m --border=bottom --border-label="Select one or more files to open" --preview="cat {} | grep --color=ALWAYS -C 5 $1" --preview-window=down)
		if [[ $selection = *[![:space:]]* ]]
		then
			echo "$selection" | xargs code
		fi
	fi
}

docs()
{
	package=$(dedoc search openjdk~11 | perl -ne 'print if s|^\d+  (.+)$|\1|g' | fzf -q "$1" -1 -0);
	dedoc -c open -c $COLUMNS openjdk~11 $package | batcat -p;
}

