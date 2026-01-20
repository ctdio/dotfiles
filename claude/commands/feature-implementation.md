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

1. **Plan is the contract** - The plan's Completion Criteria define "done". Every deliverable is mandatory.
2. **Exhaustive implementation** - Complete EVERY task, EVERY sub-task, EVERY detail. Partial implementation = failure.
3. **Verify before advancing** - Run ALL verification commands before marking phases complete
4. **No broken code** - Never advance with failing tests, lint errors, or type errors
5. **Reflect before claiming done** - Self-verify against criteria before outputting promise
6. **Re-read the plan constantly** - Don't rely on memory. Go back to the source document repeatedly.

---

## Phase: Initialize

**Goal**: Load plan and establish state

**Actions**:
1. Read `~/.ai/plans/{feature}/implementation-guide.md` (or overview.md)
2. Read `~/.ai/plans/{feature}/spec.md` to understand all requirements
3. Check if `~/.ai/plans/{feature}/implementation-state.md` exists
4. **IF STATE FILE DOES NOT EXIST: CREATE IT IMMEDIATELY** (see format below)
5. Identify current phase from state file
6. Create todo list tracking all phases

**CRITICAL: You MUST create implementation-state.md before any implementation work.**
If the file doesn't exist, use the Write tool to create it with all phases and requirements from the plan.

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
**Commit**: {HASH} - feat({feature}): complete phase 1 - {name}

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

**Goal**: Complete EVERY deliverable in the current phase according to the plan

**Actions**:
1. Read ALL phase-specific docs from plan (e.g., `phase-01-foundation/technical-details.md`, `technical-details.md`, any linked files)
2. **Extract and enumerate ALL deliverables/tasks** - create a comprehensive checklist
3. Read files identified in the plan
4. Implement deliverables one by one, checking them off
5. Update todos as you progress
6. Document any deviations in state file

### Exhaustive Implementation Protocol (CRITICAL)

**Before implementing ANYTHING**, extract a complete task list:

1. **Read the ENTIRE phase documentation** - don't skim, read every line
2. **List ALL deliverables** mentioned in:
   - The deliverables section
   - The task breakdown
   - Code examples that need to be implemented
   - Integration points mentioned
   - Tests that need to be written
   - Any "also need to" or "don't forget to" items
3. **Create a todo item for EACH deliverable** using TodoWrite
4. **Cross-reference** the plan multiple times as you implement

**During implementation**:
- After completing each task, re-read that section of the plan to verify you didn't miss sub-tasks
- If the plan says "implement X with features A, B, C" - verify A, B, AND C are all done
- If the plan shows example code, implement ALL of it (not just parts)
- If the plan mentions edge cases, handle ALL of them
- **UPDATE implementation-state.md after EVERY completed task** (see below)

**STATE FILE UPDATES (MANDATORY)**:
Update `implementation-state.md` IMMEDIATELY when:
- You complete a task → mark it ✅ with brief note
- You start a task → mark it 🔄 in_progress
- A test passes → update test status
- You satisfy a spec requirement → update Spec Requirements Status
- You discover a gotcha → add to Gotchas section
- You encounter a blocker → mark task ⛔ with reason

**DO NOT batch updates. Update after EACH task completion.**

**CRITICAL RULES**:
- **COMPLETE EVERY TASK** - partial implementation is not acceptable
- **UPDATE STATE FILE CONTINUOUSLY** - not just at end of phase
- Follow the plan's specified approach
- Match existing codebase patterns
- Write tests for new code
- Do NOT skip to next phase until current phase passes verification
- **Do NOT advance if ANY deliverable is incomplete**

---

## Phase: Completeness Check (Pre-Verification)

**Goal**: Ensure EVERY deliverable is complete before running verification

**This phase is MANDATORY before verification. DO NOT SKIP.**

### Step 1: Re-read the Phase Plan
Go back and read the entire phase documentation again. Don't rely on memory.

### Step 2: Deliverable Audit
For each deliverable/task in the plan:
1. **Find the implementation** - locate the actual code you wrote
2. **Verify completeness** - does it match what the plan specified?
3. **Check sub-items** - if the task has multiple parts, are ALL parts done?
4. **Mark verified** in your todo list

