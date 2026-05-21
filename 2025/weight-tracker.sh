#!/bin/bash

set -euo pipefail

CONFIG_DIR="${HOME}/.config"
WEIGHT_LOG="${CONFIG_DIR}/weight.log"

mkdir -p "$CONFIG_DIR"

# === Helper function to calculate rolling average ===
calc_avg() {
    local end_index=$1
    local days=$2
    local start_epoch=$(date -d "${dates[$end_index]} -$days days" +%s)
    local count=0
    local sum=0

    # Start from the end and work backwards within the date range
    for ((i=end_index; i>=0; i--)); do
        local entry_epoch=$(date -d "${dates[$i]}" +%s)
        if [ "$entry_epoch" -ge "$start_epoch" ]; then
            sum=$(awk "BEGIN {print $sum + ${weights[$i]}}")
            count=$((count + 1))
        else
            break
        fi
    done

    if [ "$count" -eq 0 ]; then
        echo "N/A"
    else
        awk "BEGIN {printf \"%.1f\n\", $sum / $count}"
    fi
}

# === Load and display averages ===
load_and_display_averages() {
    # Read all entries into arrays
    declare -a dates weights
    while IFS=' ' read -r date weight; do
        dates+=("$date")
        weights+=("$weight")
    done < "$WEIGHT_LOG"

    TOTAL_ENTRIES=${#dates[@]}
    END_INDEX=$((TOTAL_ENTRIES - 1))
    LAST_DATE="${dates[$END_INDEX]}"
    LAST_WEIGHT="${weights[$END_INDEX]}"

    echo ""
    echo "$LAST_DATE $LAST_WEIGHT"
    [ "$TOTAL_ENTRIES" -ge 7 ] && echo "  1w avg: $(calc_avg $END_INDEX 7)"
    [ "$TOTAL_ENTRIES" -ge 30 ] && echo "  1m avg: $(calc_avg $END_INDEX 30)"
    [ "$TOTAL_ENTRIES" -ge 120 ] && echo "  4m avg: $(calc_avg $END_INDEX 120)"
    [ "$TOTAL_ENTRIES" -ge 365 ] && echo "  1y avg: $(calc_avg $END_INDEX 365)"
    echo ""
}

# === Check if log exists ===
if [ ! -f "$WEIGHT_LOG" ]; then
    if [ $# -eq 0 ]; then
        echo "No weight data yet. Record your first weight with: wt <weight>"
        exit 0
    fi
    # Will initialize below when recording weight
fi

# === Handle no-argument case (just show averages) ===
if [ $# -eq 0 ]; then
    load_and_display_averages
    exit 0
fi

# === Input validation for recording new weight ===
if [ $# -ne 1 ]; then
    echo "Usage: wt [weight]"
    exit 1
fi

WEIGHT="$1"

# Validate weight: must be integer
if ! [[ "$WEIGHT" =~ ^[0-9]+$ ]]; then
    echo "Error: Weight must be a natural number (integer)"
    exit 1
fi

TODAY=$(date +%Y-%m-%d)

# === Initialize log if it doesn't exist ===
if [ ! -f "$WEIGHT_LOG" ]; then
    echo "$TODAY $WEIGHT" > "$WEIGHT_LOG"
    echo "[INFO] Created new weight log at $WEIGHT_LOG"
fi

# === Check if today already has an entry ===
if grep -q "^$TODAY " "$WEIGHT_LOG"; then
    echo "Error: Weight already recorded for today ($TODAY)"
    exit 1
fi

# === Get last recorded entry ===
LAST_ENTRY=$(tail -1 "$WEIGHT_LOG")
read LAST_DATE LAST_WEIGHT <<< "$LAST_ENTRY"

# === Calculate days between last entry and today ===
LAST_EPOCH=$(date -d "$LAST_DATE" +%s)
TODAY_EPOCH=$(date -d "$TODAY" +%s)
DAYS_DIFF=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))

# === Interpolate and append entries ===
INTERPOLATED_COUNT=0
for ((i=1; i<=DAYS_DIFF; i++)); do
    CURRENT_DATE=$(date -d "$LAST_DATE +$i days" +%Y-%m-%d)

    if [ "$i" -eq "$DAYS_DIFF" ]; then
        # Last day: use exact weight
        CURRENT_WEIGHT=$WEIGHT
    else
        # Interpolate: linear interpolation with rounding to nearest integer
        CURRENT_WEIGHT=$(awk -v lw="$LAST_WEIGHT" -v nw="$WEIGHT" -v i="$i" -v diff="$DAYS_DIFF" \
            'BEGIN {printf "%.0f\n", lw + (nw - lw) * i / diff}')
        INTERPOLATED_COUNT=$((INTERPOLATED_COUNT + 1))
    fi

    echo "$CURRENT_DATE $CURRENT_WEIGHT" >> "$WEIGHT_LOG"
done

# Log interpolation if it happened
[ "$INTERPOLATED_COUNT" -gt 0 ] && echo "[INFO] Interpolated $INTERPOLATED_COUNT missing days"

# === Display results ===
echo ""
echo "$TODAY $WEIGHT (recorded)"

# Load arrays for calculation
declare -a dates weights
while IFS=' ' read -r date weight; do
    dates+=("$date")
    weights+=("$weight")
done < "$WEIGHT_LOG"

TOTAL_ENTRIES=${#dates[@]}
TODAY_INDEX=$((TOTAL_ENTRIES - 1))

[ "$TOTAL_ENTRIES" -ge 7 ] && echo "  1w avg: $(calc_avg $TODAY_INDEX 7)"
[ "$TOTAL_ENTRIES" -ge 30 ] && echo "  1m avg: $(calc_avg $TODAY_INDEX 30)"
[ "$TOTAL_ENTRIES" -ge 120 ] && echo "  4m avg: $(calc_avg $TODAY_INDEX 120)"
[ "$TOTAL_ENTRIES" -ge 365 ] && echo "  1y avg: $(calc_avg $TODAY_INDEX 365)"
echo ""
