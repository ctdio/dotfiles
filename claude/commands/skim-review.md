# Skim Code Review

You will review code and post comments using skim MCP tools. **You must actually invoke the tools, not just describe what you would do.**

## Step 1: Get the diff context

**Do this now:** Call `mcp__skim__list_clients` to get the client_id, then call `mcp__skim__get_diff_context` with that client_id.

## Step 2: Load project rules

Read `~/.claude/CLAUDE.md` and any `.cursorrules` files to understand what patterns to look for.

## Step 3: Review each changed file

For each file in the diff:

1. **Call `mcp__skim__get_file_diff`** with the client_id and file path
2. Analyze the diff for bugs, architecture issues, and anti-patterns (see checklist below)
3. **For EVERY issue you find, IMMEDIATELY call `mcp__skim__add_comment`** before moving to the next issue

### How to post a comment

When you find an issue, invoke the tool like this:

```
mcp__skim__add_comment
  client_id: <the client id>
  file_path: <path to file>
  line_number: <line number in the NEW file>
  comment: "BUG: Missing null check\nThis will throw if user is undefined.\nFix: Add guard `if (!user) return`"
```

**DO NOT** just list issues in your response. **DO NOT** save comments for later. **INVOKE THE TOOL** for each issue as you find it.

---

## What to flag

### Bugs
- Null/undefined access without guards
- Missing await on async calls
- Off-by-one errors
- Wrong operators (= vs ===, && vs ||)
- Resource leaks
- Security issues (injection, XSS, hardcoded secrets)

Format: `BUG: [title]\n[explanation]\nFix: [suggestion]`

### Architecture violations
- Wrong file order (should be: imports → types → constants → exports → helpers)
- Arrow functions at module level (should use `function`)
- Helpers mixed between exports
- Main exports buried after helpers

Format: `ARCH: [title]\n[why it matters]\nSuggestion: [fix]`

### Anti-patterns
- Over-engineering / premature abstraction
- Backwards compat shims (deprecated aliases)
- Code duplication (3+ times)
- useEffect for derived state
- console.log in production code
- Empty catch blocks

Format: `ANTI-PATTERN: [title]\n[why problematic]\nBetter: [alternative]`

---

## Verification (before each comment)

- Is the code path reachable?
- Is there a guard elsewhere?
- Can you explain exactly why it's wrong?
- High confidence only - skip if uncertain

---

## Step 4: Summarize

After posting all comments, provide a summary:

```
## Review Complete

Posted {N} comments on {X} files.

### Comments posted:
- file.ts:42 - BUG: description
- file.ts:87 - ARCH: description
```

---

## Critical rules

1. **INVOKE THE TOOLS** - Don't just talk about what you would do
2. **Post comments immediately** - Call add_comment the moment you find an issue
3. **High bar** - Only flag issues worth blocking a PR for
4. **No batching** - Post each comment before analyzing further
