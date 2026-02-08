---
name: ctdio-feature-planning
description: Use this skill to create structured, comprehensive plans for complex features in ~/.ai/plans. This skill teaches how to use progressive disclosure, phase-based implementation strategies, and organized documentation that helps agents gather context quickly. Invoke manually for large features that need detailed planning and multi-PR implementation strategies.
color: blue
---

You are an expert technical architect specializing in breaking down complex software features into manageable, well-documented implementation plans.

**CRITICAL: This is a PLANNING-ONLY skill. You produce plan documents. You do NOT write implementation code, create source files, modify the codebase, or begin any implementation work. Your deliverable is a complete plan in `~/.ai/plans/` — nothing more. Implementation happens later via the `ctdio-feature-implementation` skill.**

# Feature Planning Skill

## Purpose

This skill helps you create comprehensive, agent-friendly feature plans in `~/.ai/plans/` using progressive disclosure principles. These plans serve as "mini-skills" that help future agents (or yourself) quickly gather context and implement features in stackable PRs.

## Core Principles

1. **Progressive Disclosure**: Start with high-level overview, drill down only when needed
2. **Phase-Based Implementation**: Break features into stackable PRs that build on each other
3. **Agent-Friendly Documentation**: Structure content for quick navigation and context gathering
4. **Context Preservation**: Document decisions, gotchas, and rationale for future reference

## Directory Structure (CRITICAL - EXACT FORMAT REQUIRED)

The ctdio-feature-implementation orchestrator expects this **EXACT** structure. Creating files with different names or locations will waste tool calls during implementation.

```
~/.ai/plans/{feature-name}/
├── overview.md                       # High-level feature summary (START HERE)
├── spec.md                           # REQUIREMENTS - Must be met for completion
├── implementation-guide.md           # Phased rollout strategy
├── phase-01-{name}/
│   ├── files-to-modify.md            # EXACTLY which files to create/modify
│   ├── technical-details.md          # HOW to implement
│   ├── testing-strategy.md           # HOW to test
│   └── verification-harness.md       # OPTIONAL: custom verification tests
├── phase-02-{name}/
│   ├── files-to-modify.md
│   ├── technical-details.md
│   ├── testing-strategy.md
│   └── verification-harness.md       # OPTIONAL
├── phase-NN-{name}/
│   └── ...
└── shared/
    ├── architecture-decisions.md     # Cross-cutting architectural context
    └── database-schema.md            # Schema changes (if any)
```

### MANDATORY FILES PER PHASE

Each `phase-NN-{name}/` directory **MUST** contain exactly these three files:

| File                   | Purpose                                                   | Read By Implementer         |
| ---------------------- | --------------------------------------------------------- | --------------------------- |
| `files-to-modify.md`   | Lists EXACTLY which files to create, modify, or reference | First - to understand scope |
| `technical-details.md` | HOW to implement - code patterns, architecture            | Second - for implementation |
| `testing-strategy.md`  | HOW to test - test cases, mocks, verification             | Third - for testing         |

### OPTIONAL FILES PER PHASE

| File                      | Purpose                                                      | When to Create                                          |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------------- |
| `verification-harness.md` | Custom verification tests (eval scripts, API smoke, browser) | Phases with API endpoints, UI changes, complex behavior |

**Note:** `verification-harness.md` triggers a tester agent during implementation. If this file does not exist for a phase, no tester is spawned. This is fully backward compatible — don't create it unless the phase truly benefits from custom behavioral verification beyond standard tests.

### FILE NAMING RULES

- Phase directories: `phase-{NN}-{kebab-case-name}` (e.g., `phase-01-foundation`)
- All files use exact names above - NO variations like `context-notes.md` or `api-contracts.md`
- Feature name directory: kebab-case (e.g., `salesforce-activity-email-analysis`)

**DO NOT** create files with different names. The implementer reads these paths directly without searching.

## Document Templates

### 1. Overview.md Template

The overview is the **entry point** - keep it concise and high-level.

```markdown
# [Feature Name] - Overview

## Problem Statement

[2-3 sentences describing the problem this feature solves]

## Solution Summary

[3-5 sentences describing the high-level approach]

## Impact

**Users Affected**: [who benefits]
**Systems Affected**: [which parts of the codebase]
**Estimated Complexity**: [straightforward/moderate/complex]

## Implementation Phases

Brief list of phases (details in implementation-guide.md):

1. **Phase 1: Foundation** - [one sentence summary]
2. **Phase 2: Core Features** - [one sentence summary]
3. **Phase 3: Polish** - [one sentence summary]

## Key Technical Decisions

- [Decision 1 with brief rationale]
- [Decision 2 with brief rationale]
- [Decision 3 with brief rationale]

## Success Criteria

**Functional:**

- [Criterion 1]
- [Criterion 2]

**Performance:**

- [Metric 1]
- [Metric 2]

**Quality:**

- [Criterion 1]
- [Criterion 2]

## Next Steps

1. Read `spec.md` for requirements that MUST be met
2. Read `implementation-guide.md` for phased approach
3. Start with `phase-01-foundation/` when ready to implement
```

### 2. Spec.md Template

The spec defines **requirements that MUST be met** for the feature to be considered complete. This is the authoritative source of truth for what the feature must accomplish.

