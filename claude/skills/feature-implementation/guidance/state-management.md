# State Management Guidance

This guide is for the **state-manager** agent. Read this for detailed guidance on managing the implementation state file.

## Core Principles

1. **Accuracy is Critical**: The state file is the source of truth for implementation progress
2. **Preserve History**: Never lose information - update, don't overwrite
3. **Track Everything**: Spec requirements, phases, tests, gotchas, decisions
4. **Enable Resumption**: Future sessions depend on accurate state

---

## State File Location

```
~/.ai/plans/{feature}/implementation-state.md
```

---

## Complete State File Template

```markdown
# Implementation State: {Feature Name}

**Last Updated**: {TODAY'S DATE}
**Current Phase**: phase-{NN}-{name}
**Status**: in_progress | completed | blocked

---

## Spec Requirements Status

Track which requirements from spec.md are satisfied:

### Functional Requirements
- ✅ FR-1: {Name} - Satisfied in Phase 1
- ✅ FR-2: {Name} - Satisfied in Phase 1
- 🔄 FR-3: {Name} - In progress (Phase 2)
- ⏳ FR-4: {Name} - Pending (Phase 3)

### Non-Functional Requirements
- ✅ NFR-1: {Name} - Verified with benchmarks
- 🔄 NFR-2: {Name} - Partially complete
- ⏳ NFR-3: {Name} - Pending

### Constraints
- ✅ C-1: {Name} - Respected throughout
- ✅ C-2: {Name} - Verified

---

## Phase 1: {Phase Name}

**Status**: completed
**Started**: {DATE}
**Completed**: {DATE}
**Commit**: `{HASH}` - feat({feature}): complete phase 1 - {name}
**Attempts**: 1

### Spec Requirements Addressed
- FR-1, FR-2, NFR-1 (partial)

### Tests Written (TDD)

**Unit Tests** ({N} passing):
- ✅ `test_function_happy_path` - Tests normal operation
- ✅ `test_function_edge_case` - Tests boundary conditions
- ✅ `test_error_handling` - Tests error scenarios

**Integration Tests** ({N} passing):
- ✅ `test_api_endpoint` - Tests full request/response cycle

### Pre-Completion Verification

> **ALL items must be checked before marking phase complete**

- [x] All deliverables implemented
- [x] All unit tests written and passing
- [x] All integration tests written and passing
- [x] Type check passes (0 errors)
- [x] Lint check passes (0 errors)
- [x] Build succeeds
- [x] Verification script runs with zero failures

**Verification Output**:
```
✓ type-check: 0 errors
✓ lint: 0 warnings
✓ build: completed in 4.2s
✓ test: 42 passed, 0 failed
```

### Completed Tasks
- ✅ {Task 1} - {Brief note about implementation}
- ✅ {Task 2} - {Brief note}
- ✅ {Task 3} - {Brief note}

### Files Created
- `src/services/example.ts` - Main service class
- `src/services/__tests__/example.test.ts` **(8 tests)**

### Files Modified
- `src/services/index.ts` - Added export for new service

### Deviations from Plan
- {Describe any changes from original plan and why}

### Gotchas Discovered
- {Document any surprises or challenges encountered}

### Notes for Future Phases
- {Anything relevant for upcoming phases}

---

## Phase 2: {Phase Name}

**Status**: in_progress
**Started**: {DATE}
**Commit**: ⏳ Pending (create after verification passes)
**Attempts**: 2

### Spec Requirements to Address
- FR-3, FR-4 (partial), NFR-2

### Tests Written (TDD)

**Unit Tests**:
- ✅ `test_new_function` - Written, passing
- 🔴 `test_component_behavior` - Written, failing (implementing now)
- ⏳ `test_edge_case` - Not yet written

**Integration Tests**:
- ⏳ `test_flow_complete` - Not yet written

### Pre-Completion Verification

> **ALL items must be checked before marking phase complete**

- [x] All deliverables implemented
- [ ] All unit tests written and passing
- [ ] All integration tests written and passing
- [ ] Type check passes (0 errors)
- [ ] Lint check passes (0 errors)
- [ ] Build succeeds
- [ ] Verification script runs with zero failures

### Completed Tasks
- ✅ {Task 1} - {Brief note}

### In Progress
- 🔄 {Task 2} - {What's being worked on now}

### Pending Tasks
- ⏳ {Task 3} - {What's next}
- ⏳ {Task 4} - {What's next}

### Blocked Tasks
- ⛔ {Task N} - {Why blocked and what's needed to unblock}

### Issues (Current Attempt)
If verification failed, document what went wrong:
- {Specific issue 1 with location}
- {Specific issue 2 with location}

### Current Notes
- {Relevant observations or context}

---

## Phase 3: {Phase Name}

**Status**: pending
**Dependencies**: Phase 2 must be completed

### Spec Requirements to Address
- FR-4 (completion), NFR-3

### Planned Tasks
- [ ] {Task 1}
- [ ] {Task 2}
- [ ] {Task 3}

---

## Overall Progress

**Phases Complete**: 1 / 4
**Spec Requirements Satisfied**: 3 / 8
**Current Focus**: Phase 2 - {Phase Name}
**Next Milestone**: Complete Phase 2

---

## Implementation Metrics

**Files Created**: 8
**Files Modified**: 5
**Tests Added**: 42
**Total Test Coverage**: 85%

---

## Key Decisions During Implementation

### Decision 1: {Decision Name}
**Date**: {Date}
**Context**: {Why this decision was needed}
**Decision**: {What was decided}
**Rationale**: {Why this was chosen}
**Impact**: {What changed as a result}

---

## Challenges & Resolutions

### Challenge 1: {Challenge Name}
**Issue**: {What the problem was}
**Solution**: {How it was resolved}
**Learned**: {What we learned for future}

---

## Quick Status Summary

Use this for rapid context gathering:

- **What's Done**: {One sentence summary}
- **What's In Progress**: {One sentence summary}
- **What's Next**: {One sentence summary}
- **Blockers**: {One sentence or "None"}
```

