#!/bin/bash

# Stuff that goes in ~/
cp ~/{.aliases.sh,.bashrc,.git.sh,.modes.py,.modes.toml,.nano.pinout,.notify-brightness.sh,.notify-volume.sh,.prompt.sh,.tmux.conf,.utils.sh,.vimrc,.weather.py,.Xresources} .

# Stuff that goes in ~/.config/
cp ~/.config/i3/config i3/config 
cp ~/.config/i3status/config i3status/config 
cp ~/.config/dunst/dunstrc dunst/dunstrc 
cp ~/.config/picom.conf picom.conf 
cp ~/.config/Code/User/settings.json Code/User/settings.json

# Stuff that goes in ~/Pictures/
cp ~/Pictures/pine.png pine_hd.png 

# Stuff that goes in /usr/local/bin/
sudo cp /usr/local/bin/scrotnot scrotnot 
sudo cp /usr/local/bin/fl fl 
sudo cp /usr/local/bin/octave-gui octave-gui

# Stuff that goes in /boot/grub/themes/
sudo cp /boot/grub/themes/pine/* pine/ 