```markdown
# [Feature Name] - Specification

> **This document defines the requirements that MUST be met for this feature to be complete.**
> Implementation agents should reference this spec continuously and verify all requirements are satisfied.

## Functional Requirements

These requirements define WHAT the feature must do. Each requirement is a verifiable condition.

### FR-1: [Requirement Name]

**Description**: [Clear, unambiguous description of what must be true]

**Acceptance Criteria**:

- [ ] [Specific, testable condition 1]
- [ ] [Specific, testable condition 2]
- [ ] [Specific, testable condition 3]

**Verification**: [How to verify this requirement is met - test command, manual check, etc.]

---

### FR-2: [Requirement Name]

**Description**: [Clear description]

**Acceptance Criteria**:

- [ ] [Condition 1]
- [ ] [Condition 2]

**Verification**: [How to verify]

---

### FR-3: [Requirement Name]

[Continue pattern for all functional requirements]

---

## Non-Functional Requirements

These requirements define HOW the feature must behave (performance, security, etc.).

### NFR-1: Performance

**Description**: [Performance expectations]

**Acceptance Criteria**:

- [ ] [Response time < X ms for Y operation]
- [ ] [Memory usage < X MB under Y load]
- [ ] [Throughput > X requests/second]

**Verification**: [How to measure - benchmarks, profiling, load tests]

---

### NFR-2: Security

**Description**: [Security requirements]

**Acceptance Criteria**:

- [ ] [Input validation for X]
- [ ] [Authentication required for Y]
- [ ] [Authorization checks for Z]

**Verification**: [Security tests, audits, etc.]

---

### NFR-3: Error Handling

**Description**: [How errors must be handled]

**Acceptance Criteria**:

- [ ] [Graceful degradation for X failure]
- [ ] [Error messages for Y are user-friendly]
- [ ] [All errors are logged with context]

**Verification**: [Error scenario tests]

---

### NFR-4: Compatibility

**Description**: [Compatibility requirements]

**Acceptance Criteria**:

- [ ] [Works with existing feature X]
- [ ] [Backward compatible with API version Y]
- [ ] [No breaking changes to Z]

**Verification**: [Integration tests, regression tests]

---

## Constraints

Hard constraints that limit implementation choices.

### C-1: [Constraint Name]

**Constraint**: [What cannot be done or must be done a specific way]

**Reason**: [Why this constraint exists]

---

### C-2: [Constraint Name]

**Constraint**: [Description]

**Reason**: [Rationale]

---

## Out of Scope

Explicitly define what this feature does NOT include to prevent scope creep.

- [Thing 1 that is NOT included]
- [Thing 2 that is NOT included]
- [Thing 3 that is NOT included]

---

## Testing Requirements

Define what tests MUST be created. Implementation should write these tests FIRST (TDD approach).

### Unit Tests

Tests for individual functions/components in isolation.

| Test                          | Description               | Requirement |
| ----------------------------- | ------------------------- | ----------- |
| `test_[function]_[scenario]`  | [What this test verifies] | FR-1        |
| `test_[function]_[edge_case]` | [What this test verifies] | FR-1        |
| `test_[component]_[behavior]` | [What this test verifies] | FR-2        |

### Integration Tests

Tests for component interactions and API endpoints.

| Test                             | Description               | Requirement |
| -------------------------------- | ------------------------- | ----------- |
| `test_[flow]_[scenario]`         | [What this test verifies] | FR-1, FR-2  |
| `test_[api]_[endpoint]_[method]` | [What this test verifies] | FR-3        |

### Test Scenarios by Requirement

#### FR-1: [Requirement Name]

- [ ] Happy path: [description]
- [ ] Edge case: [description]
- [ ] Error case: [description]

#### FR-2: [Requirement Name]

- [ ] Happy path: [description]
- [ ] Edge case: [description]
- [ ] Error case: [description]

### Test Coverage Expectations

- Unit test coverage: [target %] for new code
- All acceptance criteria must have corresponding tests
- All error paths must be tested

---

## Verification Checklist

Use this checklist before marking the feature complete:

### Functional Requirements

- [ ] FR-1: [Name] - All criteria met
- [ ] FR-2: [Name] - All criteria met
- [ ] FR-3: [Name] - All criteria met

### Non-Functional Requirements

- [ ] NFR-1: Performance - All criteria met
- [ ] NFR-2: Security - All criteria met
- [ ] NFR-3: Error Handling - All criteria met
- [ ] NFR-4: Compatibility - All criteria met

### Constraints

- [ ] C-1: [Name] - Constraint respected
- [ ] C-2: [Name] - Constraint respected

### Final Verification

- [ ] All automated tests pass
- [ ] Manual testing completed per testing-strategy.md
- [ ] No regressions in existing functionality
- [ ] Documentation updated if required

### Phase Commits (REQUIRED)

Each phase MUST have a commit created after verification passes. Commits gate advancement to the next phase.

- [ ] Phase 1 commit created: `feat(<feature>): complete phase 1 - <name>`
- [ ] Phase 2 commit created: `feat(<feature>): complete phase 2 - <name>`
- [ ] Phase 3 commit created: `feat(<feature>): complete phase 3 - <name>`
- [ ] (Add more as needed for additional phases)

---

## Requirement Traceability

Map requirements to implementation:

| Requirement | Phase   | Files              | Tests                |
| ----------- | ------- | ------------------ | -------------------- |
| FR-1        | Phase 1 | `path/to/file.ts`  | `test/file.test.ts`  |
| FR-2        | Phase 2 | `path/to/other.ts` | `test/other.test.ts` |
| NFR-1       | Phase 3 | Multiple           | `test/perf/`         |

---

## Change Log

Track changes to requirements during planning phase. Once implementation begins, spec.md is frozen.

| Date   | Requirement | Change              | Reason |
| ------ | ----------- | ------------------- | ------ |
| [Date] | FR-1        | Added criterion X   | [Why]  |
| [Date] | NFR-2       | Relaxed from X to Y | [Why]  |

---

**Note**: This spec becomes immutable once implementation begins. Any changes after implementation starts require explicit user approval and should be rare. Implementation progress is tracked in `implementation-state.md`, not here.
```

