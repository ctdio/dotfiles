---
description: Execute feature plans from ~/.ai/plans with quality gate enforcement
argument-hint: Feature name (directory in ~/.ai/plans)
---

# Feature Implementation

Execute a feature plan from `~/.ai/plans/{feature}/` with strict quality gate enforcement. This skill reads the plan, tracks progress in `implementation-state.md`, and enforces Completion Criteria before advancing phases.

**Usage with ralph-loop**:
```
/ralph-loop "implement {feature} using the feature-implementation skill" --completion-promise "FEATURE_COMPLETE" --max-iterations 50
```

---

## Core Principles

1. **Plan is the contract** - The plan's Completion Criteria define "done"
2. **Verify before advancing** - Run ALL verification commands before marking phases complete
3. **No broken code** - Never advance with failing tests, lint errors, or type errors
4. **Reflect before claiming done** - Self-verify against criteria before outputting promise

---

## Phase: Initialize

**Goal**: Load plan and establish state

**Actions**:
1. Read `~/.ai/plans/{feature}/implementation-guide.md` (or overview.md)
2. Read `~/.ai/plans/{feature}/implementation-state.md` (create if missing)
3. Identify current phase from state file
4. Create todo list tracking all phases

**State File Format** (`implementation-state.md`):
```markdown
# Implementation State: {Feature Name}

**Last Updated**: {DATE}
**Current Phase**: {PHASE_NUMBER}
**Status**: in_progress | completed

## Phase 1: {Name}
**Status**: completed | in_progress | pending
**Started**: {DATE}
**Completed**: {DATE}

### Verification Results
- Build: PASS
- Lint: PASS
- Type-check: PASS
- Tests: PASS (2397/2397)

### Completed Tasks
- [x] Task 1
- [x] Task 2

### Deviations from Plan
- {Description of any deviation and why}

### Files Modified
- `path/to/file.ts` - What changed
```

---

## Phase: Implement Current Phase

**Goal**: Complete the current phase according to the plan

**Actions**:
1. Read phase-specific docs from plan (e.g., `phase-01-foundation/technical-details.md`)
2. Read files identified in the plan
3. Implement deliverables one by one
4. Update todos as you progress
5. Document any deviations in state file

**CRITICAL RULES**:
- Follow the plan's specified approach
- Match existing codebase patterns
- Write tests for new code
- Do NOT skip to next phase until current phase passes verification

---

## Phase: Verification Gate

**Goal**: Verify phase completion criteria before advancing

**This is the most critical phase. DO NOT SKIP.**

**Actions**:

### Step 1: Read Completion Criteria
Extract the Completion Criteria table from the current phase in the plan.

### Step 2: Run Each Verification Command
For each command in the Completion Criteria table, run it and capture the result:

```bash
# Standard verification (run each, capture exit code)
npm run build
npm run lint
npm run type-check
npm run test
```

### Step 3: Evaluate Results

**If ANY check FAILS**:
1. DO NOT mark phase complete
2. DO NOT advance to next phase
3. Identify the failure (read error output)
4. Fix the issue
5. Re-run verification
6. Repeat until ALL checks pass

**If ALL checks PASS**:
1. Update implementation-state.md with verification results
2. Mark phase as completed
3. Proceed to next phase

### Step 4: Phase-Specific Checks
If the plan lists phase-specific checks, verify each one manually and document in state file.

---

## Phase: Advance to Next Phase

**Goal**: Safely transition to the next phase

**Actions**:
1. Confirm current phase verification passed (re-check state file)
2. Check dependencies for next phase (read plan)
3. Update state file: Current Phase = next phase number
4. Update todos
5. Begin "Implement Current Phase" for next phase

---

## Completion Protocol

**When all phases are complete, perform FINAL VERIFICATION**:

### Self-Reflection Checklist

Before outputting `<promise>FEATURE_COMPLETE</promise>`, verify:

```
[ ] ALL phases marked complete in implementation-state.md
[ ] FINAL npm run build passes (run it now, don't assume)
[ ] FINAL npm run lint passes (run it now)
[ ] FINAL npm run type-check passes (run it now)
[ ] FINAL npm run test passes (run it now)
[ ] Feature works as specified in plan
[ ] No regressions to existing functionality
[ ] No console.log/debug statements left in code
[ ] No TODO comments left unaddressed
[ ] Implementation-state.md accurately reflects final state
```

### Final Verification Command
```bash
npm run build && npm run lint && npm run type-check && npm run test && echo "ALL CHECKS PASSED"
```

**If the above command succeeds AND all checklist items are true**:
```
<promise>FEATURE_COMPLETE</promise>
```

**If ANY check fails or checklist item is false**:
- DO NOT output the promise
- Fix the issue
- Re-verify
- Only output promise when genuinely complete

---

## Error Recovery

**If stuck in a loop (same error 3+ times)**:
1. Stop and analyze the pattern
2. Read error messages carefully
3. Consider alternative approaches
4. If truly stuck, document the blocker and ask for help

**If verification keeps failing**:
1. Read the full error output
2. Check if the fix introduced new issues
3. Run tests in isolation to identify the specific failure
4. Don't make random changes - understand the root cause

**If plan is unclear or wrong**:
1. Document the ambiguity in implementation-state.md under "Deviations"
2. Make a reasonable decision
3. Note what you decided and why
4. Continue implementation

---

## Anti-Patterns to Avoid

- **DO NOT** output `<promise>FEATURE_COMPLETE</promise>` if any verification fails
- **DO NOT** skip running verification commands to save time
- **DO NOT** mark phases complete without running the checks
- **DO NOT** leave broken tests "to fix later"
- **DO NOT** proceed past type errors or lint errors
- **DO NOT** assume tests pass without running them
- **DO NOT** lie about verification results in implementation-state.md

---

## Example Session Flow

```
1. /ralph-loop "implement turbopuffer-vector-search using feature-implementation" --completion-promise "FEATURE_COMPLETE"

2. [Initialize]
   - Read ~/.ai/plans/turbopuffer-vector-search/implementation-guide.md
   - Read implementation-state.md → Current Phase: 1

3. [Implement Phase 1]
   - Read phase-01-foundation/technical-details.md
   - Implement Turbopuffer service
   - Write unit tests

4. [Verification Gate]
   - Run: npm run build → PASS
   - Run: npm run lint → PASS
   - Run: npm run type-check → PASS
   - Run: npm run test → PASS
   - All passed! Update state, advance to Phase 2

5. [Implement Phase 2]
   - Read phase-02-dual-write/technical-details.md
   - Implement dual-write logic

6. [Verification Gate]
   - Run: npm run build → PASS
   - Run: npm run lint → FAIL (unused import)
   - Fix: Remove unused import
   - Re-run: npm run lint → PASS
   - Run: npm run type-check → PASS
   - Run: npm run test → PASS
   - All passed! Update state, advance to Phase 3

... continue until all phases complete ...

N. [Final Verification]
   - All phases complete
   - Run final verification command
   - ALL CHECKS PASSED
   - Output: <promise>FEATURE_COMPLETE</promise>
```

---

## State File Location

- Plan: `~/.ai/plans/{feature}/implementation-guide.md`
- State: `~/.ai/plans/{feature}/implementation-state.md`
- Phase details: `~/.ai/plans/{feature}/phase-{NN}-{name}/`
