#!/bin/bash

# Get the current output (monitor) that has focus
if [ ! -f ~/current_output ]; then
    current_output=$(hyprctl activewindow -j | jq -r '.monitor')
    echo "$current_output" > ~/current_output
fi

current_output=$(cat ~/current_output)

# Swap the content of the file if no argument is provided
# MOD + A
if [ $# -eq 0 ]; then
    if [[ "$current_output" == "0" ]]; then
        echo "1" > ~/current_output
    elif [[ "$current_output" == "1" ]]; then
        echo "0" > ~/current_output
    fi
    exit 0
fi

# Compute the workspace name based on current monitor and input workspace number
#
workspace="$current_output:$1"

target_output=$(cat ~/current_output)

# Check if the action is to move the window or switch workspace
if [[ "$2" == "move" ]]; then
    # Move the focused window to the target workspace
    hyprctl dispatch movetoworkspacesilent name:$workspace
else
    # Switch to the target workspace
    hyprctl dispatch workspace name:$workspace
    hyprctl dispatch moveworkspacetomonitor "$workspace" "$target_output"
fi