### 3. Implementation-Guide.md Template

This document provides the strategic roadmap.

```markdown
# [Feature Name] - Implementation Guide

## Implementation Strategy

[Explain the overall approach and why phases are structured this way]

## Phase Breakdown

### Phase 1: Foundation

**Goal**: [What this phase achieves]

**Why First**: [Rationale for doing this phase first]

**Deliverables**:

- [Deliverable 1]
- [Deliverable 2]

**Dependencies**: None

**PR Strategy**: Single PR / Multiple PRs - [explain]

**Risks**: [Any risks specific to this phase]

**Detailed Docs**: `phase-01-foundation/`

**Completion Gate**: After verification passes, create commit: `feat(<feature>): complete phase 1 - foundation`. This commit gates advancement to Phase 2.

---

### Phase 2: Core Features

**Goal**: [What this phase achieves]

**Why After Phase 1**: [Rationale for ordering]

**Deliverables**:

- [Deliverable 1]
- [Deliverable 2]

**Dependencies**: Phase 1 complete (verified by Phase 1 commit)

**PR Strategy**: [explain]

**Risks**: [Any risks specific to this phase]

**Detailed Docs**: `phase-02-core-features/`

**Completion Gate**: After verification passes, create commit: `feat(<feature>): complete phase 2 - core-features`. This commit gates advancement to Phase 3.

---

### Phase 3: Polish

[Same structure as above, including Completion Gate]

## Migration & Rollout Strategy

**Pre-Deployment**:

1. [Step 1]
2. [Step 2]

**Deployment Order**:

- Week 1: [What gets deployed]
- Week 2: [What gets deployed]

**Rollback Plan**:
[How to rollback if issues occur]

**Monitoring**:

- [Metric 1 to monitor]
- [Metric 2 to monitor]

## Cross-Phase Concerns

**Backward Compatibility**: [Strategy across all phases]

**Testing**: [Overall testing approach]

**Performance**: [Overall performance considerations]

**Security**: [Security considerations across phases]
```

### 3. Phase Directory: technical-details.md Template

This is where implementation specifics live.

````markdown
# Phase [N]: [Phase Name] - Technical Details

## Objective

[Detailed explanation of what this phase accomplishes]

## Current State

### Existing Architecture

[Describe relevant existing code/architecture]

```typescript
// Example of current code structure
class ExistingService {
  // Show relevant existing patterns
}
```
````

### Limitations

- [Limitation 1]
- [Limitation 2]

## Proposed Changes

### Schema Changes

[If applicable - database, API, data structures]

```typescript
// New interfaces/types
interface NewStructure {
  // ...
}
```

```sql
-- Database migrations (if applicable)
ALTER TABLE ...
```

### Code Changes

#### File: `path/to/file.ts`

**Current** (relevant excerpt):

```typescript
// Show current implementation
```

**Proposed**:

```typescript
// Show proposed changes
```

**Rationale**: [Why this change]

#### File: `path/to/another-file.ts`

[Repeat structure above for each major file change]

### New Files

**File**: `path/to/new-file.ts`

**Purpose**: [Why this file]

**Structure**:

```typescript
// Outline of new file
```

## Implementation Approach

**Step-by-step**:

1. [First thing to implement and why]
2. [Second thing to implement and why]
3. [Continue...]

**Order Matters**: [Explain if certain changes must happen in specific order]

## API Changes

[If applicable]

**New Endpoints**:

- `POST /api/v1/resource` - [Description]

**Modified Endpoints**:

- `GET /api/v1/resource/:id` - [What changed and why]

**Breaking Changes**: [Any breaking changes and migration path]

## Edge Cases

### Edge Case 1: [Name]

**Scenario**: [Describe the edge case]

**Handling**: [How code handles it]

**Testing**: [How to test this edge case]

### Edge Case 2: [Name]

[Repeat structure]

## Performance Considerations

**Expected Impact**:

- [Impact on query performance]
- [Impact on memory]
- [Impact on response times]

**Optimizations**:

- [Optimization 1]
- [Optimization 2]

**Monitoring Points**:

- [What to monitor after deployment]

````

### 4. Phase Directory: files-to-modify.md Template

Quick reference for agents gathering context. Two formats are supported: **simple** (flat file list) and **work groups** (for parallel implementation).

#### Simple Format (no work groups)

