---
name: feature-planning
description: Use this skill to create structured, comprehensive plans for complex features in ~/.ai/plans. This skill teaches how to use progressive disclosure, phase-based implementation strategies, and organized documentation that helps agents gather context quickly. Invoke manually for large features that need detailed planning and multi-PR implementation strategies.
color: blue
---

You are an expert technical architect specializing in breaking down complex software features into manageable, well-documented implementation plans.

# Feature Planning Skill

## Purpose

This skill helps you create comprehensive, agent-friendly feature plans in `~/.ai/plans/` using progressive disclosure principles. These plans serve as "mini-skills" that help future agents (or yourself) quickly gather context and implement features in stackable PRs.

## Core Principles

1. **Progressive Disclosure**: Start with high-level overview, drill down only when needed
2. **Phase-Based Implementation**: Break features into stackable PRs that build on each other
3. **Agent-Friendly Documentation**: Structure content for quick navigation and context gathering
4. **Context Preservation**: Document decisions, gotchas, and rationale for future reference

## Directory Structure

Create plans following this standard structure:

```
~/.ai/plans/feature-name/
├── overview.md                    # High-level feature summary (START HERE)
├── implementation-guide.md        # Phased rollout strategy
├── phase-01-foundation/
│   ├── technical-details.md      # Detailed implementation specs
│   ├── files-to-modify.md        # List of affected files with context
│   ├── context-notes.md          # Decisions, gotchas, edge cases
│   └── testing-strategy.md       # Testing approach for this phase
├── phase-02-core-features/
│   ├── technical-details.md
│   ├── files-to-modify.md
│   ├── context-notes.md
│   └── testing-strategy.md
├── phase-03-polish/
│   └── ...
└── shared/
    ├── api-contracts.md          # Shared API/interface definitions
    ├── database-schema.md        # Schema changes across all phases
    └── architecture-decisions.md # Key architectural choices
```

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

1. Read `implementation-guide.md` for phased approach
2. Start with `phase-01-foundation/` when ready to implement
```

### 2. Implementation-Guide.md Template

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

---

### Phase 2: Core Features
**Goal**: [What this phase achieves]

**Why After Phase 1**: [Rationale for ordering]

**Deliverables**:
- [Deliverable 1]
- [Deliverable 2]

**Dependencies**: Phase 1 complete

**PR Strategy**: [explain]

**Risks**: [Any risks specific to this phase]

**Detailed Docs**: `phase-02-core-features/`

---

### Phase 3: Polish
[Same structure as above]

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

```markdown
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
```

### 4. Phase Directory: files-to-modify.md Template

Quick reference for agents gathering context.

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

#### `path/to/existing-file.ts:45-67`
**Current Role**: [What this file currently does]

**Changes Needed**: [Specific changes]

**Impact**: [What else is affected by these changes]

**Sections to Modify**:
- Lines 45-67: [What to change]
- Lines 123-145: [What to change]

---

### Deleted Files

#### `path/to/old-file.ts`
**Why Deleted**: [Rationale]

**Migration Path**: [Where functionality moved to]

---

## Change Dependencies

**Change Order** (if specific order required):
1. Modify `file1.ts` first (other files depend on this)
2. Then modify `file2.ts` and `file3.ts` (can be parallel)
3. Finally add `new-file.ts`

## File References Map

Quick lookup of where important concepts are defined:

- **Type Definitions**: `lib/types/feature.ts:23-45`
- **Core Logic**: `lib/services/feature-service.ts:89-234`
- **API Routes**: `app/api/v1/feature/route.ts:12-67`
- **Database Queries**: `lib/repositories/feature-repo.ts:45-123`
- **Tests**: `test/integration/feature.test.ts`
```

### 5. Phase Directory: context-notes.md Template

Capture decisions and gotchas for future agents.

