#!/bin/bash

# Get the current output (monitor) that has focus
if [ ! -f ~/current_output ]; then
    i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output' > ~/current_output
fi

current_output=$(cat ~/current_output)
# swap the content of the file
if [ $# -eq 0 ]; then
    if [[ "$current_output" == "HDMI-0" ]]; then
        echo "DP-4" > ~/current_output
    elif [[ "$current_output" == "DP-4" ]]; then
        echo "HDMI-0" > ~/current_output
    fi
    exit 0
fi

# Compute the workspace name based on current monitor and the input workspace number
new_workspace="$current_output:$1"

# Check if the action is to move the container or to switch the workspace
if [[ "$2" == "move" ]]; then
    # Move the current container to the computed workspace
    i3-msg move container to workspace "$new_workspace"
else
    # Switch to the computed workspace
    i3-msg workspace "$new_workspace"
    i3-msg move workspace to output $current_output
fi