Use this when all files are interconnected or the phase is small. The orchestrator assigns one implementer.

```markdown
# Phase [N]: Files to Modify

## Summary

- **New Files**: [count]
- **Modified Files**: [count]
- **Deleted Files**: [count]

## Quick Navigation

### Core Changes
- `path/to/main-file.ts` - [One sentence: what changes and why]
- `path/to/service.ts` - [One sentence]

### Supporting Changes
- `path/to/types.ts` - [One sentence]
- `path/to/utils.ts` - [One sentence]

### Tests
- `path/to/test-file.test.ts` - [One sentence]

---

## Detailed File List

### New Files

#### `path/to/new-file.ts`
**Purpose**: [Why this file exists]

**Dependencies**: [What it depends on]

**Used By**: [What uses it]

**Key Exports**:
- `functionName()` - [Description]
- `ClassName` - [Description]

---

### Modified Files

#### `path/to/existing-file.ts`
**Current Role**: [What this file currently does]

**Changes Needed**: [Specific changes]

**Impact**: [What else is affected by these changes]

**Functions to Modify**:
- `functionName()` - [What to change]
- `ClassName.methodName()` - [What to change]

---

### Deleted Files

#### `path/to/old-file.ts`
**Why Deleted**: [Rationale]

**Migration Path**: [Where functionality moved to]

---

## File References Map

Quick lookup of where important concepts are defined:

- **Type Definitions**: `lib/types/feature.ts` - `FeatureInput`, `FeatureOutput`
- **Core Logic**: `lib/services/feature-service.ts` - `processFeature()`, `validateInput()`
- **API Routes**: `app/api/v1/feature/route.ts` - `GET`, `POST` handlers
- **Database Queries**: `lib/repositories/feature-repo.ts` - `findById()`, `create()`
- **Tests**: `test/integration/feature.test.ts`
```

#### Work Group Format (for parallel implementation)

Use this when a phase has distinct, independent sets of files that can be implemented concurrently. The orchestrator spawns one implementer per independent group.

```markdown
# Phase [N]: Files to Modify

## Summary

- **New Files**: [count]
- **Modified Files**: [count]
- **Work Groups**: [count] ([N] independent, [N] dependent)

## Work Groups

### Group: [name] (independent)

[Brief description of this group's responsibility]

#### New Files
- `path/to/service-a.ts` - [Description]
- `path/to/types-a.ts` - [Description]

#### Tests
- `path/to/__tests__/service-a.test.ts` - [Description]

---

### Group: [name] (independent)

[Brief description]

#### New Files
- `path/to/service-b.ts` - [Description]
- `path/to/types-b.ts` - [Description]

#### Tests
- `path/to/__tests__/service-b.test.ts` - [Description]

---

### Group: integration (depends: [group-a], [group-b])

Shared files that depend on other groups completing first.

#### Modified Files
- `path/to/routes.ts` - Wire up new services
- `path/to/index.ts` - Add barrel exports

#### Tests
- `path/to/__tests__/integration.test.ts` - End-to-end tests

---

## File References Map

[Same as simple format]
```

#### Work Group Syntax

- **Group header**: `### Group: {name} ({dependency})`
  - `(independent)` — can run in parallel with other independent groups
  - `(depends: group-a, group-b)` — must wait for named groups to complete
  - No annotation defaults to `(independent)`
- **Within each group**: Use `#### New Files`, `#### Modified Files`, `#### Tests` subsections
- **Integration group**: A common pattern for shared files (barrel exports, route registration) that depend on all independent groups

#### When to Use Work Groups

**Use work groups when:**
- Phase has 2+ distinct features or services that don't share files
- Files can be cleanly separated by domain (auth vs. email vs. billing)
- Each group has its own tests that don't depend on other groups

**Don't use work groups when:**
- All files are interconnected (e.g., modifying a single service)
- The phase is small (< 5 files) — overhead isn't worth it
- Files share types or utilities that would need to exist before any group starts

**Default behavior:** If no `### Group:` markers exist, the orchestrator treats the entire phase as a single work group with one implementer. Fully backward compatible.

**Note:** `verification-harness.md` is per-phase, not per-work-group. When a phase has work groups AND a verification harness, the tester runs after ALL work groups complete, testing the combined result.
````

### 5. Phase Directory: testing-strategy.md Template

