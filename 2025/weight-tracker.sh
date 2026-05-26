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

# === Handle --log / -l ===
if [ "$1" = "--log" ] || [ "$1" = "-l" ]; then
    if [ $# -eq 1 ]; then
        cat "$WEIGHT_LOG"
    else
        N="$2"
        if ! [[ "$N" =~ ^[0-9]+$ ]]; then
            echo "Error: --log argument must be a positive integer"
            exit 1
        fi
        CUTOFF=$(date -d "today -$N days" +%Y-%m-%d)
        awk -v cutoff="$CUTOFF" '$1 >= cutoff' "$WEIGHT_LOG"
    fi
    exit 0
fi

# === Handle --graph / -g ===
if [ "$1" = "--graph" ] || [ "$1" = "-g" ]; then
    DATA_FILE="$WEIGHT_LOG"
    CLEANUP_FILES=()

    if [ $# -ge 2 ]; then
        N="$2"
        if ! [[ "$N" =~ ^[0-9]+$ ]]; then
            echo "Error: --graph argument must be a positive integer"
            exit 1
        fi
        CUTOFF=$(date -d "today -$N days" +%Y-%m-%d)
        DATA_FILE=$(mktemp)
        CLEANUP_FILES+=("$DATA_FILE")
        awk -v cutoff="$CUTOFF" '$1 >= cutoff' "$WEIGHT_LOG" > "$DATA_FILE"
    fi

    SMOOTH_FILE=$(mktemp)
    CLEANUP_FILES+=("$SMOOTH_FILE")
    trap "rm -f ${CLEANUP_FILES[*]}" EXIT

    awk '{dates[NR]=$1; weights[NR]=$2}
    END {
        for (i=1; i<=NR; i++) {
            sum=0; count=0
            start = (i>6) ? i-6 : 1
            for (j=start; j<=i; j++) { sum+=weights[j]; count++ }
            printf "%s %.1f\n", dates[i], sum/count
        }
    }' "$DATA_FILE" > "$SMOOTH_FILE"

    FIRST_DATE=$(awk 'NR==1{print $1}' "$SMOOTH_FILE")
    LAST_DATE=$(awk 'END{print $1}' "$SMOOTH_FILE")
    DAYS_RANGE=$(( ( $(date -d "$LAST_DATE" +%s) - $(date -d "$FIRST_DATE" +%s) ) / 86400 ))

    if [ "$DAYS_RANGE" -lt 60 ]; then
        XTICS_INTERVAL=604800    # weekly
        XTICS_FORMAT='%b %d'
    elif [ "$DAYS_RANGE" -lt 365 ]; then
        XTICS_INTERVAL=2592000   # ~monthly
        XTICS_FORMAT='%b %Y'
    else
        XTICS_INTERVAL=7862400   # ~quarterly
        XTICS_FORMAT='%b %Y'
    fi

    gnuplot -persistent -e "
        set xdata time;
        set timefmt '%Y-%m-%d';
        set format x '$XTICS_FORMAT';
        set xtics $XTICS_INTERVAL rotate by -45;
        set xlabel 'Date';
        set ylabel 'Weight (lbs)';
        set title 'Weight Log';
        set grid;
        set yrange [138:*];
        plot '$SMOOTH_FILE' using 1:2 with lines lw 2 title '7d avg', \
             172   with lines lw 1 dt 2 lc 'red'   title 'BMI 24.9 upper (172)', \
             150.5 with lines lw 1 dt 2 lc 'gray'  title 'BMI midpoint (150.5)'
    "
    exit 0
fi

# === Input validation for recording new weight ===
if [ $# -ne 1 ]; then
    echo "Usage: wt [weight]"
    exit 1
fi

WEIGHT="$1"

# Validate weight: integer or one decimal place
if ! [[ "$WEIGHT" =~ ^[0-9]+(\.[0-9])?$ ]]; then
    echo "Error: Weight must be a number with at most one decimal place"
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
            'BEGIN {printf "%.1f\n", lw + (nw - lw) * i / diff}')
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
