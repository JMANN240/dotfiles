tmux new-window -a -c "$(pwd)" -n vcode 'source ~/.utils.sh && source ~/.git.sh && vfe'

tmux split-window -h -p 85 '/usr/bin/vim --servername vim'
tmux display-message -p "#{pane_id}" > ~/.vim_pane_id

tmux split-window -v -p 30