```markdown
# Phase [N]: Testing Strategy

## Test Coverage Goals

- **Unit Tests**: [Target coverage %]
- **Integration Tests**: [Target coverage %]
- **E2E Tests**: [Target coverage %]

## Test Scenarios

### Unit Tests

#### Test Suite: [Component/Service Name]

**File**: `test/unit/path-to-test.test.ts`

**Scenarios**:

1. **Happy Path**: [What's tested]
   - Input: [Example]
   - Expected: [Expected result]

2. **Edge Case: [Name]**: [What's tested]
   - Input: [Example]
   - Expected: [Expected result]

3. **Error Handling: [Name]**: [What's tested]
   - Input: [Example]
   - Expected: [Expected behavior]

---

### Integration Tests

#### Test Suite: [Feature Name] Integration

**File**: `test/integration/path-to-test.test.ts`

**Setup Required**:

- [Database setup]
- [Mock services]
- [Test data]

**Scenarios**:

1. **Full Flow**: [Description]
   - Steps: [1, 2, 3...]
   - Assertions: [What to verify]

2. **With Dependencies**: [Description]
   - Steps: [1, 2, 3...]
   - Assertions: [What to verify]

---

### E2E Tests

#### Test Suite: [User Journey]

**File**: `test/e2e/path-to-test.test.ts`

**User Story**: As a [user], I want to [action] so that [benefit]

**Steps**:

1. [User action]
2. [System response]
3. [User verification]

**Assertions**:

- [What user should see]
- [What should be persisted]

---

## Test Data

### Fixtures

**File**: `test/fixtures/feature-data.ts`

**Data Sets**:

- `validInput` - [Description]
- `edgeCaseInput` - [Description]
- `invalidInput` - [Description]

---

## Mock Strategy

### Service: [Name]

**Mock File**: `test/mocks/service-mock.ts`

**Mocked Methods**:

- `method1()` - [Returns what]
- `method2()` - [Returns what]

**Why Mocked**: [Rationale]

---

## Performance Tests

### Load Test: [Scenario]

**Tool**: [k6, Jest, etc.]

**Scenario**: [What's being tested]

**Acceptance Criteria**:

- Response time: [< X ms]
- Throughput: [X requests/sec]
- Error rate: [< X%]

---

## Manual Testing Checklist

For each phase deployment:

- [ ] [Test scenario 1]
- [ ] [Test scenario 2]
- [ ] [Test scenario 3]
- [ ] Verify backward compatibility
- [ ] Test rollback procedure

---

## Regression Testing

**Existing Features to Verify**:

- [Feature 1] - [What to test]
- [Feature 2] - [What to test]

**Why These**: [Explain why these features might be affected]
```

### 6. Phase Directory: verification-harness.md Template (OPTIONAL)

This file is **optional**. Only create it for phases that benefit from custom behavioral verification — typically phases with API endpoints, UI changes, or complex integration behavior. If this file exists for a phase, the implementation orchestrator spawns a tester agent that runs concurrently with the verifier and reviewer.

**Do NOT create this file for every phase.** Skip it when:

- The phase only adds internal logic with no external entry points
- Standard unit/integration tests already cover the behavior adequately
- The phase is purely foundational (types, configs, schemas)

````markdown
# Phase [N]: Verification Harness

> This file defines custom verification tests run by a tester agent
> AFTER implementation, concurrently with verifier and reviewer.
> If this file does not exist, no tester is spawned.

## Dev Server Configuration (optional overrides)

- **Port**: [3000]
- **Start Command**: [`npm run dev`]
- **Health Endpoint**: [`http://localhost:3000/api/health`]
- **Startup Timeout**: [30 seconds]

## Eval Scripts

### Eval: [Name]

**Runner**: vitest | jest | node
**Purpose**: [What this verifies beyond standard tests]
**Script Outline**:

```typescript
// Tester creates the actual script based on this outline
// Import from actual implementation paths
import { SearchService } from "../../src/services/search";

// Test the behavior
const service = new SearchService(config);
const results = await service.search("test query");

// Assert expected outcome
expect(results).toHaveLength(/* expected count */);
expect(results[0]).toHaveProperty("title");
```

**Expected Outcome**: [What passing looks like]

---

## API Smoke Tests

### Smoke: [Endpoint Name]

**Method**: POST | GET | PUT | DELETE
**URL**: [/api/endpoint]
**Body**:

```json
{
  "query": "test search",
  "limit": 10
}
```

**Expected Status**: [200]
**Response Checks**:

- [Body contains results array]
- [Results have id and title fields]
- [Response time < 2s]

---

## Browser Tests

### Browser: [Test Name]

**Page**: [/path]
**Steps**:

1. [Navigate to page]
2. [Fill search input with "test query"]
3. [Click search button]
4. [Wait for results to appear]

**Assertions**:

- [Results container is visible]
- [At least one result item is rendered]
- [No error messages displayed]

---

## Graceful Degradation

Capabilities unavailable in the environment are SKIPPED, not failed.
The tester reports which capabilities ran and which were skipped.
````

## Usage Instructions

### When to Use This Skill

Invoke this skill when:

- Feature requires 3+ separate PRs to implement safely
- Feature touches multiple systems or domains
- Implementation strategy needs careful sequencing
- Future agents will need detailed context to continue work
- Feature has complex edge cases or architectural decisions

### Clarifying Requirements (CRITICAL - DO THIS FIRST)

**MANDATORY: Before writing ANY plan documents, you MUST thoroughly clarify requirements with the user.**

Vague requirements lead to wasted implementation time. A plan built on assumptions is a plan that will fail. **Your job is to be annoyingly thorough in questioning.**

**USE THE AskUserQuestion TOOL (IF AVAILABLE):**

- If you have access to the AskUserQuestion tool, use it for every round of clarifying questions
- Structure questions as multiple-choice where possible to reduce friction
- Ask follow-up questions until you have SPECIFIC, CONCRETE answers
- Never accept vague answers like "the normal way" or "whatever makes sense"

**Questioning Mindset:**

- Pretend you're a consultant being paid $500/hour - you need COMPLETE understanding before starting
- Every assumption you make is a potential bug in the plan
- Users often don't know what they need until asked the right questions
- It's better to ask 20 questions upfront than discover 20 problems during implementation

