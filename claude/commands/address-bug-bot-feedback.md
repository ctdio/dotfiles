# Address Bug Bot Feedback

Fetch **unresolved** cursor bugbot comments from a PR, verify which are real bugs, and fix them.

**Argument**: `$ARGUMENTS` - PR number (optional, defaults to current branch's PR)

## 1. Fetch Unresolved Comments

```bash
# Get repo and PR info
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')
PR_NUM=${ARGUMENTS:-$(gh pr view --json number -q '.number')}

# Get unresolved review threads
gh api graphql -f query='
query {
  repository(owner: "'"$OWNER"'", name: "'"$REPO"'") {
    pullRequest(number: '"$PR_NUM"') {
      reviewThreads(first: 50) {
        nodes {
          isResolved
          comments(first: 1) {
            nodes { body path line }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)'
```

## 2. For Each Unresolved Comment

### Triage First
Read the comment and categorize before investigating:
- **Likely bug**: Logic errors, null checks, race conditions, security issues
- **Likely false positive**: Style suggestions, "consider using", optional improvements
- **Needs investigation**: Unclear without reading code

### Verify Before Fixing
For each potential bug:

1. **Read the file** - Get full context around the flagged line
2. **Check if real** - Is there actually a bug, or is bugbot wrong?
3. **Look for safeguards** - Does defensive code exist elsewhere?
4. **Decide**: Fix it, skip it (false positive), or flag for human review

### Fix Valid Bugs
- Make minimal, surgical edits
- Follow existing code patterns
- One fix at a time

## 3. Output Summary

After processing all comments:

```
## Bug Bot Review: PR #XXX

**Fixed (N):**
- `file.ts:42` - [issue] → [fix applied]
- `other.ts:88` - [issue] → [fix applied]

**False Positives (N):**
- `file.ts:123` - [claim] → [why it's not a bug]

**Skipped (N):**
- `file.ts:55` - Style suggestion, not a bug

**Needs Review (N):**
- `file.ts:99` - [issue] → [why uncertain]
```

## Rules

1. **Only unresolved comments** - Ignore resolved threads entirely.
2. **Never blindly fix** - Bugbot has false positives. Verify each issue.
3. **Skip style issues** - Only fix functional bugs, not preferences.
4. **Minimal changes** - Fix the bug, don't refactor.
5. **When uncertain, don't fix** - Flag for human review instead.
