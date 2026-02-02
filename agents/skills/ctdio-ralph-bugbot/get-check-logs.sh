#!/usr/bin/env bash
# Fetch logs for a specific failing check on a PR
# Usage: get-check-logs CHECK_NAME [PR_NUMBER]
#
# CHECK_NAME is required - use check-ci-status.sh first to see failing checks
#
# Examples:
#   get-check-logs "lint"                 # Get logs for failing "lint" check
#   get-check-logs "lint-type-check" 123  # Specific check on specific PR

set -euo pipefail

CHECK_NAME="${1:-}"
PR_NUM="${2:-$(gh pr view --json number -q '.number' 2>/dev/null)}"

if [[ -z "$CHECK_NAME" ]]; then
  echo "Error: CHECK_NAME is required. Use check-ci-status.sh to see available checks." >&2
  exit 1
fi

if [[ -z "$PR_NUM" ]]; then
  echo "Error: No PR number provided and not in a PR context" >&2
  exit 1
fi

echo "Fetching '$CHECK_NAME' logs for PR #$PR_NUM..."

# Get all checks with their workflow/run info
CHECKS=$(gh pr checks "$PR_NUM" --json name,state,link,workflow 2>/dev/null || echo "[]")

if [[ -z "$CHECKS" ]] || [[ "$CHECKS" == "[]" ]]; then
  echo "No checks found"
  exit 1
fi

# Filter to failing checks matching the name (includes FAILURE and other problematic states)
# Use ascii_downcase and contains for case-insensitive literal matching (not regex)
# This avoids issues with special characters in check names like "build (ubuntu-latest)"
MATCHING=$(echo "$CHECKS" | jq -r --arg name "$CHECK_NAME" \
  '.[] | select(.state == "FAILURE" or .state == "CANCELLED" or .state == "TIMED_OUT" or .state == "ERROR" or .state == "ACTION_REQUIRED" or .state == "STALE") | select(.name | ascii_downcase | contains($name | ascii_downcase)) | .link')

if [[ -z "$MATCHING" ]]; then
  echo "No failing checks found matching '$CHECK_NAME'"
  exit 0
fi

# Extract run IDs from the URLs and fetch logs
echo "$MATCHING" | while read -r url; do
  # GitHub Actions URLs look like: https://github.com/owner/repo/actions/runs/12345/job/67890
  if [[ "$url" =~ actions/runs/([0-9]+) ]]; then
    RUN_ID="${BASH_REMATCH[1]}"
    echo ""
    echo "=== Logs for run $RUN_ID ==="
    echo "URL: $url"
    echo "---"
    # Get failed job logs (last 150 lines to keep output manageable)
    gh run view "$RUN_ID" --log-failed 2>&1 | tail -150
  else
    echo ""
    echo "=== Non-GitHub-Actions check ==="
    echo "URL: $url"
    echo "(Cannot fetch logs for external checks - view in browser)"
  fi
done
