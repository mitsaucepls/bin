#!/bin/bash

# Directory where your wallpapers are stored
WALLPAPER_DIR="/home/master/personal/background"

# Time delay between changes (in seconds), 900s = 15 minutes
DELAY=900

# Lock file path
LOCK_FILE="/tmp/wallpaper_change.lock"

# Check if the lock file exists and exit if another instance is running
if [ -e "$LOCK_FILE" ]; then
  exit
fi

# Create a lock file
touch "$LOCK_FILE"

# Ensure the lock file is removed when the script exits
trap "rm -f $LOCK_FILE" EXIT

# Main loop
while true; do
  feh --randomize --bg-fill "$WALLPAPER_DIR"/*
  sleep $DELAY
done