**Question Categories to Explore:**

1. **Scope Clarification**
   - What exactly should this feature do? (Get specific examples)
   - What should it NOT do? (Define boundaries early)
   - Are there similar features to reference?
   - What's the minimum viable version vs nice-to-haves?

2. **User Experience**
   - Who are the users of this feature?
   - What's the user's workflow/journey?
   - What happens on success? On failure?
   - Are there UI/UX preferences or constraints?

3. **Technical Constraints**
   - Are there performance requirements (response time, throughput)?
   - Security requirements (auth, permissions, data sensitivity)?
   - Compatibility requirements (browsers, APIs, backwards compat)?
   - Infrastructure constraints (hosting, databases, external services)?

4. **Edge Cases**
   - What happens when X fails?
   - How should concurrent access be handled?
   - What about empty states, large datasets, special characters?
   - Rate limiting, quotas, or other operational concerns?

5. **Integration Points**
   - What existing features does this touch?
   - External APIs or services involved?
   - Data flow between systems?

6. **Success Criteria**
   - How will we know this feature is working correctly?
   - What metrics define success?
   - What's the testing strategy?

**Questioning Process (4 PHASES - ALL MANDATORY):**

### Phase A: Initial Requirements Gathering (USE AskUserQuestion TOOL)

Ask 5-10 broad clarifying questions covering scope, users, and constraints. Use multiple-choice options where possible to surface hidden requirements.

Cover these categories in your initial questions:

- **Scope**: What exactly should this do? What should it NOT do?
- **Users**: Who uses this? What's their workflow?
- **UX**: What happens on success? On failure? UI preferences?
- **Technical Constraints**: Performance, security, compatibility, infrastructure?
- **Edge Cases**: Failure modes, concurrent access, empty states, large datasets?
- **Integration Points**: What existing features does this touch? External APIs?
- **Success Criteria**: How will we know this is working?

### Phase B: Codebase Exploration (USE Task TOOL WITH Explore AGENT)

**MANDATORY: After Round 1 answers, explore the codebase BEFORE asking more questions.**

You are making assumptions about the codebase based on the user's description. Those assumptions are likely incomplete or wrong. Before you can ask sharp follow-up questions, you need ground truth.

**Spawn an Explore agent** (via the Task tool with `subagent_type: Explore`) to investigate:

1. **Existing architecture** — How are similar features structured? What patterns are used?
2. **Integration surface** — What files, functions, and types will this feature touch?
3. **Existing abstractions** — Are there utilities, services, or patterns this feature should reuse?
4. **Test patterns** — How are similar features tested? What test infrastructure exists?
5. **Entry points** — What API routes, pages, or CLI commands exist near this feature area?
6. **Dev server / build setup** — What scripts exist in package.json? What's the dev workflow?

**What exploration gives you:**

- Real file paths and function names instead of guesses
- Understanding of which phases will have API endpoints, UI pages, or complex behavior
- Knowledge of existing patterns the feature should follow
- Concrete examples to reference in follow-up questions

**Do NOT skip this phase.** A plan built on assumptions about the codebase is a plan that will fail during implementation.

### Phase C: Informed Drill-Down (USE AskUserQuestion TOOL)

Now you have both the user's requirements AND codebase reality. This is where you get sharp.

1. **Challenge assumptions with evidence:**
   - "You mentioned adding a new service, but the codebase uses function exports, not classes — should we follow the existing pattern?"
   - "I found 3 files that import the module you want to modify — should those be updated too?"
   - "The existing test setup uses MSW for HTTP mocking — should we follow that pattern?"

2. **Surface discoveries the user didn't mention:**
   - "I found an existing utility at `src/utils/X.ts` that does part of what you described — should we extend it?"
   - "There's already a feature flag system in `src/config/features.ts` — should this feature use it?"

3. **Per-phase verification harness decisions (MANDATORY — see below)**

4. **Probe edge cases with real code context:**
   - "The existing `search()` function doesn't handle empty results — should the new feature?"
   - "I noticed the API has no rate limiting — is that a concern for this feature?"

### Phase C.1: Verification Harness Decisions (MANDATORY PER-PHASE)

**For EACH proposed phase**, you MUST explicitly discuss whether it needs a `verification-harness.md`. Do not bundle this into a generic question — ask per-phase.

**Phases that NEED a harness** (default to YES, push the user to include one):

- Phases that add or modify **API endpoints** — smoke test the actual HTTP contract
- Phases that add or modify **UI pages/components** — verify rendering and user flows
- Phases with **complex integration behavior** — eval scripts that exercise the full chain
- Phases that change **data pipelines or processing** — verify output correctness end-to-end

**Phases that DON'T need a harness** (default to NO):

- Purely foundational phases (types, configs, schemas, internal refactors)
- Phases that only add internal logic with no external entry points
- Phases where standard unit/integration tests fully cover the behavior

**How to prompt the user:**

Use AskUserQuestion with concrete, per-phase choices. Example:

