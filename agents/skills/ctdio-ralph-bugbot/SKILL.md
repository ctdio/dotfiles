---
name: ctdio-ralph-bugbot
description: Loop-aware skill for iteratively addressing bugbot feedback and CI failures on PRs. Fetches unresolved bugbot comments, triages them, fixes valid bugs, resolves false positives, checks CI status, fixes lint/format/test failures, and commits changes. Designed to be used with ralph-loop.
color: orange
---

# Ralph Bugbot

Loop-aware skill for iteratively addressing bugbot feedback and CI failures. Designed to be used with `/ralph-loop`.

## Purpose

This skill helps you systematically address bugbot feedback and CI failures on pull requests by:

1. Fetching unresolved bugbot comments
2. Triaging each comment (bug vs false positive)
3. Fixing valid bugs with surgical edits
4. Resolving verified false positives via GraphQL
5. Committing and pushing changes
6. Waiting for bugbot to re-analyze
7. Checking CI status (lint, format, tests, build)
8. Fixing any CI failures found

## CRITICAL: Execute Commands Immediately

**DO NOT deliberate or explain. Run the bash commands in each step IMMEDIATELY.**

This is an action-oriented skill. Follow steps in order, execute commands directly, move fast.

## Workflow

### Step 1: Wait for Bugbot (if running)

**RUN THIS IMMEDIATELY to ensure bugbot has finished analyzing:**

Run the `wait-for-bugbot.sh` script in this skill's directory.

This script checks if bugbot is currently running and waits for it to complete before proceeding.

### Step 2: Fetch Unresolved Comments

**RUN THIS IMMEDIATELY:**

```bash
# Get repo and PR info
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')
PR_NUM=$(gh pr view --json number -q '.number')

echo "Fetching unresolved bugbot comments on PR #$PR_NUM..."

# Get ONLY unresolved review threads from bugbot (with thread IDs for resolving)
# IMPORTANT: The jq filter ensures only isResolved==false threads are returned.
# Do NOT process any threads outside this output.
# Fetches ALL comments in each thread for full context (follow-ups, prior resolution attempts, human replies).
UNRESOLVED=$(gh api graphql -f query='
query {
  repository(owner: "'"$OWNER"'", name: "'"$REPO"'") {
    pullRequest(number: '"$PR_NUM"') {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 100) {
            nodes {
              author { login }
              body
              path
              line
              createdAt
            }
          }
        }
      }
    }
  }
}' --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | select(.comments.nodes[0].author.login == "cursor")]')

COUNT=$(echo "$UNRESOLVED" | jq 'length')
echo ""
echo "=== Unresolved Bugbot Comments: $COUNT ==="
echo "$UNRESOLVED" | jq '.'
```

**CRITICAL:** Only the comments printed above are unresolved. Do NOT re-fetch, re-query, or look at any other source of comments. The `isResolved == false` filter has already excluded resolved threads. Work exclusively from this output.

### Step 3: Evaluate Bugbot Comments

**IMMEDIATELY after Step 2, check the count from `$COUNT`:**

- **`$COUNT` is 0?** → Skip to Step 6c (Check CI Status). Bugbot is satisfied but CI may still need fixes.
- **`$COUNT` > 0?** → Continue to Step 4. Process ONLY the comments in `$UNRESOLVED`. Do not deliberate.

### Step 4: Process Each Comment

For each unresolved bugbot comment:

#### Triage

Categorize before investigating:

- **Likely bug**: Logic errors, null checks, race conditions, security issues
- **Likely false positive**: Style suggestions, "consider using", optional improvements
- **Needs investigation**: Unclear without reading code

#### Verify RIGOROUSLY

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

#### Fix Valid Bugs

- Make minimal, surgical edits
- Follow existing code patterns
- One fix at a time
- **DO NOT comment on the PR thread** — just fix the code. The commit and bugbot re-analysis are sufficient. Comments are ONLY for false positive resolutions.

#### Resolve False Positives

**ONLY after rigorous verification:**

1. **First, post a reply explaining the false positive:**

```bash
# THREAD_ID from Step 2's output (the "id" field)
# Replace REASON with your specific evidence-based explanation

REASON="[Your explanation here - be specific about why this is safe]"

# JSON-escape the reason to handle quotes and special characters
ESCAPED_REASON=$(echo "$REASON" | jq -Rs '.')
# Remove the outer quotes that jq adds (we'll add them in the query)
ESCAPED_REASON="${ESCAPED_REASON:1:-1}"

gh api graphql -f query='
mutation {
  addPullRequestReviewThreadReply(input: {
    pullRequestReviewThreadId: "'"$THREAD_ID"'",
    body: "### ✅ Resolved as False Positive\n\n**Reason:** '"$ESCAPED_REASON"'\n\n---\n<sub>🤖 *Automatically triaged by **Claude** via Ralph Bugbot skill — if this seems wrong, please reopen and flag for human review.*</sub>"
  }) {
    comment { id }
  }
}'
```

2. **Then resolve the thread:**

