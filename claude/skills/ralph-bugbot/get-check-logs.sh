#!/usr/bin/env bash
# Fetch logs for failing checks on a PR
# Usage: get-check-logs [CHECK_NAME] [PR_NUMBER]
#
# If CHECK_NAME provided: fetches logs for that specific check
# If no CHECK_NAME: fetches failed logs for all failing checks
#
# Examples:
#   get-check-logs                    # Get all failed logs
#   get-check-logs "lint"             # Get logs matching "lint"
#   get-check-logs "lint-type-check" 123

set -euo pipefail

CHECK_NAME="${1:-}"
PR_NUM="${2:-$(gh pr view --json number -q '.number' 2>/dev/null)}"

if [[ -z "$PR_NUM" ]]; then
  echo "Error: No PR number provided and not in a PR context" >&2
  exit 1
fi

echo "Fetching CI logs for PR #$PR_NUM..."

# Get the failing checks with their workflow/run info
CHECKS=$(gh pr checks "$PR_NUM" --json name,state,link,workflow 2>/dev/null || echo "[]")

if [[ -z "$CHECKS" ]] || [[ "$CHECKS" == "[]" ]]; then
  echo "No checks found"
  exit 1
fi

# Filter to failing checks, optionally by name
if [[ -n "$CHECK_NAME" ]]; then
  FAILING=$(echo "$CHECKS" | jq -r --arg name "$CHECK_NAME" \
    '.[] | select(.state == "FAILURE") | select(.name | test($name; "i")) | .link')
else
  FAILING=$(echo "$CHECKS" | jq -r '.[] | select(.state == "FAILURE") | .link')
fi

if [[ -z "$FAILING" ]]; then
  if [[ -n "$CHECK_NAME" ]]; then
    echo "No failing checks found matching '$CHECK_NAME'"
  else
    echo "No failing checks found"
  fi
  exit 0
fi

# Extract run IDs from the URLs and fetch logs
echo "$FAILING" | while read -r url; do
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
