#!/bin/bash

CACHE_FILE="/tmp/tmux_copilot_usage"
INTERVAL=300 # 5 minutes

# Check if cache exists and is newer than INTERVAL
if [[ -f "$CACHE_FILE" ]]; then
    last_update=$(stat -c %Y "$CACHE_FILE")
    now=$(date +%s)
    if (( now - last_update < INTERVAL )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# If expired or missing, run the actual script and save to cache
RESULT=$(~/dev/configutils/2025/copilot-usage.sh)
echo -n "$RESULT" > "$CACHE_FILE"
echo -n "$RESULT"