```
Phase 1 (Foundation - DB schema + types): No harness needed — foundational only.
Phase 2 (API endpoints): I recommend a verification harness with API smoke tests.
  - The new POST /api/activities endpoint should be smoke-tested with real payloads.
  - The GET endpoint should verify response shape and status codes.
Phase 3 (UI integration): I recommend a verification harness with browser checks.
  - The activity table should render with test data.
  - The manual entry form should submit without errors.

Do you agree with these harness recommendations, or would you adjust any?
```

**Why this matters:** A `verification-harness.md` triggers a tester agent during implementation. Without it, complex behavior is only verified by standard tests — which often miss integration-level issues like wrong response shapes, broken UI rendering, or misconfigured routes. Verification harnesses catch the bugs that slip between unit tests and production.

**NEVER skip this step.** If you don't discuss harnesses explicitly, phases that need them will ship without behavioral verification.

### Phase D: Final Verification (USE AskUserQuestion TOOL)

1. Present your complete understanding:
   - All functional requirements
   - All constraints and non-functional requirements
   - Per-phase breakdown with harness decisions
   - Key architectural decisions informed by codebase exploration
2. Ask "Is this understanding correct?"
3. Resolve any remaining ambiguities
4. Ask about priorities: "If we can only ship 2 of these 4 features, which 2?"

### Documentation

Throughout all phases:

- Keep a record of all Q&A in the plan
- Document unknowns explicitly — don't paper over gaps
- If user doesn't know, that's valuable information — document it as an open question
- Document codebase exploration findings — these inform the plan's architecture decisions

**NEVER proceed to planning if:**

- You have unresolved ambiguities about core requirements
- User gave vague answers that you haven't drilled into
- You're making assumptions about user intent without confirmation
- You haven't explored the codebase to validate your understanding
- You haven't made per-phase verification harness decisions with the user

If AskUserQuestion tool is not available, achieve the same through direct questioning in your responses.

**Red Flags That Indicate More Questions Needed:**

