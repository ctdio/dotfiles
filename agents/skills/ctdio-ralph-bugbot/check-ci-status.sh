#!/usr/bin/env bash
# Check CI status on a PR and report failing checks with details
# Usage: check-ci-status [PR_NUMBER]
# If no PR number provided, uses current PR from gh pr view
#
# Bugbot checks are excluded (tracked separately by wait-for-bugbot.sh).
# Pending CI checks are polled internally until they reach a terminal state.
#
# Exit codes:
#   0 = all checks passing
#   1 = one or more checks failing
#   2 = checks still pending after polling timeout

set -euo pipefail

PR_NUM="${1:-$(gh pr view --json number -q '.number' 2>/dev/null)}"

if [[ -z "$PR_NUM" ]]; then
  echo "Error: No PR number provided and not in a PR context" >&2
  exit 1
fi

MAX_POLL_WAIT="${CI_POLL_TIMEOUT:-300}"
POLL_INTERVAL=30
POLL_ELAPSED=0

while true; do
  echo "Checking CI status on PR #$PR_NUM..."

  # Capture exit code separately to detect API failures
  if ! RAW_CHECKS=$(gh pr checks "$PR_NUM" --json name,state,link 2>&1); then
    echo "Error: Failed to fetch CI checks from GitHub API" >&2
    echo "$RAW_CHECKS" >&2
    exit 1
  fi

  if [[ "$RAW_CHECKS" == "[]" ]] || [[ -z "$RAW_CHECKS" ]]; then
    echo "No checks found on this PR"
    exit 0
  fi

  # Exclude bugbot checks — tracked separately by wait-for-bugbot.sh
  CHECKS=$(echo "$RAW_CHECKS" | jq '[.[] | select(.name | test("bugbot|bug-bot|cursor-bugbot|Cursor Bugbot"; "i") | not)]')

  if [[ "$(echo "$CHECKS" | jq 'length')" -eq 0 ]]; then
    echo "No CI checks found (only bugbot checks present, tracked separately)"
    exit 0
  fi

  # Count statuses
  PENDING=$(echo "$CHECKS" | jq '[.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED")] | length')
  FAILING=$(echo "$CHECKS" | jq '[.[] | select(.state == "FAILURE" or .state == "CANCELLED" or .state == "TIMED_OUT" or .state == "ERROR" or .state == "ACTION_REQUIRED" or .state == "STALE")] | length')
  PASSING=$(echo "$CHECKS" | jq '[.[] | select(.state == "SUCCESS" or .state == "SKIPPED" or .state == "NEUTRAL")] | length')
  TOTAL=$(echo "$CHECKS" | jq 'length')

  echo ""
  echo "=== CI Status Summary ==="
  echo "Total: $TOTAL | Passing: $PASSING | Failing: $FAILING | Pending: $PENDING"
  echo ""

  if [[ "$PENDING" -eq 0 ]]; then
    break
  fi

  POLL_ELAPSED=$((POLL_ELAPSED + POLL_INTERVAL))
  if [[ $POLL_ELAPSED -ge $MAX_POLL_WAIT ]]; then
    echo "Timeout: $PENDING checks still pending after ${MAX_POLL_WAIT}s"
    echo ""
    echo "Pending checks:"
    echo "$CHECKS" | jq -r '.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED") | "  - \(.name): \(.state)"'
    echo ""
    echo "STATUS: PENDING (timed out)"
    exit 2
  fi

  echo "Waiting for $PENDING pending CI checks... (${POLL_ELAPSED}s/${MAX_POLL_WAIT}s)"
  echo "$CHECKS" | jq -r '.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED") | "  - \(.name): \(.state)"'
  echo ""
  sleep "$POLL_INTERVAL"
done

# All checks are terminal
if [[ "$FAILING" -eq 0 ]]; then
  echo "All checks passing!"
  echo "STATUS: SUCCESS"
  exit 0
fi

echo "=== Failing Checks ==="
echo "$CHECKS" | jq -r '.[] | select(.state == "FAILURE" or .state == "CANCELLED" or .state == "TIMED_OUT" or .state == "ERROR" or .state == "ACTION_REQUIRED" or .state == "STALE") | "- \(.name) [\(.state)]\n  URL: \(.link)"'
echo ""
echo "STATUS: FAILURE"
exit 1