```bash
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

**The reply MUST include:**

- A clear, evidence-based explanation of why it's a false positive
- Reference to the specific defensive code, type system, or validation that makes it safe
- The automated disclaimer so reviewers know it was triaged by Ralph Bugbot

### Step 5: Commit and Submit

**EXECUTE THESE COMMANDS after fixing (do not skip):**

1. Stage all changes: `git add -A`
2. Commit with message describing fixes: `git commit -m "fix: address bugbot feedback"`
3. Submit via Graphite: `gt submit --update-only`

**You MUST run git add, commit, and gt submit. Do not just show the commands.**

**IMPORTANT:** Never use `git push`, `git rebase`, or `git pull`. Always use `gt submit --update-only` for pushing changes.

**After pushing, go to Step 6.** Every push invalidates the current state — bugbot will re-analyze and CI will re-run. You must verify the new state before reporting.

### Step 6: Verify Clean State (Post-Push Loop)

**MANDATORY after every `gt submit`. This is where you grind.**

Every push triggers new bugbot analysis and new CI runs. You cannot trust the previous state. You must re-verify everything from scratch.

#### 6a: Wait for Bugbot

Run `wait-for-bugbot.sh`. Do not proceed until bugbot reaches a terminal state.

#### 6b: Re-fetch Bugbot Comments

Re-run the Step 2 query to check for new or remaining unresolved bugbot comments.

- **New comments found?** → Go back to Step 4. Process them, fix/resolve, commit, push, return here.
- **Zero comments?** → Continue to 6c.

#### 6c: Check CI Status

Run `check-ci-status.sh`.

- **Exit code 0 (SUCCESS):** All CI checks passing → Continue to Step 7 (Report).
- **Exit code 1 (FAILURE):** Failing checks found → Fix them (see "Fixing CI Failures" below), commit, push via `gt submit --update-only`, then **restart Step 6 from 6a**. The push invalidates state again.
- **Exit code 2 (TIMEOUT):** Checks still pending → **Wait 60s and re-run. Repeat up to 3 successive times.** If still pending after 3 retries, report the pending checks and do NOT emit the completion promise. **NEVER conclude the task while checks are pending.**

#### 6d: Confirm Clean

You may ONLY proceed to Step 7 when ALL of these are true in a single pass through Step 6 with NO pushes required:

1. `wait-for-bugbot.sh` reached a terminal state
2. Zero unresolved bugbot comments
3. `check-ci-status.sh` exited 0

If you pushed during this step (fixing bugbot comments or CI failures), you MUST restart Step 6 from 6a. A push resets the verification. Keep grinding until a full pass completes with nothing to fix.

#### Fixing CI Failures

When checks fail, follow this process for each failing check:

**1. Get failure details:**

Run the `get-check-logs.sh` script:

```bash
# Get all failed logs
./get-check-logs.sh

# Or filter by check name
./get-check-logs.sh "lint"
./get-check-logs.sh "test"
```

The script extracts run IDs from check URLs and uses `gh run view --log-failed` to fetch the actual error output.

**2. Identify the issue type and fix:**

| Check Type     | Common Issues                  | Fix Approach                                  |
| -------------- | ------------------------------ | --------------------------------------------- |
| **Lint**       | ESLint, TSLint, Pylint errors  | Run linter locally, fix reported errors       |
| **Format**     | Prettier, Black, gofmt         | Run formatter: `npm run format` or equivalent |
| **Type Check** | TypeScript, mypy errors        | Fix type errors in reported files             |
| **Tests**      | Unit/integration test failures | Read test output, fix failing assertions      |
| **Build**      | Compilation errors             | Fix syntax/import errors                      |

**3. Common fix commands (run locally first):**

```bash
# JavaScript/TypeScript
npm run lint -- --fix    # Auto-fix lint errors
npm run format           # Run formatter
npm run typecheck        # Check types
npm test                 # Run tests locally

# Python
ruff check --fix .       # Auto-fix lint
black .                  # Format
mypy .                   # Type check
pytest                   # Run tests

# Go
go fmt ./...             # Format
golangci-lint run        # Lint
go test ./...            # Run tests
```

**4. After fixing CI failures:**

- Stage changes: `git add -A`
- Commit: `git commit -m "fix: address CI failures"`
- Submit via Graphite: `gt submit --update-only`
- **Restart Step 6 from 6a.** The push invalidates state — bugbot will re-analyze, CI will re-run.

**5. If you cannot fix a CI failure:**

- Note it in the progress report
- Let the human know what's failing and why you couldn't fix it
- Continue with other fixable issues

### Step 7: Report Progress

**You should only reach this step after Step 6d confirmed a completely clean state.** If you are here, it means a full pass through Step 6 completed with zero bugbot comments AND `check-ci-status.sh` exit 0 AND no pushes were needed.

**If ALL checks pass** (you came through Step 6d cleanly):

```
RESOLVED — PR is clean.

Fixed: [list files:lines]
Resolved as false positive (replied + resolved): [list files:lines with brief reason]
CI fixes: [list what was fixed - lint, format, tests, etc.]
Bugbot comments: 0 unresolved
CI status: ALL PASSING
```

**If you could NOT achieve a clean state** (unfixable CI failure, pending timeout after retries, etc.):

```
NOT RESOLVED — issues remain.

