# Ralph Bugbot

Loop-aware skill for iteratively addressing bugbot feedback. Designed to be used with `/ralph-loop`.

**Argument**: `$ARGUMENTS` - PR number (optional, defaults to current branch's PR)

---

## CRITICAL: Execute Commands Immediately

**DO NOT deliberate or explain. Run the bash commands in each step IMMEDIATELY.**

This is an action-oriented skill. Follow steps in order, execute commands directly, move fast.

---

## Step 1: Check Current State

**RUN THIS IMMEDIATELY:**

```bash
# Get repo and PR info
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')
PR_NUM=${ARGUMENTS:-$(gh pr view --json number -q '.number')}

echo "Checking bugbot comments on PR #$PR_NUM..."

# Get unresolved review threads from bugbot
gh api graphql -f query='
query {
  repository(owner: "'"$OWNER"'", name: "'"$REPO"'") {
    pullRequest(number: '"$PR_NUM"') {
      reviewThreads(first: 50) {
        nodes {
          isResolved
          comments(first: 1) {
            nodes {
              author { login }
              body
              path
              line
            }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | select(.comments.nodes[0].author.login == "cursor-bugbot" or .comments.nodes[0].author.login == "bugbot")'
```

## Step 2: Evaluate Completion

**IMMEDIATELY after Step 1:**

- **Zero comments?** → Output `<promise>BUGBOT RESOLVED</promise>` and STOP.
- **Has comments?** → Continue to Step 3. Do not deliberate.

## Step 3: Process Each Comment

For each unresolved bugbot comment:

### 3a. Triage
Categorize before investigating:
- **Likely bug**: Logic errors, null checks, race conditions, security issues
- **Likely false positive**: Style suggestions, "consider using", optional improvements
- **Needs investigation**: Unclear without reading code

### 3b. Verify
1. **Read the file** - Get full context around the flagged line
2. **Check if real** - Is there actually a bug, or is bugbot wrong?
3. **Look for safeguards** - Does defensive code exist elsewhere?
4. **Decide**: Fix it, skip it (false positive), or flag for human review

### 3c. Fix Valid Bugs
- Make minimal, surgical edits
- Follow existing code patterns
- One fix at a time

## Step 4: Commit and Push

**EXECUTE THESE COMMANDS after fixing (do not skip):**

1. Stage all changes: `git add -A`
2. Commit with message describing fixes: `git commit -m "fix: address bugbot feedback"`
3. Push to remote: `git push`

**You MUST run git add, commit, and push. Do not just show the commands.**

## Step 5: Wait for Bugbot Check

**RUN THIS LOOP IMMEDIATELY after pushing. Do not skip.**

```bash
PR_NUM=${ARGUMENTS:-$(gh pr view --json number -q '.number')}
echo "Waiting for bugbot check to complete..."
while true; do
  CHECK_STATUS=$(gh pr checks $PR_NUM --json name,state --jq '.[] | select(.name | test("bugbot|bug-bot|cursor-bugbot|Cursor Bugbot"; "i")) | .state' | head -1)
  if [[ -z "$CHECK_STATUS" ]]; then echo "No bugbot check found, proceeding..."; break; fi
  case "$CHECK_STATUS" in
    SUCCESS|FAILURE|CANCELLED|SKIPPED|NEUTRAL) echo "Bugbot check complete: $CHECK_STATUS"; break ;;
    *) echo "Bugbot check status: $CHECK_STATUS - waiting 30s..."; sleep 30 ;;
  esac
done
```

## Step 6: Report Progress

**Brief summary only** (don't over-explain):

```
Fixed: [list files:lines]
Skipped: [list false positives]
Remaining: [count]
```

## Step 7: Loop Behavior

After pushing and waiting for bugbot check:
- Do NOT output the completion promise yet
- The ralph-loop will re-run this skill
- Next iteration will re-fetch comments (bugbot has finished re-analyzing)
- Only output `<promise>BUGBOT RESOLVED</promise>` when Step 1 finds zero unresolved comments

---

## Rules

1. **Move fast** - Execute commands immediately. No deliberation between steps.
2. **Only unresolved bugbot comments** - Ignore resolved threads and other reviewers
3. **Never blindly fix** - Bugbot has false positives. Verify each issue.
4. **Skip style issues** - Only fix functional bugs, not preferences
5. **Minimal changes** - Fix the bug, don't refactor
6. **When uncertain, skip** - Flag for human review instead of guessing
7. **Always push** - Even if only skipping false positives, push to let bugbot re-analyze
8. **One iteration = one pass** - Don't try to loop internally; let ralph-loop handle iteration
