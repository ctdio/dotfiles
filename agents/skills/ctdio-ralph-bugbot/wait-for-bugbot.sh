#!/usr/bin/env bash
# Wait for bugbot check to complete on a PR
# Usage: wait-for-bugbot [PR_NUMBER]
# If no PR number provided, uses current PR from gh pr view

set -euo pipefail

PR_NUM="${1:-$(gh pr view --json number -q '.number' 2>/dev/null)}"

if [[ -z "$PR_NUM" ]]; then
  echo "Error: No PR number provided and not in a PR context" >&2
  exit 1
fi

echo "Checking bugbot status on PR #$PR_NUM..."

# Wait for bugbot check to appear (may take a few seconds after push)
MAX_WAIT_FOR_CHECK=60
WAIT_COUNT=0
while true; do
  CHECK_STATUS=$(gh pr checks "$PR_NUM" --json name,state \
    --jq '.[] | select(.name | test("bugbot|bug-bot|cursor-bugbot|Cursor Bugbot"; "i")) | .state' \
    | head -1)

  if [[ -n "$CHECK_STATUS" ]]; then
    break
  fi

  WAIT_COUNT=$((WAIT_COUNT + 5))
  if [[ $WAIT_COUNT -ge $MAX_WAIT_FOR_CHECK ]]; then
    echo "No bugbot check found after ${MAX_WAIT_FOR_CHECK}s - bugbot may not be configured"
    exit 0
  fi

  echo "Waiting for bugbot check to appear... (${WAIT_COUNT}s/${MAX_WAIT_FOR_CHECK}s)"
  sleep 5
done

# Wait for bugbot check to complete (max 10 minutes)
MAX_WAIT_FOR_COMPLETE=600
COMPLETE_WAIT_COUNT=0
while true; do
  CHECK_STATUS=$(gh pr checks "$PR_NUM" --json name,state \
    --jq '.[] | select(.name | test("bugbot|bug-bot|cursor-bugbot|Cursor Bugbot"; "i")) | .state' \
    | head -1)

  # Handle empty status (check disappeared or API failure)
  if [[ -z "$CHECK_STATUS" ]]; then
    echo "Warning: Bugbot check status is empty (check may have disappeared)"
    exit 0
  fi

  case "$CHECK_STATUS" in
    SUCCESS|FAILURE|CANCELLED|SKIPPED|NEUTRAL|TIMED_OUT|ACTION_REQUIRED|STALE)
      echo "Bugbot check complete: $CHECK_STATUS"
      exit 0
      ;;
    *)
      COMPLETE_WAIT_COUNT=$((COMPLETE_WAIT_COUNT + 30))
      if [[ $COMPLETE_WAIT_COUNT -ge $MAX_WAIT_FOR_COMPLETE ]]; then
        echo "Timeout: Bugbot check did not complete after ${MAX_WAIT_FOR_COMPLETE}s"
        exit 1
      fi
      echo "Bugbot status: $CHECK_STATUS - waiting 30s... (${COMPLETE_WAIT_COUNT}s/${MAX_WAIT_FOR_COMPLETE}s)"
      sleep 30
      ;;
  esac
done
