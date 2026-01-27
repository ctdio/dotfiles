#!/usr/bin/env bash
# Check CI status on a PR and report failing checks with details
# Usage: check-ci-status [PR_NUMBER]
# If no PR number provided, uses current PR from gh pr view
#
# Exit codes:
#   0 = all checks passing
#   1 = one or more checks failing
#   2 = checks still pending/running

set -euo pipefail

PR_NUM="${1:-$(gh pr view --json number -q '.number' 2>/dev/null)}"

if [[ -z "$PR_NUM" ]]; then
  echo "Error: No PR number provided and not in a PR context" >&2
  exit 1
fi

echo "Checking CI status on PR #$PR_NUM..."

# Get all checks - use the actual available fields
# Capture exit code separately to detect API failures
if ! CHECKS=$(gh pr checks "$PR_NUM" --json name,state,link 2>&1); then
  echo "Error: Failed to fetch CI checks from GitHub API" >&2
  echo "$CHECKS" >&2
  exit 1
fi

if [[ "$CHECKS" == "[]" ]] || [[ -z "$CHECKS" ]]; then
  echo "No checks found on this PR"
  exit 0
fi

# Count statuses (state values: PENDING, SUCCESS, FAILURE, CANCELLED, TIMED_OUT, ERROR, ACTION_REQUIRED, STALE, etc.)
PENDING=$(echo "$CHECKS" | jq '[.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED")] | length')
# Count FAILURE and other problematic states as failing
FAILING=$(echo "$CHECKS" | jq '[.[] | select(.state == "FAILURE" or .state == "CANCELLED" or .state == "TIMED_OUT" or .state == "ERROR" or .state == "ACTION_REQUIRED" or .state == "STALE")] | length')
PASSING=$(echo "$CHECKS" | jq '[.[] | select(.state == "SUCCESS" or .state == "SKIPPED" or .state == "NEUTRAL")] | length')
TOTAL=$(echo "$CHECKS" | jq 'length')

echo ""
echo "=== CI Status Summary ==="
echo "Total: $TOTAL | Passing: $PASSING | Failing: $FAILING | Pending: $PENDING"
echo ""

# If there are pending checks
if [[ "$PENDING" -gt 0 ]]; then
  echo "Pending checks:"
  echo "$CHECKS" | jq -r '.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED") | "  - \(.name): \(.state)"'
  echo ""
  echo "STATUS: PENDING"
  exit 2
fi

# If all passing
if [[ "$FAILING" -eq 0 ]]; then
  echo "All checks passing!"
  echo "STATUS: SUCCESS"
  exit 0
fi

# Show failing checks with details (includes FAILURE and other problematic states)
echo "=== Failing Checks ==="
echo "$CHECKS" | jq -r '.[] | select(.state == "FAILURE" or .state == "CANCELLED" or .state == "TIMED_OUT" or .state == "ERROR" or .state == "ACTION_REQUIRED" or .state == "STALE") | "- \(.name) [\(.state)]\n  URL: \(.link)"'
echo ""
echo "STATUS: FAILURE"
exit 1