Fixed: [list files:lines]
Resolved as false positive (replied + resolved): [list files:lines with brief reason]
CI fixes: [list what was fixed - lint, format, tests, etc.]
Remaining bugbot comments: [count]
CI status: [FAILING/PENDING with details]
Blocking issues: [what still needs to pass]
```

**NEVER report the PR as resolved, clean, or done unless Step 6d confirmed it.** Partial success is not resolution. If you pushed fixes and didn't re-verify, you are NOT done — go back to Step 6a.

### Step 8: Loop Behavior

After reporting:

- If you reported RESOLVED, ralph-loop will confirm completion
- If you reported NOT RESOLVED, ralph-loop will re-run this skill for another pass

**Completion criteria — ALL must be true simultaneously in a single verification pass (Step 6) with NO pushes:**

1. `wait-for-bugbot.sh` reached a terminal state (not pending, not timed out)
2. Re-fetch finds zero unresolved bugbot comments
3. `check-ci-status.sh` exits 0 (all CI checks passing)

**You are NOT done until everything has settled.** Do not rationalize early exits. Do not describe pending checks as "just a status indicator" or "external check that can be ignored." If a script is still polling, a check is still pending, or bugbot hasn't finished — you wait. The entire purpose of this skill is to keep going until the PR is clean.

### CRITICAL: Handling Pending States

**If bugbot or any CI check is in a PENDING state, you MUST wait for it to finish before emitting the completion promise.** Specifically:

- If `wait-for-bugbot.sh` reports bugbot is still running or pending → **wait for it to complete, then re-fetch comments**
- If `check-ci-status.sh` exits with code 2 (timeout/pending) → **sleep 60 seconds and re-run the script. Repeat up to 3 successive times.** After 3 retries, report the pending checks but do NOT emit the completion promise.
- **Step 6 is MANDATORY after every push** — every `gt submit` invalidates state. You must re-verify bugbot AND CI from scratch.
- **NEVER emit `<promise>` while any check is pending** — a pending check is not a passing check
- **NEVER describe a pending check as "external" or "not blocking"** — all checks must reach a terminal state
- **NEVER skip CI verification** — CI status must always be checked and must always reach a terminal state before you can conclude
- **A push resets verification** — if you pushed during Step 6 (fixing bugbot or CI), restart Step 6 from 6a. You have not verified the post-push state yet.

If you find yourself writing "pending" in your progress report, that is a signal you are NOT done. Go back and wait.

## Rules

1. **Move fast** - Execute commands immediately. No deliberation between steps.
2. **Only unresolved bugbot comments** - Work EXCLUSIVELY from the `$UNRESOLVED` output from Step 2. Never re-fetch threads, never look at resolved threads, never process comments from other reviewers. If a thread is not in `$UNRESOLVED`, it does not exist for you.
3. **Verify rigorously** - For false positives, gather evidence before resolving
4. **Resolve false positives** - Use GraphQL mutation to mark them resolved (don't just skip)
5. **Never blindly fix OR resolve** - Both bugs and false positives need verification
6. **Minimal changes** - Fix the bug, don't refactor
7. **When uncertain, skip** - Flag for human review instead of guessing
8. **Always commit and submit** - After fixes or resolving false positives, use `gt submit --update-only`
9. **Grind until clean** - After every push, re-verify bugbot AND CI from scratch (Step 6). Keep looping internally until a full verification pass completes with nothing to fix. Ralph-loop handles cross-iteration retries, but within a single iteration you must exhaust the fix→push→verify loop.
10. **Fix CI failures** - After addressing bugbot, check and fix lint/format/test failures
11. **Run locally first** - For CI failures, run the failing check locally before pushing fixes
12. **Never rebase, push, or pull** - Only use `git add`, `git commit`, and `gt submit --update-only`. Graphite handles branch management.
13. **Never comment on valid bug fixes** - Do NOT post replies to PR threads when fixing actual bugs. The code fix + commit is sufficient. Only post comments when resolving false positives (the explanation reply is required there). No "Fixed in commit X" or similar comments.
14. **Never conclude until fully settled** - If any check is pending, any script is polling, or bugbot hasn't finished analyzing, you are not done. Do not rationalize pending checks as "status indicators" or "external checks." Wait until everything reaches a terminal state.
15. **Never emit `<promise>` while anything is pending** - The word "pending" in your output means you are NOT done. If you wrote "pending" anywhere in your progress report, do not emit the completion promise. Go back and wait for the pending item to resolve.
16. **Only report "resolved" when ALL checks pass** - Partial success is not resolution. If bugbot comments are at zero but CI is failing, you are NOT resolved. If CI is passing but bugbot comments remain, you are NOT resolved. All three completion criteria (Step 8) must be true simultaneously in a single verification pass with no pushes before you can say the PR is clean.

## Usage

Invoke this skill when:

- You need to address bugbot feedback on a PR
- You need to fix CI failures (lint, format, tests)
- Used with `/ralph-wiggum:ralph-loop` for automated iteration
- User says "fix bugbot comments", "fix CI", or similar

The skill will loop via ralph-loop until all bugbot comments are resolved and all CI checks pass.
