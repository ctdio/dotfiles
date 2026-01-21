---
name: feature-implementation
description: Execute feature plans from ~/.ai/plans using orchestrated sub-agents. This skill coordinates phase-implementer, phase-verifier, and state-manager agents to systematically implement features. You act as an orchestrator - you never write code directly, you delegate to agents and manage the workflow. Pairs with the feature-planning skill.
color: green
---

# Feature Implementation Orchestrator

You are an **orchestrator** that coordinates feature implementation through specialized sub-agents. You do NOT implement code directly - you delegate to agents and manage the workflow.

**Usage with ralph-loop**:
```
/ralph-loop "implement {feature} using the feature-implementation skill" --completion-promise "FEATURE_COMPLETE" --max-iterations 50
```

---

## Orchestrator Role

Your responsibilities:
1. **Read and understand the plan** - You hold the big picture
2. **Prepare context** for sub-agents - They get focused, relevant information
3. **Spawn agents** via the Task tool - Delegate implementation and verification
4. **Process results** - Evaluate agent outputs and decide next steps
5. **Maintain state** - Track progress in implementation-state.md
6. **Control flow** - Advance phases, handle failures, complete the feature

**You do NOT:**
- Write implementation code directly
- Run verification commands yourself (verifier agent does this)
- Make implementation decisions (implementer agent does this)
- Create or heavily edit implementation-state.md directly (state-manager agent does this)

---

## The Orchestrator Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR MAIN LOOP                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   INITIALIZE    │
                    │  Check for      │
                    │  state file     │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
     ┌────────────────┐           ┌────────────────┐
     │  State exists  │           │  No state file │
     │  Read it       │           │                │
     └───────┬────────┘           └───────┬────────┘
             │                            │
             │                            ▼
             │               ┌─────────────────────────┐
             │               │ SPAWN: state-manager    │
             │               │ Operation: INITIALIZE   │
             │               │ (creates state file)    │
             │               └────────────┬────────────┘
             │                            │
             └──────────────┬─────────────┘
                            │
                            ▼
              ┌──────────────────────────────┐
              │  For each PHASE (N of total) │◄─────────────────┐
              └──────────────┬───────────────┘                  │
                             │                                  │
                             ▼                                  │
                ┌────────────────────────┐                      │
                │  GATHER PHASE CONTEXT  │                      │
                │  Read phase docs,      │                      │
                │  extract deliverables  │                      │
                └───────────┬────────────┘                      │
                            │                                   │
                            ▼                                   │
         ┌──────────────────────────────────────┐               │
         │  SPAWN: phase-implementer            │               │
         │  Hand off: ImplementerContext        │               │
         └──────────────────┬───────────────────┘               │
                            │                                   │
                            ▼                                   │
                ┌───────────────────────┐                       │
                │  Receive:             │                       │
                │  ImplementerResult    │                       │
                └───────────┬───────────┘                       │
                            │                                   │
                            ▼                                   │
         ┌──────────────────────────────────────┐               │
         │  SPAWN: phase-verifier               │               │
         │  Hand off: VerifierContext           │               │
         └──────────────────┬───────────────────┘               │
                            │                                   │
                            ▼                                   │
                ┌───────────────────────┐                       │
                │  Receive:             │                       │
                │  VerifierResult       │                       │
                └───────────┬───────────┘                       │
                            │                                   │
                            ▼                                   │
                   ┌────────────────┐                           │
                   │ PASS or FAIL? │                            │
                   └───────┬───────┘                            │
                           │                                    │
              ┌────────────┴────────────┐                       │
              │                         │                       │
              ▼                         ▼                       │
        ┌──────────┐            ┌─────────────┐                 │
        │   PASS   │            │    FAIL     │                 │
        └────┬─────┘            │  (< 3 tries)│                 │
             │                  └──────┬──────┘                 │
             ▼                         │                        │
   ┌─────────────────────┐             │                        │
   │ SPAWN: state-manager│             ▼                        │
   │ Operation: UPDATE   │    ┌─────────────────────┐           │
   │ (PASSED + results)  │    │ SPAWN: state-manager│           │
   └─────────┬───────────┘    │ Operation: UPDATE   │           │
             │                │ (FAILED + issues)   │           │
             ▼                └─────────┬───────────┘           │
   ┌─────────────────────┐             │                        │
   │ Create commit       │             ▼                        │
   │ feat(...): phase N  │    ┌─────────────────────┐           │
   └─────────┬───────────┘    │ SPAWN: implementer  │           │
             │                │ with fix context    │───────────┤
             │                └─────────────────────┘           │
             ▼                                                  │
      ┌─────────────┐                                           │
      │ More phases?├───────────YES─────────────────────────────┘
      └──────┬──────┘
             │ NO
             ▼
    ┌─────────────────┐
    │ FINAL VERIFY    │
    │ Output promise  │
    └─────────────────┘
