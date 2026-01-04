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

while true; do
  CHECK_STATUS=$(gh pr checks "$PR_NUM" --json name,state \
    --jq '.[] | select(.name | test("bugbot|bug-bot|cursor-bugbot|Cursor Bugbot"; "i")) | .state' \
    | head -1)

  if [[ -z "$CHECK_STATUS" ]]; then
    echo "No bugbot check found"
    exit 0
  fi

  case "$CHECK_STATUS" in
    SUCCESS|FAILURE|CANCELLED|SKIPPED|NEUTRAL)
      echo "Bugbot check complete: $CHECK_STATUS"
      exit 0
      ;;
    *)
      echo "Bugbot status: $CHECK_STATUS - waiting 30s..."
      sleep 30
      ;;
  esac
done
