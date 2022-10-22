#!/bin/bash
if [ -s "$HOME/.brightness-notification-id.tmp" ]; then
	REPLACE="--replace-id=$(cat $HOME/.brightness-notification-id.tmp)"
else
	REPLACE=""
fi

notify-send --expire-time=1000 -p $REPLACE "Brightness $(($(brightnessctl g)/$(($(brightnessctl m)/100))))" > ~/.brightness-notification-id.tmp
