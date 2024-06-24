#!/bin/bash

wallpapers_path="$HOME/personal/background"
swaymsg output "*" bg "$(find $wallpapers_path -regex '.*\.\(jpg\|gif\|png\|jpeg\)' | shuf -n 1)" fill