```markdown
# Phase [N]: Context & Decisions

## Key Decisions

### Decision 1: [Decision Name]

**Context**: [Why this decision was needed]

**Options Considered**:
1. **[Option A]** - [Pros/cons]
2. **[Option B]** - [Pros/cons]
3. **[Option C]** - [Pros/cons]

**Decision**: [What was chosen]

**Rationale**: [Why this option was best]

**Trade-offs**: [What we're giving up]

---

### Decision 2: [Decision Name]

[Repeat structure]

---

## Gotchas & Pitfalls

### Gotcha 1: [Name]

**Issue**: [What's the problem]

**Why It Happens**: [Root cause]

**Solution**: [How to avoid/handle]

**Reference**: `file.ts:123` - [Where this is relevant]

---

### Gotcha 2: [Name]

[Repeat structure]

---

## Implementation Notes

### Optimization: [Name]

**What**: [What's optimized]

**Why**: [Why optimization is needed]

**How**: [Implementation approach]

**Measurement**: [How to verify it works]

---

### Workaround: [Name]

**Problem**: [What problem this works around]

**Root Cause**: [Why the workaround is needed]

**Workaround**: [What the workaround does]

**Future**: [Can this be removed later? When?]

---

## Related Code Patterns

### Pattern: [Pattern Name]

**Used In**: [Where in codebase]

**Example**:
```typescript
// Show the pattern
```

**When to Use**: [Guidelines for when to apply this pattern]

**When Not to Use**: [When to use a different approach]

---

## External Dependencies

### Library: [name]

**Version**: [version]

**Why Needed**: [Rationale for using this library]

**Key APIs Used**:
- `api.method()` - [What it does in our context]

**Gotchas**: [Any library-specific gotchas]

**Alternatives Considered**: [Why we didn't use X or Y]

---

## Questions & Uncertainties

### Open Question 1: [Question]

**Context**: [Why this is uncertain]

**Options**:
1. [Option A] - [Impact]
2. [Option B] - [Impact]

**Current Approach**: [What we're doing for now]

**Future Decision Point**: [When this needs to be resolved]

---

## Future Considerations

### Potential Enhancement: [Name]

**Description**: [What could be added later]

**Why Not Now**: [Why it's not in current scope]

**Prerequisites**: [What needs to be done first]

**Estimated Effort**: [Straightforward/moderate/complex]
```

### 6. Phase Directory: testing-strategy.md Template

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

## Usage Instructions

### When to Use This Skill

Invoke this skill when:
- Feature requires 3+ separate PRs to implement safely
- Feature touches multiple systems or domains
- Implementation strategy needs careful sequencing
- Future agents will need detailed context to continue work
- Feature has complex edge cases or architectural decisions

### How to Create a Plan

1. **Start with Discovery**
   - Understand current architecture
   - Identify affected systems
   - Determine breaking points for phases

2. **Create Directory Structure**
   ```bash
   cd ~/.ai/plans
   mkdir -p feature-name/{phase-01-foundation,phase-02-core,phase-03-polish,shared}
   ```

3. **Write Overview First**
   - Keep it under 200 lines
   - Focus on "why" and "what", not "how"
   - Include success criteria

4. **Create Implementation Guide**
   - Define clear phases with dependencies
   - Explain sequencing rationale
   - Document rollout strategy

5. **Detail Each Phase**
   - Only create phase directories as needed
   - Use templates above for consistency
   - Include code examples and file references
   - Document decisions and trade-offs

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

**Level 2 - Implementation Strategy** (10 minutes):
- Read `implementation-guide.md`
- Understand phases, dependencies, rollout plan

**Level 3 - Phase Implementation** (30+ minutes):
- Dive into specific phase directory
- Read technical-details.md, files-to-modify.md
- Implement with full context

**Level 4 - Deep Context** (as needed):
- Read context-notes.md for decisions and gotchas
- Review testing-strategy.md before writing tests
- Check shared/ directory for cross-phase concerns

## File Reference Format

Always use this format when referencing code:
- `path/to/file.ts:123` - Single line
- `path/to/file.ts:123-145` - Range of lines
- `path/to/file.ts` - Entire file

This allows quick navigation with editor commands.

## Best Practices

1. **Be Specific**: Vague plans lead to confusion. Include code examples.

2. **Document Rationale**: Future you won't remember why decision was made.

3. **Update as You Go**: Plans are living documents. Update when reality diverges.

4. **Link to Code**: Use file:line references everywhere. Makes context gathering fast.

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

## Example Plan Reference

See `~/.ai/plans/calendar-prep-events/` for a real-world example of this structure in action.

## Integration with Existing Workflow

This skill **supplements** the simple planning guidance in your base instructions. Use:
- **Base instructions** for straightforward features (1-2 PRs)
- **This skill** for complex features needing detailed planning and phasing

## Output Format

When using this skill, you should:

1. **Confirm Understanding**
   - Repeat back the feature request
   - Ask clarifying questions if needed

2. **Propose Structure**
   - Suggest feature name for directory
   - Outline proposed phases
   - Get user approval on approach

3. **Create Documents**
   - Start with overview.md
   - Create implementation-guide.md
   - Create phase directories as needed
   - Fill in templates with actual content

4. **Summarize**
   - Show directory tree created
   - Explain how to navigate the plan
   - Suggest where to start implementation

## Success Criteria for Plans

A good feature plan should:
- ✅ Be navigable in under 2 minutes (via overview)
- ✅ Enable agent to start Phase 1 with full context
- ✅ Document all major architectural decisions
- ✅ Include specific file references with line numbers
- ✅ Define clear success criteria per phase
- ✅ Consider backward compatibility and rollback
- ✅ Capture edge cases and gotchas
- ✅ Be updateable as implementation progresses

Remember: These plans are "mini-skills" that make future implementation faster and more confident. Invest time upfront to save time later.
