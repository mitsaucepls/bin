#!/bin/bash

last_pid=''

cleanup() {
    [[ -n "$last_pid" ]] && kill "$last_pid"
    exit 0
}

trap cleanup SIGINT

while true; do
    [[ -n "$last_pid" ]] && kill "$last_pid"; wait "$last_pid" 2>/dev/null

    wallpaperpath="$(find $HOME/personal/background -maxdepth 1 -regex '.*\.\(jpg\|gif\|png\|jpeg\)' | shuf -n 1)"

    [[ "$wallpaperpath" != *.gif ]] && feh --bg-fill $wallpaperpath \
    || {
        digits="${wallpaperpath%.*}";
        digits="${digits: -4}";
        modified_digits="${digits:0:1}.${digits:1}";
        back4.sh "$modified_digits" "$wallpaperpath" &
        last_pid=$!;
    }

    sleep 900
done