---

## Status Indicators

Use these consistently:

| Symbol | Meaning |
|--------|---------|
| ✅ | Complete/Passing |
| 🔄 | In progress |
| ⏳ | Pending/Not started |
| 🔴 | Failing (for tests) |
| ⛔ | Blocked |

---

## INITIALIZE Operation

When creating a new state file:

### What to Read

1. `~/.ai/plans/{feature}/overview.md` - Get feature name
2. `~/.ai/plans/{feature}/spec.md` - Get ALL requirements (FR, NFR, Constraints)
3. `~/.ai/plans/{feature}/implementation-guide.md` - Get phase list
4. Each `phase-NN-{name}/files-to-modify.md` - Get planned tasks

### What to Create

1. Create `~/.ai/plans/{feature}/implementation-state.md`
2. Populate Spec Requirements Status from spec.md (all ⏳ Pending)
3. Create sections for each phase with planned tasks
4. Mark Phase 1 as `in_progress`
5. Set Overall Progress to 0 / {total phases}

### Output

Report back:
- State file created at {path}
- {N} spec requirements tracked
- {N} phases initialized
- Phase 1 marked as in_progress

---

## UPDATE Operation (PASSED)

When a phase verification passes:

### Input You'll Receive

- Phase number and name
- Verification results (technical checks output)
- Files modified (list with descriptions)
- Deliverables completed (list)
- Tests written (list with status)
- Spec requirements satisfied (list)
- Deviations (if any)

### What to Update

1. **Current Phase Section**:
   - Status → `completed`
   - Add Completed date (today)
   - Commit → Will be added by orchestrator after you update
   - Fill in Verification Output block
   - Check all Pre-Completion Verification boxes
   - Fill in Completed Tasks
   - Fill in Files Created/Modified
   - Fill in Tests Written with counts