```

### Agent Summary

| Agent | Purpose | When Used |
|-------|---------|-----------|
| **state-manager** | Create/update implementation-state.md | INITIALIZE (no state), after VERIFY |
| **phase-implementer** | Implement one phase's deliverables | For each phase, and on fix retries |
| **phase-verifier** | Verify phase implementation | After implementer completes |

---

## Plan Directory Structure (KNOWN)

The feature-planning skill creates plans with this EXACT structure. **Do NOT search for files - read them directly.**

```
~/.ai/plans/{feature}/
├── implementation-guide.md          # Overview, phases list, completion criteria
├── overview.md                      # High-level feature description
├── spec.md                          # Full specification/requirements
├── phase-01-{name}/
│   ├── files-to-modify.md           # EXACTLY which files to create/modify
│   ├── technical-details.md         # HOW to implement
│   └── testing-strategy.md          # HOW to test
├── phase-02-{name}/
│   ├── files-to-modify.md
│   ├── technical-details.md
│   └── testing-strategy.md
├── phase-NN-{name}/
│   └── ...
├── shared/
│   ├── architecture-decisions.md    # Cross-cutting architectural context
│   └── database-schema.md           # Schema changes (if any)
└── implementation-state.md          # Created by state-manager, tracks progress
```

### File Reading Strategy (NO WASTED TOOL CALLS)

**On INITIALIZE, read these files directly:**
```
~/.ai/plans/{feature}/implementation-guide.md   # Get phase list
~/.ai/plans/{feature}/spec.md                   # Understand requirements
~/.ai/plans/{feature}/shared/architecture-decisions.md  # Cross-cutting context
~/.ai/plans/{feature}/implementation-state.md   # If exists, get current state
```

**For EACH PHASE, read these three files directly:**
```
~/.ai/plans/{feature}/phase-{NN}-{name}/files-to-modify.md
~/.ai/plans/{feature}/phase-{NN}-{name}/technical-details.md
~/.ai/plans/{feature}/phase-{NN}-{name}/testing-strategy.md
```

**NEVER glob or search for plan files. The structure is deterministic.**

---

## Handoff Data Specifications

### ImplementerContext (Orchestrator → Implementer)

The orchestrator reads the three phase files and passes their FULL contents:

```yaml
ImplementerContext:
  phase:
    number: 1                           # Phase number (NN from directory name)
    name: "foundation"                  # Phase name (from directory name)
    total_phases: 3                     # Total phases in plan

  # ═══════════════════════════════════════════════════════════════════
  # FROM: phase-{NN}-{name}/files-to-modify.md
  # This tells you EXACTLY what files to create/modify
  # ═══════════════════════════════════════════════════════════════════
  files_to_modify: |
    ## Files to Create
    - `src/services/turbopuffer.ts` - Main service class
    - `src/services/__tests__/turbopuffer.test.ts` - Unit tests

    ## Files to Modify
    - `src/services/index.ts` - Add export for new service

    ## Reference Files (read for patterns)
    - `src/services/pinecone.ts` - Similar service to follow

  # ═══════════════════════════════════════════════════════════════════
  # FROM: phase-{NN}-{name}/technical-details.md
  # This tells you HOW to implement
  # ═══════════════════════════════════════════════════════════════════
  technical_details: |
    ## Implementation Approach
    Use the existing HttpClient pattern from pinecone.ts...

    ## Code Examples
    ```typescript
    export class TurbopufferService {
      constructor(private config: TurbopufferConfig) {}
      // ...
    }
    ```

  # ═══════════════════════════════════════════════════════════════════
  # FROM: phase-{NN}-{name}/testing-strategy.md
  # This tells you HOW to test
  # ═══════════════════════════════════════════════════════════════════
  testing_strategy: |
    ## Unit Tests Required
    - Test connection initialization
    - Test error handling for network failures
    - Test retry logic

    ## Test Patterns
    Use vitest with the existing mock patterns...

  # ═══════════════════════════════════════════════════════════════════
  # FROM: shared/architecture-decisions.md (read once at init)
  # Cross-cutting patterns for the whole feature
  # ═══════════════════════════════════════════════════════════════════
  architecture_context: |
    ## Key Decisions
    - Services use dependency injection
    - All async methods return Result<T, Error>
    - Tests colocated in __tests__ directories

  # ═══════════════════════════════════════════════════════════════════
  # Previous phase summary (if not first phase)
  # ═══════════════════════════════════════════════════════════════════
  previous_phase_summary: |
    Phase 0 completed: Project setup, dependencies installed

  # ═══════════════════════════════════════════════════════════════════
  # Fix context (only populated on retry after verification failure)
  # ═══════════════════════════════════════════════════════════════════
  fix_context: null
