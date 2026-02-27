#!/bin/bash

CACHE_FILE="/tmp/tmux_prod_health"
INTERVAL=60

# Check if cache exists and is newer than 60 seconds
if [[ -f "$CACHE_FILE" ]]; then
    last_update=$(stat -c %Y "$CACHE_FILE")
    now=$(date +%s)
    if (( now - last_update < INTERVAL )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# If expired or missing, run your actual script and save to cache
# Replace 'tmux-prod-health.sh' with the full path to your original script
RESULT=$(~/dev/configutils/2025/tmux-prod-health.sh)
echo -n "$RESULT" > "$CACHE_FILE"
echo -n "$RESULT"
