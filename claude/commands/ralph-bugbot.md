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

# Get unresolved review threads from bugbot (with thread IDs for resolving)
gh api graphql -f query='
query {
  repository(owner: "'"$OWNER"'", name: "'"$REPO"'") {
    pullRequest(number: '"$PR_NUM"') {
      reviewThreads(first: 50) {
        nodes {
          id
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

### 3b. Verify RIGOROUSLY

**For potential false positives, you MUST prove it before resolving:**

1. **Read the ENTIRE file** - Get complete context, not just the flagged line
2. **Search for related code** - Use Grep to find similar patterns in codebase
3. **Check defensive code** - Look for validation, error handling, type guards elsewhere
4. **Trace data flow** - Follow the execution path to understand safeguards
5. **Verify false positive criteria** - Confirm it matches one of these:
   - Style suggestion only (no functional impact)
   - Already handled by defensive code elsewhere
   - Impossible condition (proven by type system or validation)
   - Misunderstanding of framework/library behavior

**ONLY if you have concrete evidence it's safe, mark as false positive.**

### 3c. Fix Valid Bugs
- Make minimal, surgical edits
- Follow existing code patterns
- One fix at a time

### 3d. Resolve False Positives

**ONLY after rigorous verification in 3b, resolve the thread:**

```bash
# THREAD_ID from Step 1's output (the "id" field)
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "'"$THREAD_ID"'"}) {
    thread {
      id
      isResolved
    }
  }
}
'
```

**Do not resolve unless you can explain WHY it's a false positive with evidence.**

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
Resolved as false positive: [list files:lines with brief reason]
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
3. **Verify rigorously** - For false positives, gather evidence before resolving
4. **Resolve false positives** - Use GraphQL mutation to mark them resolved (don't just skip)
5. **Never blindly fix OR resolve** - Both bugs and false positives need verification
6. **Minimal changes** - Fix the bug, don't refactor
7. **When uncertain, skip** - Flag for human review instead of guessing
8. **Always commit and push** - After fixes or resolving false positives
9. **One iteration = one pass** - Don't try to loop internally; let ralph-loop handle iteration
