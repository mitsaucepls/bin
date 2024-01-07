if [ -z "$TMUX" ]; then
    tmux kill-session -t !main! 2>/dev/null
    tmux new -s !main! -c ~
    tmux attach -t !main!
fi
