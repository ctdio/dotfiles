# Shared Guidance

This guide applies to ALL agents in the feature implementation system. Read this for troubleshooting, tips, and common patterns.

---

## Understanding the System

### The Orchestrator Model

```
Orchestrator (coordinates)
    │
    ├── state-manager (creates/updates implementation-state.md)
    │
    ├── phase-implementer (implements one phase)
    │
    └── phase-verifier (verifies one phase)
```

**Key insight**: Each agent has a focused role. The orchestrator manages flow; you do your specific job.

### Your Role in the System

| Agent | Focus | You DON'T Do |
|-------|-------|--------------|
| state-manager | State file accuracy | Implementation, verification |
| phase-implementer | Writing code & tests | Verification commands, state updates |
| phase-verifier | Running checks, reporting | Fixing code, state updates |

---

## Plan Directory Structure

All agents should understand this structure:

```
~/.ai/plans/{feature}/
├── implementation-guide.md          # Phases overview
├── overview.md                      # Feature description
├── spec.md                          # Requirements (THE LAW)
├── phase-01-{name}/
│   ├── files-to-modify.md           # What to create/modify
│   ├── technical-details.md         # How to implement
│   └── testing-strategy.md          # How to test
├── phase-NN-{name}/
│   └── ...
├── shared/
│   ├── architecture-decisions.md    # Cross-cutting patterns
│   └── database-schema.md           # Schema (if any)
└── implementation-state.md          # Progress tracking
```

**Read files directly** - don't search for them. The structure is deterministic.

---

## Spec.md is Law

The `spec.md` file defines:
- **Functional Requirements (FR)**: Features that MUST work
- **Non-Functional Requirements (NFR)**: Performance, security, etc.
- **Constraints**: Limitations that MUST be respected
- **Acceptance Criteria**: How to verify requirements are met

**All agents** should reference spec.md:
- Implementer: Ensure code meets requirements
- Verifier: Check requirements are satisfied
- State-manager: Track requirement completion status

---

## Troubleshooting

### "I can't find the plan files"

1. Check the exact path: `~/.ai/plans/{feature}/`
2. Verify the feature name matches directory name
3. Ask orchestrator to confirm the feature name

### "The plan seems outdated or wrong"

1. Document the discrepancy in your result
2. Follow what makes sense given the codebase
3. Note it as a deviation with justification
4. Don't silently ignore the inconsistency

### "I'm blocked by something outside my control"

1. Document the blocker clearly
2. Specify what's needed to unblock
3. Complete what you can without the blocked item
4. Return a partial result with blocker documented

### "The codebase doesn't match expectations"

1. Read existing code to understand actual patterns
2. Follow actual patterns, not assumed ones
3. Document any discoveries
4. Suggest plan updates if significant

### "Tests are failing for unclear reasons"

1. Read the test error messages carefully
2. Check if it's a code issue or test issue
3. Verify test environment is correct
4. Document the specific failure for debugging

### "Verification keeps failing"

After 3 attempts, the orchestrator will ask the user for help. But before that:
1. Read ALL issues from previous attempts
2. Fix issues in priority order (high → low)
3. Don't introduce new issues while fixing
4. Test after each fix

---

## Communication Patterns

### Structured Results

All agents return structured data. Use YAML-like formatting:

```yaml
ResultType:
  field1: value
  field2:
    - list item 1
    - list item 2
  field3: |
    Multi-line
    text content
```

### Status Indicators

Use consistently across all communication:

| Symbol | Meaning | Use For |
|--------|---------|---------|
| ✅ | Complete/Pass | Finished tasks, passing tests |
| 🔄 | In Progress | Current work |
| ⏳ | Pending | Not yet started |
| 🔴 | Failing | Failing tests |
| ⛔ | Blocked | Cannot proceed |
| ❌ | Failed | Verification failed |

### Severity Levels

For issues:
- **high**: Blocks completion, must fix
- **medium**: Should fix, but not blocking
- **low**: Nice to fix, can defer

---

## Best Practices

### Read Before You Act

Before doing anything:
1. Read the relevant plan files
2. Read existing code you'll modify
3. Understand patterns before implementing

### Document Everything

- Decisions made
- Deviations from plan
- Gotchas discovered
- Challenges encountered

### Be Specific

Bad: "There's an error in the code"
Good: "Type error at src/services/user.ts:45 - 'string' not assignable to 'number'"

### Complete Your Role

Don't leave partial work:
- Implementer: All deliverables done or blocked
- Verifier: All checks run
- State-manager: All sections updated

### Trust the System

- Orchestrator handles flow - focus on your task
- Other agents handle their parts - don't duplicate
- State file tracks progress - don't track separately

---

## Anti-Patterns (All Agents)

### Communication Anti-Patterns

❌ **Don't**: Return vague results
✅ **Do**: Be specific with paths, line numbers, exact errors

❌ **Don't**: Hide problems or uncertainties
✅ **Do**: Document issues clearly

❌ **Don't**: Assume the orchestrator knows context
✅ **Do**: Include all relevant information in results

### Process Anti-Patterns

❌ **Don't**: Skip reading plan files
✅ **Do**: Read all relevant plan documentation

❌ **Don't**: Ignore existing codebase patterns
✅ **Do**: Follow established patterns exactly

❌ **Don't**: Work outside your role
✅ **Do**: Focus on your specific responsibility

### Quality Anti-Patterns

❌ **Don't**: Leave work incomplete
✅ **Do**: Finish or clearly mark as blocked

❌ **Don't**: Rush through without checking
✅ **Do**: Verify your own work before returning

❌ **Don't**: Ignore spec requirements
✅ **Do**: Reference spec.md continuously

---

## Examples Directory

Reference examples are available:

```
~/.ai/plans/{feature}/../examples/
├── implementation-state-example.md   # Complete state file example
└── in-progress-phase-example.md      # Phase in-progress example
```

Or in the skill directory:
```
claude/skills/feature-implementation/examples/
```

These show expected formats and level of detail.

---

## Integration with Orchestrator

### What You Receive

The orchestrator provides context tailored to your role:
- **Implementer**: Files to modify, technical details, testing strategy
- **Verifier**: Deliverables to check, implementation summary, commands to run
- **State-manager**: Operation type, data to record

### What You Return

Return structured results that the orchestrator can process:
- Clear status (complete/blocked/pass/fail)
- Specific details (files, issues, evidence)
- Actionable information (what to do next)

### When Things Go Wrong

If you can't complete your task:
1. Return what you accomplished
2. Clearly state what's blocked/failed
3. Provide enough detail for the next attempt
4. Don't silently fail or return empty results

---

## Remember

1. **You're part of a system** - Do your role well
2. **Spec is law** - Requirements must be met
3. **State is truth** - Keep it accurate
4. **Be specific** - Vague doesn't help
5. **Complete or document** - No silent failures