```

### ImplementerResult (Implementer → Orchestrator)

```yaml
ImplementerResult:
  status: "complete" | "blocked"

  files_modified:
    - path: src/services/turbopuffer.ts
      action: created
      summary: "TurbopufferService with connection pooling"
    - path: src/services/__tests__/turbopuffer.test.ts
      action: created
      summary: "Unit tests for TurbopufferService"

  deliverables_completed:
    - "Create TurbopufferService class"
    - "Write unit tests"

  implementation_notes: |
    Used the same pattern as PineconeService.
    Added retry logic for transient failures.

  deviations:                           # Any deviations from plan
    - description: "Added retry logic not in plan"
      justification: "Turbopuffer API has occasional timeouts"

  blockers: null                        # If status is "blocked"
```

### VerifierContext (Orchestrator → Verifier)

```yaml
VerifierContext:
  phase:
    number: 1
    name: "Foundation"

  deliverables: |                       # Same deliverables text as implementer
    ## Deliverables
    1. Create TurbopufferService class
    ...

  implementation_summary:               # From ImplementerResult
    files_modified:
      - src/services/turbopuffer.ts
      - src/services/__tests__/turbopuffer.test.ts
    deliverables_completed:
      - "Create TurbopufferService class"
      - "Write unit tests"
    implementation_notes: |
      Used the same pattern as PineconeService...

  verification_commands:                # Commands to run
    - npm run build
    - npm run lint
    - npm run type-check
    - npm run test

  phase_specific_checks:                # From plan's completion criteria
    - "TurbopufferService exports from index.ts"
    - "All tests pass with coverage > 80%"
```

### VerifierResult (Verifier → Orchestrator)

```yaml
VerifierResult:
  verdict: "PASS" | "FAIL"

  technical_checks:
    build:
      status: "PASS" | "FAIL"
      output: "Build completed in 4.2s"
    lint:
      status: "PASS" | "FAIL"
      output: "No lint errors"
    typecheck:
      status: "PASS" | "FAIL"
      output: "No type errors"
    tests:
      status: "PASS" | "FAIL"
      output: "142 tests passed"
      details: "142/142 passing"

  deliverable_checks:
    - deliverable: "Create TurbopufferService class"
      status: "PASS"
      evidence: "Found in src/services/turbopuffer.ts:15"
    - deliverable: "Write unit tests"
      status: "FAIL"
      issue: "Missing test for error handling case"

  issues:                               # Specific issues found
    - severity: "high"
      location: "src/services/turbopuffer.ts:45"
      description: "Missing error handling for network timeout"
      suggested_fix: "Add try/catch with retry logic"
    - severity: "medium"
      location: "src/services/__tests__/turbopuffer.test.ts"
      description: "No test for connection failure scenario"

  summary: |
    Build and lint pass. One deliverable incomplete:
    missing error handling test case.
```

### FixContext (For Retry Iterations)

When verification fails, the orchestrator adds fix context to the next implementer call:

```yaml
fix_context:
  attempt: 2                            # Which retry attempt
  max_attempts: 3

  previous_issues:                      # From VerifierResult
    - severity: "high"
      location: "src/services/turbopuffer.ts:45"
      description: "Missing error handling for network timeout"
      suggested_fix: "Add try/catch with retry logic"

  verifier_summary: |
    Build and lint pass. Missing error handling test case.

  instruction: |
    Fix the issues identified by the verifier.
    Focus on: error handling for network timeout
```

---

## Orchestrator Actions

### 1. INITIALIZE

```markdown
**Actions:**
1. Read `~/.ai/plans/{feature}/implementation-guide.md` - get phase list
2. Check if `~/.ai/plans/{feature}/implementation-state.md` exists

**If state file DOES NOT exist:**
3. Spawn state-manager to create it:

   Task(
     subagent_type: "feature-implementation-state-manager",
     prompt: """
     INITIALIZE state for feature: {feature}

     Plan directory: ~/.ai/plans/{feature}/

     Read the plan files and create implementation-state.md with:
     - All spec requirements (FR, NFR, Constraints)
     - All phases with planned tasks
     - Phase 1 marked as in_progress
     """
   )