### Step 3: Compare Against Plan Checklist

Ask yourself for EACH item in the plan:
- [ ] Is this implemented?
- [ ] Is it implemented FULLY (not partially)?
- [ ] Does it match the plan's specification?
- [ ] Are there tests for it (if tests were required)?

### Step 4: Fill Gaps

If you find ANY incomplete deliverable:
1. **STOP** - do not proceed to verification
2. Implement the missing item
3. Re-run this completeness check
4. Only proceed when ALL items are verified complete

**BLOCKER**: Do NOT proceed to Verification Gate if ANY deliverable is incomplete or partially implemented.

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

### Step 5: Create Phase Commit (GATES NEXT PHASE)
After ALL verification checks pass, create a commit for the completed phase:

```bash
# Stage all files modified in this phase
git add .

# Create commit with standardized message
git commit -m "feat(<feature>): complete phase N - <phase-name>

- Summary of deliverables completed
- Tests passing: X/X
- Verification: build, lint, type-check, tests all pass"
```

**CRITICAL**:
- DO NOT advance to the next phase without creating this commit
- The commit serves as a checkpoint and proof of verified completion
- Record the commit hash in implementation-state.md

---

## Phase: Advance to Next Phase

**Goal**: Safely transition to the next phase

**Actions**:
1. Confirm current phase verification passed (re-check state file)
2. **Confirm phase commit was created** (check state file for commit hash)
3. Check dependencies for next phase (read plan)
4. Update state file: Current Phase = next phase number
5. Update todos
6. Begin "Implement Current Phase" for next phase

**BLOCKER**: If no commit hash is recorded for the current phase, DO NOT advance. Go back and create the commit first.

---

## Completion Protocol

**When all phases are complete, perform FINAL VERIFICATION**:

### Self-Reflection Checklist

Before outputting `<promise>FEATURE_COMPLETE</promise>`, verify:

**Exhaustiveness Check (CRITICAL)**:
```
[ ] Re-read the ENTIRE implementation-guide.md one final time
[ ] For EACH phase: verify EVERY deliverable listed was implemented
[ ] For EACH deliverable: verify it matches the spec exactly
[ ] No tasks were skipped because they seemed minor or optional
[ ] No partial implementations - everything is 100% complete
```

**Technical Verification**:
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

### Exhaustiveness Violations
- **DO NOT** implement only "the main parts" and skip details
- **DO NOT** skim the plan - read EVERY line
- **DO NOT** assume you know what the plan says from memory - re-read it
- **DO NOT** mark a task complete if it's only partially done
- **DO NOT** skip sub-tasks or "nice to have" items that are in the plan
- **DO NOT** advance phases if ANY deliverable is incomplete
- **DO NOT** interpret "implement X" as "implement the easy parts of X"

### Verification Violations
- **DO NOT** output `<promise>FEATURE_COMPLETE</promise>` if any verification fails
- **DO NOT** skip running verification commands to save time
- **DO NOT** mark phases complete without running the checks
- **DO NOT** leave broken tests "to fix later"
- **DO NOT** proceed past type errors or lint errors
- **DO NOT** assume tests pass without running them
- **DO NOT** lie about verification results in implementation-state.md
- **DO NOT** advance to the next phase without creating a commit for the current phase

### State Tracking Violations
- **DO NOT** skip creating implementation-state.md at the start
- **DO NOT** batch state updates - update after EVERY task
- **DO NOT** wait until end of session to update the state file
- **DO NOT** forget to mark tasks as complete when done
- **DO NOT** forget to update Spec Requirements Status when requirements are satisfied
- **DO NOT** leave the state file stale or outdated
- **DO NOT** rely on TodoWrite alone - implementation-state.md is the persistent record

### Completeness Mindset
**Think of the plan as a legal contract.** Every deliverable listed is a contractual obligation. "Mostly done" is breach of contract. The feature is not complete until EVERY item is implemented EXACTLY as specified (or deviations are explicitly documented with justification).

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
   - All passed! Create commit: feat(turbopuffer): complete phase 1 - foundation
   - Update state with commit hash, advance to Phase 2

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
   - All passed! Create commit: feat(turbopuffer): complete phase 2 - dual-write
   - Update state with commit hash, advance to Phase 3

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
