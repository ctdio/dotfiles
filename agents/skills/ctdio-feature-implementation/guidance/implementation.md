# Implementation Guidance

This guide is for the **phase-implementer** agent. Read this for detailed guidance on how to implement a phase.

## Core Principles

1. **Spec is Law**: The `spec.md` file defines requirements that MUST be met
2. **Tests Define the Target**: Write failing tests FIRST that assert expected behavior, then implement to make them pass. Tests that never failed prove nothing.
3. **Real Tests, Not Mock Theater**: Test through real entry points with real infrastructure. Only mock external third-party APIs.
4. **Follow Existing Patterns**: Match the codebase's conventions exactly
5. **Ship Working Code**: Every deliverable must be wired up and functional

---

## Testing Philosophy: Real Tests, Not Mock Theater

### The #1 Rule: Test Real Behavior

The highest-value test is one that exercises your code the way it will actually be used. A test full of mocks proves your mocks work, not your code.

**Test value hierarchy:**

| Test Type                                  | Value   | When to Use                                                                             |
| ------------------------------------------ | ------- | --------------------------------------------------------------------------------------- |
| Integration test through real entry point  | Highest | **Default for everything** — API routes, service calls, UI interactions                 |
| Integration test with real DB/dependencies | High    | Data layer, queries, transactions                                                       |
| Unit test of pure logic (no mocks)         | Medium  | Algorithms, transformers, validators, pure functions                                    |
| Unit test with mocks                       | **Low** | ONLY when you literally cannot run the real dependency (external paid API, SMS gateway) |

### Set Up Real Infrastructure First

**Before writing integration tests, ensure the environment is ready.** This is your responsibility — don't skip it.

If the phase includes schema changes (new tables, columns, indexes):

```
Run the appropriate migration command:
  - prisma db push / npx prisma migrate dev    → then npx prisma generate
  - drizzle-kit push / drizzle-kit migrate     → then drizzle-kit generate (if needed)
  - knex migrate:latest
  - python manage.py migrate
  - rails db:migrate
  - Any project-specific migration scripts
```

If the phase needs new dependencies:

```
Install them:
  - npm install {package}
  - pip install {package}
  - Check package.json/requirements.txt for the project's package manager
```

If tests need seed data or fixtures, set them up. The goal: when your integration test runs, it hits a **real database with the correct schema**, not a mock.

### What NOT to Mock

**Do not mock these — use the real thing:**

- Database/ORM (Prisma, Drizzle, etc.) — use a real test database (run migrations first!)
- Internal services and repositories — test them together
- File system operations — use a temp directory
- Your own code — if you're mocking your own modules, your test is worthless

**Only mock these:**

- External third-party APIs you don't control (Stripe, SendGrid, Twilio)
- Time-sensitive operations (use fake timers, not mocked functions)
- Non-deterministic inputs (random IDs, current timestamps)

### What Good Tests Look Like

```typescript
// ✅ HIGH VALUE: Tests the real API endpoint with real service layer
describe("POST /api/users", () => {
  it("creates a user and returns it", async () => {
    const response = await request(app)
      .post("/api/users")
      .send({ name: "Alice", email: "alice@example.com" });

    expect(response.status).toBe(201);
    expect(response.body.name).toBe("Alice");

    // Verify it actually hit the database
    const user = await db.user.findUnique({
      where: { email: "alice@example.com" },
    });
    expect(user).not.toBeNull();
  });
});

// ✅ HIGH VALUE: Tests pure logic without mocks
describe("validateEmail", () => {
  it("rejects invalid formats", () => {
    expect(validateEmail("not-an-email")).toBe(false);
    expect(validateEmail("also@bad")).toBe(false);
  });
});
```

```typescript
// ❌ LOW VALUE: Mocks everything, proves nothing
describe("UserService", () => {
  it("creates a user", async () => {
    const mockRepo = {
      create: vi.fn().mockResolvedValue({ id: 1, name: "Alice" }),
    };
    const service = new UserService(mockRepo);
    const result = await service.createUser({ name: "Alice" });
    expect(mockRepo.create).toHaveBeenCalledWith({ name: "Alice" }); // Testing the mock!
  });
});
```

### Test Strategy Per Phase

- **Data/Foundation phases**: Run schema migrations first, then integration tests against real DB — create, read, update, delete actual records
- **API/Service phases**: Hit the real API endpoints, verify real responses, check database state
- **UI phases**: Render real components, simulate real user interactions, verify real state changes
- **Integration phases**: End-to-end tests through the full stack

### Minimum Test Requirements

For every phase, you MUST have:

1. At least one integration test that exercises the real code path through its entry point
2. Unit tests (without mocks) for any non-trivial pure logic
3. Edge case coverage for error paths and boundary conditions

You should NOT have:

- Tests where >50% of the code is mock setup
- Tests that only verify mock calls were made (`.toHaveBeenCalledWith`)
- Tests that pass even when the implementation is broken

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

### Step 3: Set Up Environment

Before writing tests, ensure the environment supports real integration testing:

- **Schema changes**: If the phase modifies the database, run migrations now (`prisma db push`, `drizzle-kit push`, `knex migrate:latest`, etc.) and codegen (`npx prisma generate`)
- **Dependencies**: If the phase needs new packages, install them
- **Fixtures**: If tests need seed data, set it up

### Step 4: Write Failing Tests (Red)

For each deliverable, write tests that describe the **expected behavior** before writing the implementation:

1. Read `testing_strategy` and `files_to_modify` to understand what each deliverable should do
2. Write integration tests through real entry points (API routes, service methods, components)
3. Write unit tests for pure logic (no mocks)
4. **Run tests — they MUST fail.** If they pass before you've implemented anything, they aren't testing real behavior.
5. Tests that never failed prove nothing — the red phase is what gives them value.

```
Example TDD flow for an API endpoint:

  1. Write test: POST /api/users → expects 201, user in DB
  2. Run test → FAILS (route doesn't exist yet)           ← RED
  3. Create route handler, service, schema
  4. Run test → PASSES (real user created in real DB)      ← GREEN
```

### Step 5: Implement to Make Tests Pass (Green)

- Write the minimal code to make each failing test pass
- Follow the patterns from reference files exactly
- Cross-reference `spec.md` to ensure requirements are met
- Run tests after each deliverable — watch them go from red to green

### Step 6: Clean Up While Green

- Clean up code while keeping tests passing
- Extract common patterns
- Improve naming
- Add necessary comments (only where logic isn't self-evident)

---

## Context Management

**Context is a finite resource.** The implementer agent has a limited context window. Consuming it all on upfront reading leaves nothing for implementation and debugging.

### Read On Demand, Not All at Once

- **Reference files**: Read them when you're about to implement the deliverable that needs them, not all at startup
- **Targeted grep**: When you only need one function signature or type, grep for it instead of reading the entire file
- **Test output**: After confirming tests pass, note the result (pass/fail + key errors) but don't retain full output — re-run if you need details later

### Plan for Partial Returns on Large Phases

- If a phase has **8+ files** (create + modify combined), plan to return partial after ~4-5 files
- Complete a natural batch of deliverables, verify tests pass, then checkpoint
- The orchestrator will spawn a fresh agent with your completed work as context

### Signs You Should Return Partial

- You've done many file reads, test runs, and fix iterations
- You've completed 4-5+ files and significant work remains
- Your responses are getting shorter or less precise (context pressure)
- You're about to start a major new deliverable that will require substantial reading

### What a Good Partial Return Looks Like

- All completed deliverables have passing tests
- `remaining_deliverables` is specific enough for a fresh agent to continue
- `completed_summary` mentions key files created, patterns followed, and any gotchas
- The codebase builds and type-checks with current changes

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

❌ **Don't**: Mock internal services, repositories, or your own code
✅ **Do**: Test real code paths with real dependencies

❌ **Don't**: Write tests where most of the code is mock setup
✅ **Do**: Write tests that exercise the real entry point (API route, service call, component render)

❌ **Don't**: Assert on mock calls (`.toHaveBeenCalledWith`) as your primary assertion
✅ **Do**: Assert on actual outputs, database state, or response bodies

❌ **Don't**: Skip tests because "it's simple"
✅ **Do**: Write integration tests for all significant functionality

❌ **Don't**: Mock the database because you didn't run migrations
✅ **Do**: Run schema migrations (prisma db push, etc.) first, then test against the real DB

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

### Integration Anti-Patterns

❌ **Don't**: Consider a feature "done" when unit tests pass
✅ **Do**: Verify the feature is wired up and works through its entry point

❌ **Don't**: Write code that nothing imports or calls (dead code)
✅ **Do**: Connect your implementation to the system that will use it

❌ **Don't**: Test only in isolation with mocked dependencies
✅ **Do**: Have at least some tests that exercise the actual integration

❌ **Don't**: Assume wiring will happen "later" or "in another phase"
✅ **Do**: If the plan says implement X, wire X up so it can be used

---

## Result Format

Your result must include:

```yaml
ImplementerResult:
  status: "complete" | "partial" | "blocked"

  files_modified:
    - path: src/services/example.ts
      action: created | modified
      summary: "Brief description of changes"

  deliverables_completed:
    - "Deliverable 1 name"
    - "Deliverable 2 name"

  # Only when status is "partial"
  remaining_deliverables: null  # or list:
  # remaining_deliverables:
  #   - "Wire service into search handler"
  #   - "Add integration tests for search endpoint"

  # Only when status is "partial"
  completed_summary: null  # or string:
  # completed_summary: "Created TurbopufferService with connection pooling, wrote unit tests"

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

### Track Every File From the Plan

Before writing any code:

1. Read `files_to_modify` from your context
2. Create a TodoWrite entry for **each individual file** — one per file, not grouped by concept
3. As you implement, check each file off
4. At the end, reconcile: every planned file should be either DONE or SKIPPED with a reason in `planned_files_skipped`

Plans evolve during implementation — you may discover a file isn't needed, or that you need a different file. That's fine. **Just document it.** An unexplained gap looks like you forgot; an explained skip looks like engineering judgment.

**"Files to Modify" entries are the most commonly missed.** These are existing files where you need to add something (a button in a component, an import in a barrel, a route in a router). They're easy to overlook when you're focused on the core logic.

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

### Verify Integration (CRITICAL)

**The most common failure: Feature works in isolation but isn't wired into the system.**

Before considering any feature "done":

1. **Grep for imports** - Is your new code imported anywhere?
2. **Grep for usage** - Is your new code called anywhere?
3. **Check entry points** - Is the feature reachable via API/UI/trigger?
4. **Test through entry point** - Not just unit tests, but actual end-to-end path

If your code isn't called from anywhere, you've created dead code. The feature doesn't work until it's wired up.

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
