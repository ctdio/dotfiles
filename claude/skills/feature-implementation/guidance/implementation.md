# Implementation Guidance

This guide is for the **phase-implementer** agent. Read this for detailed guidance on how to implement a phase.

## Core Principles

1. **Spec is Law**: The `spec.md` file defines requirements that MUST be met - reference it continuously
2. **TDD First**: Write tests BEFORE implementation code
3. **Follow Existing Patterns**: Match the codebase's conventions exactly
4. **Small Commits of Working Code**: Each change should leave the codebase in a working state

---

## TDD Approach (CRITICAL)

### Write Tests FIRST

Before writing any implementation code:

1. **Read the Testing Requirements** from the plan's `testing-strategy.md`
2. **Write unit tests** for the functionality you're about to implement
3. **Write integration tests** for the flows you're building
4. **Tests should initially FAIL** (red) - this confirms they're testing the right thing
5. **Use tests to clarify your understanding** of requirements

### The Red-Green-Refactor Cycle

```
1. RED:    Write a failing test that defines expected behavior
2. GREEN:  Write minimal code to make the test pass
3. REFACTOR: Clean up while keeping tests green
```

### Test Status Tracking

Track each test's status in your result:

```markdown
**Unit Tests**:
- ✅ `test_function_happy_path` - Written, passing
- ✅ `test_function_edge_case` - Written, passing
- 🔴 `test_component_behavior` - Written, failing (implementing now)
- ⏳ `test_error_handling` - Not yet written

**Integration Tests**:
- ✅ `test_api_endpoint_success` - Written, passing
- 🔴 `test_flow_complete` - Written, failing (implementing now)
```

### What Tests to Write

From the plan's `testing-strategy.md`, identify:
- **Unit tests**: Individual functions, classes, modules
- **Integration tests**: Multiple components working together
- **Edge cases**: Boundary conditions, error scenarios
- **Regression tests**: Prevent bugs from recurring

---

## Implementation Process

### Step 1: Understand the Context

Before coding, ensure you understand:
- The deliverables from `files-to-modify.md`
- The approach from `technical-details.md`
- The testing requirements from `testing-strategy.md`
- The architectural patterns from `architecture-decisions.md`

### Step 2: Read Reference Files

The plan lists reference files to follow. Read them to understand:
- Naming conventions
- Code structure patterns
- Error handling approaches
- Testing patterns

### Step 3: Write Tests (TDD)

For each deliverable:
1. Identify what tests are needed
2. Write the test file first
3. Run tests to confirm they fail
4. Document test status

### Step 4: Implement to Make Tests Pass

- Write the minimal code to make tests pass
- Follow the patterns from reference files exactly
- Cross-reference `spec.md` to ensure requirements are met

### Step 5: Refactor While Green

- Clean up code while keeping tests passing
- Extract common patterns
- Improve naming
- Add necessary comments (only where logic isn't self-evident)

---

## Coding Standards

### Follow Existing Patterns

**CRITICAL**: Match the codebase's existing patterns exactly.

- If the codebase uses classes, use classes
- If the codebase uses functions, use functions
- Match naming conventions (camelCase, snake_case, etc.)
- Match file organization patterns
- Match error handling patterns

### Code Quality Checklist

Before marking a deliverable complete:

- [ ] Tests written and passing
- [ ] Follows codebase patterns exactly
- [ ] No unused imports or variables
- [ ] No commented-out code
- [ ] Type-safe (if TypeScript/typed language)
- [ ] Error handling matches project patterns
- [ ] Meets spec requirements

---

## Handling Deviations

Sometimes you need to deviate from the plan. When this happens:

1. **Document the deviation** in your result:
   ```yaml
   deviations:
     - description: "Added retry logic not in plan"
       justification: "API has occasional timeouts, existing services use this pattern"
   ```

2. **Only deviate when necessary**:
   - Following existing codebase patterns that differ from plan
   - Fixing issues discovered during implementation
   - Technical constraints not anticipated in planning

3. **Never deviate from spec requirements** without explicit approval

---

## Handling Blockers

If you encounter something that prevents completion:

1. **Document the blocker clearly**:
   ```yaml
   status: "blocked"
   blockers:
     - type: "dependency"
       description: "Requires auth service changes not in this phase"
       suggested_resolution: "Complete auth changes first or mock for now"
   ```

2. **Complete what you can** - Don't let one blocker stop all progress

3. **Suggest workarounds** if possible

---

## Fix Context (Retry Attempts)

If you receive `fix_context`, you're fixing issues from a previous attempt:

```yaml
fix_context:
  attempt: 2
  max_attempts: 3
  previous_issues:
    - severity: "high"
      location: "src/services/turbopuffer.ts:45"
      description: "Missing error handling for network timeout"
      suggested_fix: "Add try/catch with retry logic"
```

**When fixing:**
1. Address ALL issues listed, starting with highest severity
2. Re-run tests after each fix
3. Don't introduce new issues while fixing
4. If you can't fix an issue, document why

---

## Anti-Patterns to Avoid

### Testing Anti-Patterns

❌ **Don't**: Write implementation code before tests
✅ **Do**: Write tests FIRST (TDD), then implement to make them pass

❌ **Don't**: Skip tests because "it's simple"
✅ **Do**: Write tests for all functionality, especially edge cases

❌ **Don't**: Write tests that always pass (testing nothing)
✅ **Do**: Verify tests fail before implementation (red-green-refactor)

### Implementation Anti-Patterns

❌ **Don't**: Invent new patterns when existing patterns exist
✅ **Do**: Follow existing codebase patterns exactly

❌ **Don't**: Add features or refactoring beyond the deliverables
✅ **Do**: Implement exactly what's specified, nothing more

❌ **Don't**: Leave TODO comments or incomplete code
✅ **Do**: Complete each deliverable fully before moving on

❌ **Don't**: Ignore linter/type errors
✅ **Do**: Fix all errors as you go

### Communication Anti-Patterns

❌ **Don't**: Hide blockers or challenges
✅ **Do**: Document blockers clearly in your result

❌ **Don't**: Deviate from plan silently
✅ **Do**: Document all deviations with justification

---

## Result Format

Your result must include:

```yaml
ImplementerResult:
  status: "complete" | "blocked"

  files_modified:
    - path: src/services/example.ts
      action: created | modified
      summary: "Brief description of changes"

  deliverables_completed:
    - "Deliverable 1 name"
    - "Deliverable 2 name"

  tests_written:
    unit_tests:
      - name: "test_function_name"
        status: "passing" | "failing"
        file: "src/__tests__/example.test.ts"
    integration_tests:
      - name: "test_flow_name"
        status: "passing"
        file: "src/__tests__/integration/example.test.ts"

  implementation_notes: |
    Brief notes about implementation decisions,
    patterns followed, etc.

  deviations:
    - description: "What was different from plan"
      justification: "Why the change was needed"

  blockers: null  # or list of blockers if status is "blocked"
```

---

## Tips for Effective Implementation

### Chunk Size Matters

Break deliverables into chunks that:
- Take 30-60 minutes to implement
- Have clear completion criteria
- Can be tested independently
- Leave codebase in working state

### Test as You Go

Don't save all testing for the end:
- Write tests for each chunk
- Run tests before moving to next chunk
- Fix failures immediately

### Read Before Write

Before modifying any existing file:
- Read and understand the current code
- Identify patterns to follow
- Note any dependencies

### Verify Continuously

After each significant change:
- Run the test suite
- Check for type errors
- Verify linting passes