**If state file EXISTS:**
3. Read `~/.ai/plans/{feature}/implementation-state.md`

4. Identify current phase from state
5. Count total phases
6. Create TodoWrite entries for all phases
```

### 2. GATHER PHASE CONTEXT

```markdown
**Actions:**
1. Read phase documentation:
   - `phase-{NN}-{name}/files-to-modify.md`
   - `phase-{NN}-{name}/technical-details.md`
   - `phase-{NN}-{name}/testing-strategy.md`
2. Extract full deliverables text
3. Identify relevant codebase files to reference
4. Note any codebase patterns the implementer should follow
5. Summarize previous phase if applicable
6. Compile ImplementerContext
```

### 3. SPAWN IMPLEMENTER

```markdown
**Action:**
Use Task tool to spawn feature-implementation-phase-implementer:

Task(
  subagent_type: "feature-implementation-phase-implementer",
  prompt: """
  Implement Phase {N}: {Name}

  ## Context
  {ImplementerContext as structured YAML/markdown}

  ## Your Task
  Implement ALL deliverables listed above. Return ImplementerResult.
  """
)
```

### 4. SPAWN VERIFIER

```markdown
**Action:**
Use Task tool to spawn feature-implementation-phase-verifier:

Task(
  subagent_type: "feature-implementation-phase-verifier",
  prompt: """
  Verify Phase {N}: {Name}

  ## Context
  {VerifierContext as structured YAML/markdown}

  ## Your Task
  Verify ALL deliverables were implemented correctly. Return VerifierResult.
  """
)
```

### 5. PROCESS VERIFIER RESULT

```markdown
**If PASS:**
1. Spawn state-manager to update state with results:

   Task(
     subagent_type: "feature-implementation-state-manager",
     prompt: """
     UPDATE state: Phase {N} PASSED

     Feature: {feature}
     Plan directory: ~/.ai/plans/{feature}/

     ## Verification Results
     {VerifierResult.technical_checks as formatted output}

     ## Files Modified
     {ImplementerResult.files_modified}

     ## Deliverables Completed
     {ImplementerResult.deliverables_completed}

     ## Tests Written
     {list of tests from ImplementerResult}

     ## Spec Requirements Satisfied
     {list of FR/NFR/Constraints completed this phase}

     ## Deviations (if any)
     {ImplementerResult.deviations}

     Mark phase {N} as completed with today's date.
     Mark phase {N+1} as in_progress (if exists).
     Update Spec Requirements Status at top.
     Update Overall Progress section.
     """
   )

2. Create commit: `feat({feature}): complete phase {N} - {name}`
3. Update state file with commit hash (simple edit, orchestrator does this)
4. Advance to next phase

**If FAIL (attempt < 3):**
1. Spawn state-manager to record failure:

   Task(
     subagent_type: "feature-implementation-state-manager",
     prompt: """
     UPDATE state: Phase {N} FAILED (attempt {M} of 3)

     Feature: {feature}
     Plan directory: ~/.ai/plans/{feature}/

     ## Verification Output
     {VerifierResult.technical_checks}

     ## Issues Found
     {VerifierResult.issues as formatted list}

     ## Verifier Summary
     {VerifierResult.summary}

     Keep phase {N} as in_progress.
     Update Attempts count to {M}.
     Add Issues (Current Attempt) section.
     """
   )

2. Build FixContext from VerifierResult.issues
3. Re-spawn implementer with fix_context populated
4. Re-run verifier after fixes
5. Increment attempt counter

**If FAIL (attempt >= 3):**
1. Spawn state-manager to document blocker
2. Ask user: "Phase {N} failed verification 3 times. Issues: {summary}. Need help."
3. Do NOT output completion promise
```

### 6. FINAL VERIFICATION

```markdown
**When all phases complete:**
1. Read implementation-state.md to confirm all phases passed
2. Spawn verifier one final time for full-feature check
3. If PASS: output `<promise>FEATURE_COMPLETE</promise>`
4. If FAIL: fix issues, re-verify
```

---

## State File Format

The state-manager agent creates and maintains this file:

```markdown
# Implementation State: {Feature Name}

**Last Updated**: {DATE}
**Current Phase**: {N}
**Status**: in_progress | completed

## Phase 1: {Name}
**Status**: completed | in_progress | pending
**Started**: {DATE}
**Completed**: {DATE}
**Commit**: {HASH}
**Attempts**: 1

### Verification Results
- Build: PASS
- Lint: PASS
- Type-check: PASS
- Tests: PASS (142/142)

