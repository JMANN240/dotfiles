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
