#!/bin/bash
if [ -f "$HOME/.volume-notification-id.tmp" ]; then
	REPLACE="--replace-id=$(cat $HOME/.volume-notification-id.tmp)"
else
	REPLACE=""
fi

if [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: no" ]; then
	notify-send --expire-time=1000 -p $REPLACE "Volume $(pactl get-sink-volume @DEFAULT_SINK@ | sed -E 's/^Volume: front-left: [0-9]+ \/ +([0-9]+%).*/\1/' | head -n 1)" > ~/.volume-notification-id.tmp
else
	notify-send --expire-time=1000 -p $REPLACE "Volume Muted" > ~/.volume-notification-id.tmp
	echo "muted"
fi