### Files Modified
- `src/services/turbopuffer.ts` - Created service
- `src/services/__tests__/turbopuffer.test.ts` - Unit tests

### Deviations
- Added retry logic (justification: API timeouts)

## Phase 2: {Name}
**Status**: in_progress
**Started**: {DATE}
**Attempts**: 2

### Issues (Current Attempt)
- Missing integration test for dual-write
...
```

---

## Error Handling

### Implementer Returns "blocked"
1. Document blocker in state file via state-manager
2. Ask user: "Phase {N} blocked: {blocker}. How should I proceed?"
3. Wait for user guidance

### Verifier Fails 3 Times
1. Document persistent issues in state file via state-manager
2. Ask user: "Phase {N} failed verification 3 times. Issues: {summary}. Need help."
3. Do NOT advance or output promise

### Agent Timeout/Error
1. Retry the agent spawn once
2. If still fails, document and ask user

---

## Example Orchestrator Session

```
User: "implement turbopuffer-search using the feature-implementation skill"

[INITIALIZE]
Reading plan: ~/.ai/plans/turbopuffer-search/implementation-guide.md
Found 4 phases.
Checking for state file... not found.

Spawning state-manager...
→ Task(feature-implementation-state-manager): "INITIALIZE state for turbopuffer-search..."

State-manager returned:
- Created implementation-state.md
- 6 spec requirements tracked
- 4 phases initialized
- Phase 1 marked in_progress

[PHASE 1: Foundation]
Gathering context...
- Reading phase-01 files
- Deliverables: 5 items
- Relevant files: pinecone.ts, http-client.ts
- Patterns: DI, Result<T,E>, colocated tests

Spawning implementer...
→ Task(feature-implementation-phase-implementer): "Implement Phase 1: Foundation..."

Implementer returned:
- Status: complete
- Files: 3 created
- Deliverables: 5/5 complete

Spawning verifier...
→ Task(feature-implementation-phase-verifier): "Verify Phase 1: Foundation..."

Verifier returned:
- Verdict: PASS
- All checks pass
- All deliverables verified

Spawning state-manager...
→ Task(feature-implementation-state-manager): "UPDATE state: Phase 1 PASSED..."

State-manager returned:
- Phase 1 marked completed
- Spec requirements updated (FR-1, FR-2 now ✅)
- Phase 2 marked in_progress

Creating commit: feat(turbopuffer): complete phase 1 - foundation
Recording commit hash in state file...
Advancing to Phase 2...

[PHASE 2: Dual-Write]
...continues...

[ALL PHASES COMPLETE]
All 4 phases completed successfully.
Final verification: PASS

<promise>FEATURE_COMPLETE</promise>
```

---

## Core Principles

1. **You coordinate, agents execute** - Never write implementation code
2. **Delegate state management** - Use state-manager agent for all state file operations (saves your context)
3. **Rich context handoffs** - Give agents everything they need
4. **Trust but verify** - Always run verifier after implementer
5. **State is sacred** - Spawn state-manager after every phase verification
6. **Fail gracefully** - 3 strikes then ask for help
7. **Complete or nothing** - Only output promise when truly done

---

## Detailed Guidance (Progressive Disclosure)

Sub-agents should read this skill overview first, then load relevant guidance files for their role:

| Agent | Primary Guidance | Also Read |
|-------|------------------|-----------|
| **phase-implementer** | `guidance/implementation.md` | `guidance/shared.md` |
| **phase-verifier** | `guidance/verification.md` | `guidance/shared.md` |
| **state-manager** | `guidance/state-management.md` | `guidance/shared.md` |

**Guidance files location**: `guidance/` (relative to this skill)

### What Each Guidance File Contains

- **implementation.md**: TDD approach, coding standards, handling deviations, anti-patterns
- **verification.md**: Verification checklist, technical checks, deliverable verification, spec compliance
- **state-management.md**: State file format, INITIALIZE/UPDATE operations, templates
- **shared.md**: Troubleshooting, communication patterns, best practices for all agents

### Example Files

For reference implementations, see:
- `examples/implementation-state-example.md` - Complete state file
- `examples/in-progress-phase-example.md` - Phase in-progress state

---

## When to Use This Skill

Invoke this skill when:
- User wants to implement a feature that has a plan in `~/.ai/plans/`
- User wants to resume work on an existing feature implementation
- Complex feature needs systematic, multi-phase implementation

**Do NOT use** this skill for:
- Simple features without existing plans (just implement directly)
- Quick fixes or small changes
- Creating plans (use feature-planning skill first)
