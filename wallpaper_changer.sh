#!/bin/bash

# Directory where your wallpapers are stored
WALLPAPER_DIR="/home/master/personal/background"

# Time delay between changes (in seconds), 900s = 15 minutes
DELAY=900

# Main loop
while true; do
  feh --randomize --bg-fill "$WALLPAPER_DIR"/*
  sleep $DELAY
done

