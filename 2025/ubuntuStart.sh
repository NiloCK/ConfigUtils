#!/bin/bash

create_terminal_session() {
    gnome-terminal --maximize -- bash -c '
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
    '
}

# Check if we're running Wayland or X11
SESSION_TYPE=$(echo $XDG_SESSION_TYPE)

if [ "$SESSION_TYPE" = "wayland" ]; then
    # Wayland approach
    if gdbus call --session \
                  --dest org.gnome.Shell \
                  --object-path /org/gnome/Shell \
                  --method org.gnome.Shell.Eval \
                  "global.get_window_actors().map(w => w.meta_window.get_title()).join('\n')" \
        | grep -q "Terminal"; then

        # Focus existing terminal
        gdbus call --session \
                  --dest org.gnome.Shell \
                  --object-path /org/gnome/Shell \
                  --method org.gnome.Shell.Eval \
                  "global.get_window_actors().filter(w => w.meta_window.get_title().includes('Terminal'))[0].meta_window.activate(0)"
    else
        create_terminal_session
    fi
else
    # X11 approach
    if wmctrl -l | grep -i "terminal"; then
        wmctrl -a "Terminal"
    else
        create_terminal_session
    fi
fi
