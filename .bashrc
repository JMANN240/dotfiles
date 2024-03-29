# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Disable stopping and starting the terminal, outdated garbo
stty -ixon;

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth;

# append to the history file, don't overwrite it
shopt -s histappend;

# force 24-bit color
export COLORTERM="24bit";

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000;
HISTFILESIZE=2000;

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

include() {
    if [ -f $1 ]; then
        source $1
    fi
}

include ~/.aliases.sh
include ~/.utils.sh
include ~/.prompt.sh
include ~/.git.sh
include ~/.java.sh
include ~/.registers.sh

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
	tmux list-sessions &> /dev/null
	TMUX_RUNNING="$?"
	if [ $TMUX_RUNNING -eq 0 ]; then
		OPTION=$(cat <(echo "n: New Session") <(tmux list-sessions) | fzf --reverse -1 | sed -n 's/:.*$//p');
		if [ "$OPTION" != "" ]; then
			if [ "$OPTION" = "n" ]; then
				tmux new-session
			else
				tmux attach-session -t $OPTION
			fi
		fi
	else
		tmux new-session
	fi
fi

export FZF_DEFAULT_COMMAND="find -L ! -name '*.class'"

export PATH=$PATH:$HOME/.cargo/bin
. "$HOME/.cargo/env"

export PATH=$PATH:$HOME/.local/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export VLC_VERBOSE=0
stty erase ^H

# add up-arrow autocompletion / search functionality
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
