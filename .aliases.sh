# Aliases for editing bashrc
alias rebash="source ~/.bashrc"
alias bashrc="code ~/.bashrc"

# Pretty colors
alias ls="ls --color=auto"

# Vim based editor layout in tmux
alias vcode="source ~/.vcode.sh"

# Lazy Git (Thanks, Frankie)
alias lg="lazygit"

# Scan for wifi networks on my laptop
alias wscan="sudo iwlist wlp2s0 scan"

# Restart the network manager on my laptop
alias wscan="sudo service network-manager restart"

# Alias for opening
alias open="xdg-open"

# Alias for deactivating a python venv
alias deact="deactivate"

# Aliases for systemctl stuff
alias start="sudo systemctl start"
alias stop="sudo systemctl stop"
alias restart="sudo systemctl restart"

# Ask nicely
alias pls="sudo"

# Alias to remove PEAP cache
alias reap="sudo rm /var/lib/iwd/.eap-tls-session-cache && restart iwd"

# Audio outputs
alias headphones="pactl set-sink-port 0 analog-output-headphones"
alias speakers="pactl set-sink-port 0 analog-output-lineout"

# Workspace switches
alias 1="i3-msg -q workspace 1;"
alias 2="i3-msg -q workspace 2;"
alias 3="i3-msg -q workspace 3;"
alias 4="i3-msg -q workspace 4;"
alias 5="i3-msg -q workspace 5;"
alias 6="i3-msg -q workspace 6;"
alias 7="i3-msg -q workspace 7;"
alias 8="i3-msg -q workspace 8;"
alias 9="i3-msg -q workspace 9;"
alias 10="i3-msg -q workspace 10;"
