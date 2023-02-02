#!/bin/bash

# Stuff that goes in ~/
cp .aliases.sh .bashrc .git.sh .modes.py .modes.toml .nano.pinout .notify-brightness.sh .notify-volume.sh .prompt.sh .tmux.conf .utils.sh .vimrc .weather.py .Xresources ~

# Stuff that goes in ~/.config/
mkdir -p ~/.config/i3/ && cp i3/config ~/.config/i3/config
mkdir -p ~/.config/i3status/ && cp i3status/config ~/.config/i3status/config
mkdir -p ~/.config/dunst/ && cp dunst/dunstrc ~/.config/dunst/dunstrc
mkdir -p ~/.config/ && cp picom.conf ~/.config/picom.conf

# Stuff that goes in ~/Pictures/
mkdir -p ~/Pictures/ && cp pine_hd.png ~/Pictures/pine.png

# Stuff that goes in /usr/local/bin/
sudo mkdir -p /usr/local/bin/ && sudo cp scrotnot /usr/local/bin/scrotnot && sudo chmod +x /usr/local/bin/scrotnot
sudo mkdir -p /usr/local/bin/ && sudo cp fl /usr/local/bin/fl && sudo chmod +x /usr/local/bin/fl
sudo mkdir -p /usr/local/bin/ && sudo cp scrotnot /usr/local/bin/octave-gui && sudo chmod +x /usr/local/bin/octave-gui

# Stuff that goes in /boot/grub/themes/
sudo mkdir -p /boot/grub/themes/pine/ && sudo cp pine/* /boot/grub/themes/pine/

# Load the Xresources
xrdb -merge ~/.Xresources
