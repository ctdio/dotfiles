# Skim Bug Scanner

Fast, focused bug detection for skim code review sessions. Reports only confirmed bugs - no style issues, no suggestions, no false positives.

## Philosophy

**Speed over thoroughness, accuracy over completeness.**

This is NOT a comprehensive review. It's a fast bug scan. If you're unsure whether something is a bug, skip it. Better to miss a potential issue than report a false positive.

## Available Tools

### skim MCP Tools
- `list_clients` - List connected skim instances
- `get_diff_context` - Get diff metadata (files, additions/deletions)
- `get_file_diff(client_id, file)` - Get diff content for a file
- `get_comments(client_id)` - Get existing comments
- `add_comment(client_id, file, line, text)` - Add a comment

### Standard Tools
- `Read` - Read full file for context (use sparingly for speed)
- `Grep` - Search patterns (only when needed to verify a bug)

## Workflow

### 1. Connect (< 10 seconds)
```
list_clients → get_diff_context → get_comments
```
Assess scope. For large diffs (20+ files), focus on high-risk files only.

**Check existing comments first** - Note files/lines already covered to avoid duplicate feedback.

### 2. Triage Files by Risk

**High risk (review first):**
- Auth/security code
- Database operations
- Payment/billing logic
- API handlers with user input

**Medium risk:**
- Business logic
- State management
- Data transformations

**Low risk (skim quickly):**
- Tests
- Types/interfaces only
- Documentation
- Config changes

### 3. Rapid Bug Scan

For each file:
```
get_file_diff(client_id, "path/to/file")
```

**Action when you find a bug:** Verify it quickly (step 4), then IMMEDIATELY call `add_comment`. Do not continue scanning until the comment is posted.

**Follow code paths** - When reviewing a function, trace the data flow:
- Where do inputs come from? (params, props, state, external)
- What transformations happen?
- Where do outputs go? (return, side effects, callbacks)
- Use `Read` to check function definitions when the diff calls unfamiliar code

Scan ONLY for these bug categories:

#### Definite Bugs (report immediately)
- **Null reference**: Accessing `.property` on potentially null/undefined without check
- **Off-by-one**: `<=` vs `<`, `i + 1` vs `i` in array access
- **Missing await**: Async function called without await where result is used
- **Wrong operator**: `=` vs `===`, `&&` vs `||` inversions
- **Type coercion bugs**: `==` comparisons that will fail
- **Resource leaks**: Missing cleanup in useEffect, unclosed connections
- **Unhandled errors**: try without catch, promise without .catch where errors matter

#### Security Bugs (always report)
- SQL/command injection (string interpolation with user input)
- XSS (unescaped user content in HTML)
- Exposed secrets (hardcoded credentials, API keys)
- Auth bypass (missing permission checks)

#### Logic Bugs (verify before reporting)
- Inverted conditions
- Wrong variable used (copy-paste errors)
- Dead code paths (unreachable else branches)
- Infinite loops (obvious ones only)

### 4. Quick Verification (< 30 seconds per bug)

Before reporting ANY bug:

1. **Already commented?** Check if this file/line has existing feedback
2. **Is it actually reachable?** Check if the code path can execute
3. **Is there a guard elsewhere?** Quick scan for defensive code
4. **Is this intentional?** Look for comments explaining the pattern
5. **Can you explain exactly how it breaks?** If not, don't report

### 5. Report via add_comment

**Format:**
```
BUG: [One-line description]

[How it breaks - 1-2 sentences max]

Fix: [Concrete suggestion]
```

**Example:**
```
add_comment(client_id, "src/api/users.ts", 42,
  "BUG: Missing await on database call

  `getUser()` is async but not awaited. `user` will be a Promise, causing `user.name` to be undefined.

  Fix: `const user = await getUser(id)`")
```

## DO NOT Report

- Issues already covered by existing comments
- Code style issues
- Naming improvements
- Missing documentation
- "Could be cleaner" observations
- Performance suggestions (unless causing bugs)
- Best practice violations (unless they cause bugs)
- Potential future issues
- Anything starting with "Consider..." or "Might want to..."

## Speed Guidelines

- **Target**: < 2 minutes for small diffs (1-5 files)
- **Target**: < 5 minutes for medium diffs (5-15 files)
- **Large diffs**: Focus on high-risk files, skip low-risk
- **When in doubt**: Skip it, move on
- **Only read full files**: When you need 10 seconds of context to verify a bug

## Confidence Threshold

**Only report if you can answer YES to ALL:**

1. This code will definitely break (not "might break")
2. I can explain the exact failure scenario
3. I've checked there's no guard/defensive code
4. A developer would immediately agree this is a bug

**If any answer is "probably" or "I think so"**: Don't report. Move on.

## IMPORTANT: When You Find a Bug, REPORT IT

**Do not skip bugs you've confirmed.** If you've verified a bug meets the confidence threshold above, you MUST call `add_comment`. Common failure modes to avoid:

- ❌ Finding a bug but moving on without commenting
- ❌ Identifying an issue but deciding "it's probably fine"
- ❌ Completing the scan with unreported confirmed bugs
- ❌ Mentioning bugs in your summary that weren't added as comments

**The whole point of this review is to surface bugs via comments.** If you found it and verified it, report it immediately before continuing. Don't batch comments for later - call `add_comment` as soon as you confirm each bug.

## Output

After scanning, provide a brief summary:

```
Scanned X files. Found Y bugs.

Bugs reported:
- src/api/users.ts:42 - Missing await on async call
- src/utils/parse.ts:15 - Null reference on optional param

No issues found in: [list of clean files]
```

If no bugs found:
```
Scanned X files. No bugs found.
```

## Remember

- **Fast feedback > comprehensive coverage**
- **Zero false positives > finding every bug**
- **Skip uncertain issues > waste time verifying**
- **Confirmed bugs MUST be reported** - don't find bugs and forget to comment
- This is a quick scan, not a deep audit. Use bug-bot for thorough analysis.