2. **Spec Requirements Status** (at top):
   - Update completed requirements from ⏳/🔄 to ✅
   - Note which phase satisfied them

3. **Next Phase Section**:
   - Status → `in_progress`
   - Started → today's date

4. **Overall Progress**:
   - Increment Phases Complete
   - Update Spec Requirements Satisfied count
   - Update Current Focus to next phase

5. **Quick Status Summary**:
   - Update all fields

---

## UPDATE Operation (FAILED)

When a phase verification fails:

### Input You'll Receive

- Phase number and name
- Attempt number (e.g., 2 of 3)
- Verification output (what failed)
- Issues found (list with locations)
- Verifier summary

### What to Update

1. **Current Phase Section**:
   - Keep Status as `in_progress`
   - Update Attempts count
   - Add/update "Issues (Current Attempt)" section
   - Add Verification Output showing failures

2. **DO NOT**:
   - Mark phase as completed
   - Advance to next phase
   - Update Spec Requirements Status

3. **Quick Status Summary**:
   - Update to reflect current issues

---

## Critical Rules

### Never Lose Information

When updating, PRESERVE:
- Previous phases' complete information
- Gotchas discovered
- Decisions made
- Notes for future phases
- Challenges & resolutions

### Be Accurate

- Test counts must match actual results
- File lists must reflect what was actually created/modified
- Dates must be accurate (use today's date for new entries)
- Spec requirement status must match verification results

### Copy from Source

- Copy spec requirements EXACTLY from spec.md
- Copy phase names from implementation-guide.md
- Don't paraphrase or summarize requirements

### Include Test Information

Always note:
- Test file paths
- Number of tests in each file
- Test status (passing/failing)
- Coverage if available

---

## Anti-Patterns to Avoid

❌ **Don't**: Lose existing content when updating
✅ **Do**: Preserve all historical information

❌ **Don't**: Guess at test counts or file changes
✅ **Do**: Use exact information from the provided data

❌ **Don't**: Mark requirements satisfied without evidence
✅ **Do**: Only mark ✅ when verification confirms completion

❌ **Don't**: Skip sections or leave placeholders
✅ **Do**: Fill in all relevant sections with real data

❌ **Don't**: Use inconsistent status indicators
✅ **Do**: Use the standard symbols (✅ 🔄 ⏳ 🔴 ⛔)

---

## Example Updates

### After Phase 1 PASSES

Before:
```markdown
## Phase 1: Foundation
**Status**: in_progress
**Started**: 2024-01-15
```

After:
```markdown
## Phase 1: Foundation
**Status**: completed
**Started**: 2024-01-15
**Completed**: 2024-01-15
**Commit**: ⏳ (orchestrator will add)
**Attempts**: 1

### Tests Written (TDD)
**Unit Tests** (12 passing):
- ✅ `test_service_init` - Tests initialization
...

### Pre-Completion Verification
- [x] All deliverables implemented
- [x] All unit tests written and passing
...

**Verification Output**:
```
✓ type-check: 0 errors
✓ lint: 0 warnings
✓ test: 12 passed, 0 failed
```

### Completed Tasks
- ✅ Create TurbopufferService - Following PineconeService pattern
...
```

### After Phase 2 FAILS (Attempt 1)

```markdown
## Phase 2: Dual-Write
**Status**: in_progress
**Started**: 2024-01-15
**Attempts**: 1

### Issues (Current Attempt)
- Missing error handling in dual-write logic (src/services/dual-write.ts:45)
- Integration test failing: timeout not handled

### Verification Output
```
✓ type-check: 0 errors
✓ lint: 0 warnings
✗ test: 8 passed, 2 failed
  - test_dual_write_error: Expected retry, got exception
  - test_timeout_handling: Timeout not caught
```
```
