#!/bin/bash

SESSION="my_workspace"

# Check if session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Session does not exist, create it
    tmux new-session -d -s $SESSION

    # Create the splits first
    tmux split-window -h -t $SESSION:0
    tmux split-window -v -t $SESSION:0.0

    # Name the panes
    tmux select-pane -t $SESSION:0.2 -T "main"
    tmux select-pane -t $SESSION:0.0 -T "tuido"
    tmux select-pane -t $SESSION:0.1 -T "side"

    # Execute commands
    tmux send-keys -t $SESSION:0.0 "cd ~/notes && ~/notes/tuido" C-m
    tmux send-keys -t $SESSION:0.2 "cd ~/dev" C-m
    tmux send-keys -t $SESSION:0.1 "cd ~" C-m

    # Set focus to main pane
    tmux select-pane -t $SESSION:0.2
fi

# Attach to session
tmux attach-session -t $SESSION
exec bash