- "It should just work like X" (what specifically about X?)
- "The normal way" (what's normal in this context?)
- "Whatever makes sense" (clarify expectations)
- "We might need X later" (include in plan or explicitly defer?)
- Any ambiguous terms (define them explicitly)

**Document Your Questions:**
Keep a record of questions asked and answers received. This becomes valuable context in the plan's `overview.md` or `shared/architecture-decisions.md`.

### How to Create a Plan

By this point you have completed Phases A-D: you have user requirements, codebase exploration findings, and per-phase harness decisions confirmed.

1. **Create Directory Structure**

   ```bash
   cd ~/.ai/plans
   mkdir -p feature-name/{phase-01-foundation,phase-02-core,phase-03-polish,shared}
   ```

2. **Write Overview First**
   - Keep it under 200 lines
   - Focus on "why" and "what", not "how"
   - Include success criteria

3. **Create Spec File**
   - Define ALL functional requirements with acceptance criteria
   - Define non-functional requirements (performance, security, etc.)
   - Document constraints and out-of-scope items
   - Create verification checklist
   - This is the authoritative source of truth for what MUST be implemented

4. **Create Implementation Guide**
   - Define clear phases with dependencies
   - Explain sequencing rationale
   - Document rollout strategy

5. **Detail Each Phase**
   - Only create phase directories as needed
   - Use templates above for consistency
   - Reference real file paths and function names from codebase exploration — not guesses
   - Include code examples from the actual codebase where relevant
   - Document decisions and trade-offs
   - Create `verification-harness.md` for phases confirmed to need behavioral verification (per Phase C.1 decisions)

6. **Keep It Updated**
   - Update as implementation reveals new information
   - Document deviations from plan with rationale
   - Add lessons learned

### Phase Naming Conventions

Use numbered prefixes for clear ordering:

- `phase-01-foundation` - Foundational changes, often database/API
- `phase-02-core-features` - Main functionality
- `phase-03-integration` - Connecting systems
- `phase-04-polish` - UX improvements, edge cases
- `phase-05-optimization` - Performance, cleanup (if needed)

### Progressive Disclosure in Practice

**Level 1 - Quick Context** (2 minutes):

- Read `overview.md` only
- Understand problem, solution, and success criteria

**Level 2 - Requirements** (5 minutes):

- Read `spec.md` for MUST-have requirements
- Understand acceptance criteria and constraints
- Know what defines "done"

**Level 3 - Implementation Strategy** (10 minutes):

- Read `implementation-guide.md`
- Understand phases, dependencies, rollout plan

**Level 4 - Phase Implementation** (30+ minutes):

- Dive into specific phase directory
- Read technical-details.md, files-to-modify.md
- Cross-reference spec.md to ensure requirements are met
- Implement with full context

**Level 5 - Deep Context** (as needed):

- Review testing-strategy.md before writing tests
- Check shared/ directory for cross-phase concerns

## File Reference Format

Reference code by function/class names, not line numbers (lines shift as code changes):

**Good references:**

- `path/to/file.ts` - `functionName()` - What to change
- `path/to/service.ts` - `ClassName.methodName()` - Specific method
- `path/to/types.ts` - `InterfaceName` - Type definition

**Avoid:**

- ~~`path/to/file.ts:123-145`~~ - Line numbers become stale quickly

This keeps references valid as the codebase evolves.

## Best Practices

1. **Be Specific**: Vague plans lead to confusion. Include code examples.

2. **Document Rationale**: Future you won't remember why decision was made.

3. **Update as You Go**: Plans are living documents. Update when reality diverges.

4. **Link to Code**: Reference specific functions/classes by name. Makes context gathering fast and stays valid as code changes.

5. **Capture Gotchas**: Document anything that took >30 min to debug.

6. **Think in PRs**: Each phase should produce reviewable, shippable PRs.

7. **Consider Rollback**: Document how to undo changes if needed.

8. **Plan for Monitoring**: Include what metrics to watch after deployment.

## Anti-Patterns to Avoid

❌ **Don't**: Create massive 5000-line single-document plans
✅ **Do**: Break into focused, navigable documents

❌ **Don't**: Write implementation details in overview.md
✅ **Do**: Keep overview high-level, details in phase directories

❌ **Don't**: Skip rationale and just list tasks
✅ **Do**: Explain "why" for every major decision

❌ **Don't**: Create phases that can't be independently shipped
✅ **Do**: Ensure each phase is a complete, shippable unit

❌ **Don't**: Forget about backward compatibility
✅ **Do**: Document compatibility strategy for each phase

❌ **Don't**: Mix multiple concerns in one phase
✅ **Do**: Keep phases focused on single concern when possible

❌ **Don't**: Skip codebase exploration and plan based on assumptions
✅ **Do**: Explore the codebase after initial requirements, then ask informed follow-up questions

❌ **Don't**: Skip verification harness decisions or ask about them generically
✅ **Do**: Make explicit per-phase harness decisions with the user, with concrete reasoning

## Example Plan Reference

**Template examples:**
This skill includes example templates in `examples/` showing well-structured documents based on a "Task Comments" feature:

- `examples/overview-example.md` - How to write a concise, navigable overview
- `examples/spec-example.md` - How to write testable requirements with acceptance criteria
- `examples/implementation-guide-example.md` - How to structure phases with required tests and completion criteria
- `examples/phase-technical-details-example.md` - How to document implementation details
- `examples/phase-files-to-modify-example.md` - How to list files for quick context gathering

Review these examples before creating your first plan.

## Integration with Existing Workflow

This skill **supplements** the simple planning guidance in your base instructions. Use:

- **Base instructions** for straightforward features (1-2 PRs)
- **This skill** for complex features needing detailed planning and phasing

## Output Format

When using this skill, follow this sequence:

1. **Phase A: Initial Requirements** (USE AskUserQuestion TOOL)
   - Ask 5-10 broad clarifying questions covering scope, users, constraints
   - Structure questions as multiple-choice to surface hidden requirements
   - Challenge vague answers — don't accept "normal", "fast", "simple"

2. **Phase B: Codebase Exploration** (USE Task TOOL WITH Explore AGENT)
   - After receiving initial answers, explore the codebase
   - Find existing patterns, integration points, test infrastructure, entry points
   - Build a real understanding before asking more questions

3. **Phase C: Informed Drill-Down** (USE AskUserQuestion TOOL)
   - Challenge user assumptions with codebase evidence
   - Surface discoveries the user didn't mention
   - Make per-phase verification harness decisions (MANDATORY)
   - Probe edge cases with real code context

4. **Phase D: Final Verification** (USE AskUserQuestion TOOL)
   - Present complete understanding with per-phase harness decisions
   - Get explicit confirmation before proceeding
   - **DO NOT START PLANNING until user confirms understanding is correct**

5. **Propose Structure**
   - Suggest feature name for directory
   - Outline proposed phases with harness decisions
   - Preview key requirements that will go in spec.md
   - Get user approval on approach

6. **Create Documents**
   - Start with overview.md
   - Create spec.md with all requirements (CRITICAL — this defines what MUST be implemented)
   - Create implementation-guide.md
   - Create phase directories as needed
   - Fill in templates with actual content from clarifying questions AND codebase exploration
   - Create `verification-harness.md` for phases confirmed to need behavioral verification
   - Reference real file paths and function names discovered during exploration

7. **Summarize**
   - Show directory tree created
   - Highlight key requirements from spec.md
   - List which phases have verification harnesses and why
   - Explain how to navigate the plan
   - Suggest where to start implementation

8. **STOP** — Do NOT begin implementation. The plan is your deliverable. Implementation is a separate step via `/ctdio-feature-implementation`.

## Success Criteria for Plans

A good feature plan should:

- ✅ Be navigable in under 2 minutes (via overview)
- ✅ Have spec.md with ALL requirements clearly defined and verifiable
- ✅ Have acceptance criteria for every functional requirement
- ✅ Enable agent to start Phase 1 with full context
- ✅ Document all major architectural decisions
- ✅ Include specific file and function/class references from actual codebase exploration
- ✅ Define clear success criteria per phase
- ✅ Consider backward compatibility and rollback
- ✅ Capture edge cases and gotchas
- ✅ Be updateable as implementation progresses
- ✅ Include verification checklist in spec.md
- ✅ Have `verification-harness.md` for every phase with API endpoints, UI changes, or complex behavior

Remember: These plans are "mini-skills" that make future implementation faster and more confident. The spec.md is especially critical - it's the authoritative definition of what MUST be implemented. Invest time upfront to save time later.

**Reminder: Your job ends when the plan documents are complete. Do NOT start implementing the feature.**
