#!/bin/bash

create_terminal_session() {
    ghostty -e /home/colin/dev/configutils/2025/tmux-workspace-setup.sh
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
        | grep -q "ghostty"; then

        # Focus existing ghostty window
        gdbus call --session \
                  --dest org.gnome.Shell \
                  --object-path /org/gnome/Shell \
                  --method org.gnome.Shell.Eval \
                  "global.get_window_actors().filter(w => w.meta_window.get_title().toLowerCase().includes('ghostty'))[0].meta_window.activate(0)"
    else
        create_terminal_session
    fi
else
    # X11 approach
    if wmctrl -l | grep -i "ghostty"; then
        wmctrl -a "ghostty"
    else
        create_terminal_session
    fi
fi
