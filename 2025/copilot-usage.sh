#!/bin/bash
# Fetch usage and format it as a percentage of 300
# Usage limit is 300 premium requests

USAGE=$(gh api users/nilock/settings/billing/usage/summary 2>/dev/null \
        | jq -r '.usageItems[] | select(.sku == "copilot_premium_request") | .grossQuantity')

if [ -z "$USAGE" ]; then
  echo "Copilot: --%"
else
  # Calculate percentage: (USAGE / 300) * 100
  # Using awk for floating point math since it's likely available
  PERCENT=$(awk "BEGIN {printf \"%.1f\", ($USAGE / 300) * 100}")
  echo "Cpt: ${PERCENT}%"
fi
