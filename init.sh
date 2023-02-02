#!/bin/bash

# Pacman dependencies (sorry Debian users)
sudo pacman -S dunst ttf-fira-code xterm dmenu picom feh fcron tmux fzf perl git python gvim arduino-cli xclip scrot

# Python dependencies
python -m ensurepip --upgrade
python -m pip install toml requests
