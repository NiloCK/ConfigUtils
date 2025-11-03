#!/bin/bash

# Production health check for tmux status bar
# Checks letterspractice.com backend health endpoint

ENDPOINT="https://letterspractice.com/backend/health"
TIMEOUT=5

# Get current time in HH:MM format
TIMESTAMP=$(date +"%H:%M")

# Try to fetch health status
RESPONSE=$(curl -s --max-time $TIMEOUT "$ENDPOINT" 2>/dev/null)
CURL_EXIT=$?

# Check if curl succeeded
if [ $CURL_EXIT -ne 0 ]; then
    echo "#[fg=colour16,bg=colour220,bold]⚠ PROD#[fg=colour250,bg=colour237] ${TIMESTAMP}"
    exit 0
fi

# Parse JSON - check status and features count
STATUS=$(echo "$RESPONSE" | jq -r '.status // empty' 2>/dev/null)
FEATURES_COUNT=$(echo "$RESPONSE" | jq '.features | length' 2>/dev/null)

# Validate health
if [ "$STATUS" = "ok" ] && [ "$FEATURES_COUNT" = "2" ]; then
    echo "#[fg=colour255,bg=colour28,bold]✓ PROD#[fg=colour250,bg=colour237] ${TIMESTAMP}"
else
    echo "#[fg=colour255,bg=colour160,bold]✗ PROD#[fg=colour250,bg=colour237] ${TIMESTAMP}"
fi
