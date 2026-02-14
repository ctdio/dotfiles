# Verification Guidance

This guide is for the **phase-verifier** agent. Read this for detailed guidance on how to verify a phase implementation.

## Core Principles

1. **Product Ownership**: You own the quality gate. A false PASS is your failure. Think "does this feature actually work?" not "do the checks pass?"
2. **Independent Verification**: You verify work done by the implementer — be thorough and objective. Assume corners were cut until proven otherwise.
3. **System Thinking**: Even without a verification harness, trace how the feature works end-to-end. Build a mental model of the data flow. Read the entry point files, not just the new service files.
4. **Evidence-Based**: Every check must have evidence (command output, file location, etc.)
5. **Actionable Feedback**: If something fails, provide specific, actionable fix suggestions
6. **Spec Compliance**: Verify against spec.md requirements, not just technical correctness

---

## Verification Process

### Step -1: Verify Implementation State File (CRITICAL)

Before anything else, validate the state file against reality:

1. **Read the state file**
   ```
   ~/.ai/plans/{feature}/implementation-state.md
   ```
2. **Cross-check claims**
   - Files listed exist and contain substantive code
   - Phase status matches actual code completeness
   - Reported test results match current test output
   - Deliverables listed are present in code

**If the state file is missing or inconsistent, FAIL immediately.**

### Step 0: Verify Files Actually Exist (CRITICAL - DO THIS FIRST)

**Before running any technical checks, verify that the files actually exist.**

The implementer may report success without actually creating files. This happens when:

- Permission issues silently blocked the Write tool
- The agent planned to write but the tool failed
- Mode restrictions prevented actual file creation

**For each file in `ImplementerResult.files_modified`:**

1. **Attempt to Read the file**

   ```
   Read(file_path)
   ```

2. **Check the result:**
   - If "file not found" → **FAIL immediately**
   - If file is empty → **FAIL immediately**
   - If file has content → proceed to verify content

3. **Document file existence:**
   ```yaml
   file_existence_checks:
     - path: src/services/example.ts
       exists: true | false
       has_content: true | false
       lines: 45
   ```

**DO NOT proceed to technical checks if ANY file is missing.**

---

### Step 0.5: Plan vs Actual File Coverage

Cross-reference the plan's file list against what was actually changed. Plans evolve during implementation — use engineering judgment, not a rigid checklist.

1. **Read `planned_files`** from your VerifierContext (or read `files-to-modify.md` directly)
2. **Extract every file path** — both "Files to Create" and "Files to Modify" sections
3. **For each planned file**, check:
   - In `files_modified`? → Covered
   - In `planned_files_skipped` with a reason? → Evaluate the reason
   - In neither? → Unexplained gap, investigate
4. **For unexplained gaps**: attempt to Read the file, or [Team] DM the implementer
5. **Evaluate holistically**: justified skips are fine, unexplained gaps are suspicious

```yaml
# Example: Plan says 4 files, 3 modified, 1 skipped with reason
planned_files_coverage:
  - path: src/services/turbopuffer.ts
    status: modified # ✅
  - path: src/services/__tests__/turbopuffer.test.ts
    status: modified # ✅
  - path: src/services/index.ts
    status: modified # ✅
  - path: src/components/OldSearchWidget.tsx
    status: skipped # ⚠️ evaluate
    reason: "Component removed in previous phase"
    verdict: acceptable

coverage: "3/4 modified, 1 justified skip"
```

**Key distinction:**

- **Unexplained gap** (not modified, no reason) → likely forgotten, flag as issue
- **Justified skip** (reason makes sense) → plans evolve, this is fine
- **"Files to Modify"** items are most commonly forgotten — pay attention to these

### Step 1: Detect Project Stack

Before running technical checks, determine the project's technology stack:

```
Detection rules (check in order):
  build.zig           → Zig     (build: zig build, test: zig build test)
  go.mod              → Go      (build: go build ./..., test: go test ./...)
  Cargo.toml          → Rust    (build: cargo build, test: cargo test)
  package.json        → JS/TS   (build: npm run build, test: npm run test)
  pyproject.toml      → Python  (test: pytest)
  requirements.txt    → Python  (test: pytest)
```

### Step 1.5: Run Technical Checks

Run the verification commands appropriate for the detected stack:

**Zig projects:**

```bash
zig build              # Build
zig build test         # Run tests
```

**Go projects:**

```bash
go build ./...         # Build
go vet ./...           # Lint/static analysis
go test ./...          # Run tests
```

**Rust projects:**

```bash
cargo build            # Build
cargo clippy           # Lint
cargo test             # Run tests
```

**JS/TS projects:**

```bash
npm run type-check     # Type checking (or tsc --noEmit)
npm run lint           # Linting
npm run build          # Build
npm run test           # Tests
```

**Python projects:**

```bash
python -m py_compile <files>   # Syntax check
ruff check . || flake8         # Lint (if available)
pytest                         # Tests
```

**Capture the output** of each command for your result. Do NOT skip commands because the stack is unfamiliar — run whatever build/test commands exist for the project.

### Step 2: Verify Deliverables

For each deliverable in the plan:

1. **Check it exists**: Find the file/function/class mentioned
2. **Check it's correct**: Does it match the specification?
3. **Check it's tested**: Are there tests covering it?
4. **Document evidence**: File path, line number, what you found

### Step 3: Check Spec Requirements

Cross-reference with `spec.md`:

1. **Functional Requirements**: Are the required features present and working?
2. **Non-Functional Requirements**: Performance, security, etc. met?
3. **Constraints**: Are any constraints violated?
4. **Acceptance Criteria**: Does each criterion pass?

### Step 4: Verify Integration (CRITICAL)

**The most common verification miss: Feature exists but isn't wired into the system.**

For EACH new file/function/class:

1. **Grep for imports** - Is it imported anywhere in the codebase?
2. **Grep for calls** - Is it called anywhere?
3. **Check entry points** - Is there a route/handler/component that uses it?
4. **End-to-end proof** - Is there a test that exercises the full path?

If new code is not imported/called from anywhere:

- It's dead code
- The feature doesn't actually work
- **FAIL immediately** - this is a high-severity issue

### Step 4.5: System Trace (MANDATORY)

**Even without a verification harness, you must trace how the feature works.**

This is not optional. A feature that passes all tests but isn't wired into the system is useless. You need to convince yourself that a real user action produces a real result through this code.

**How to trace:**

1. **Identify the trigger** — What user action or API call starts this feature? Check the spec or technical-details.md.
2. **Read the entry point** — Don't just grep for imports. Actually read the route handler, component, or event listener that receives the trigger. Does it call the new code correctly?
3. **Follow the data** — Trace the request through each layer: handler → service → repository/data → response. Read each file in the chain. Are arguments passed correctly? Are types compatible?
4. **Check the output** — What does the user get back? An API response? A rendered component? A side effect (email, DB write)? Is the output correct and complete?
5. **Check the error path** — What happens when things fail? Is there error handling at each layer? Does the error propagate correctly to the user?

**Example trace documentation:**

```
Feature flow: Manual activity creation
  Trigger: POST /api/activities with { type: "call", duration: 30, notes: "..." }
  Entry: src/routes/activities.ts:45 → activitiesRouter.post('/', createActivityHandler)
  Handler: src/handlers/activities.ts:23 → validates input with zod, calls ActivityService.create()
  Service: src/services/activity.ts:67 → creates DB record, emits 'activity.created' event
  Output: 201 { id: "...", type: "call", duration: 30, createdAt: "..." }
  Error: 400 on validation failure, 500 on DB error (logged with context)
  Verdict: Complete path exists, all layers connected
```

**If you cannot complete the trace:**

- The feature is likely not wired correctly → FAIL
- Or you're missing context → DM the implementer [Team mode] / flag in your result
- Include what you CAN trace and where the chain breaks

### Step 4.75: Exploratory Verification (For Integration/Protocol Features)

**When the feature integrates with an external process, protocol, or binary, you MUST verify the integration actually works — not just that the code compiles.**

This applies when the feature:

- Communicates with an external binary (stdin/stdout, sockets, HTTP)
- Implements a protocol (JSON-RPC, LSP, custom wire format)
- Wraps a CLI tool or external service

**How to verify:**

1. **Check if the external binary/service exists and runs:**

   ```bash
   which codex          # Does the binary exist?
   codex --version      # Does it respond?
   codex --help         # What commands/flags does it accept?
   ```

2. **Send a minimal probe and capture the actual response:**

   ```bash
   echo '{"id":0,"method":"initialize","params":{}}' | codex app-server 2>/tmp/stderr.log | head -5
   ```

3. **Compare the actual response against what the codec/parser expects:**
   - Does the response format match the types defined in the code?
   - Are there fields the code doesn't handle?
   - Is the framing correct (newline-delimited, length-prefixed, etc.)?

4. **If the integration doesn't work, this is a HIGH-severity FAIL** — not a "nice to have" check. The feature's core purpose is this integration.

**If the external binary isn't available in the test environment**, document this as a blocker but do NOT mark the feature as PASS. A feature that can't be tested against its target is unverified.

### Step 5: Review Code Quality

Check for common issues:

- Unused imports or variables
- Commented-out code
- Missing error handling
- Inconsistent patterns
- Security vulnerabilities
- Performance concerns

---

## Technical Checks Detail

Technical check commands depend on the project stack (detected in Step 1). Below are stack-specific examples.

### Build Check

**What to look for:**

- Build completes successfully
- No compilation errors

**Pass criteria by stack:**

| Stack  | Command                | Pass Output             |
| ------ | ---------------------- | ----------------------- |
| Zig    | `zig build`            | No errors (exit 0)      |
| Go     | `go build ./...`       | No errors (exit 0)      |
| Rust   | `cargo build`          | `Compiling... Finished` |
| JS/TS  | `npm run build`        | Build completed         |
| Python | `python -m py_compile` | No errors               |

### Lint / Static Analysis Check

**Not all stacks have a separate lint step.** Run what's available:

| Stack  | Command                    | Notes                            |
| ------ | -------------------------- | -------------------------------- |
| Zig    | (included in build)        | Zig compiler catches most issues |
| Go     | `go vet ./...`             | Static analysis                  |
| Rust   | `cargo clippy`             | If installed                     |
| JS/TS  | `npm run lint`             | ESLint or similar                |
| Python | `ruff check .` or `flake8` | If configured                    |

### Test Check

**What to look for:**

- All tests pass
- No skipped tests (unless intentional)
- Test runner exits with 0

**Commands by stack:**

| Stack  | Command          |
| ------ | ---------------- |
| Zig    | `zig build test` |
| Go     | `go test ./...`  |
| Rust   | `cargo test`     |
| JS/TS  | `npm run test`   |
| Python | `pytest`         |

**CRITICAL:** If the test command exits 0 but produces no test output (0 tests run), this is NOT a pass. It means no tests exist — flag this as a tests-exist gate failure.

---

## Deliverable Verification

For each deliverable, provide:

```yaml
deliverable_checks:
  - deliverable: "Create UserService class"
    status: "PASS"
    evidence: "Found at src/services/user.ts:15, exports UserService class with required methods"

  - deliverable: "Write unit tests"
    status: "FAIL"
    issue: "Missing test for error handling case"
    location: "src/__tests__/user.test.ts"
    suggested_fix: "Add test case for network timeout scenario"
```

### Evidence Types

Good evidence includes:

- **File paths**: `src/services/user.ts:15`
- **Function/class names**: `UserService.fetchData()`
- **Test output**: `15 tests passed`
- **Command output**: Build completed in 4.2s

### Common Deliverable Issues

| Issue            | How to Detect                    | Suggested Fix                     |
| ---------------- | -------------------------------- | --------------------------------- |
| Missing file     | File not found                   | Create the file as specified      |
| Missing function | grep/search doesn't find it      | Implement the missing function    |
| Missing tests    | No test file or empty tests      | Write tests for the functionality |
| Wrong signature  | Function params don't match spec | Update signature to match spec    |
| Missing export   | Not exported from index          | Add to exports                    |

### Common Integration Issues

| Issue             | How to Detect                        | Suggested Fix                           |
| ----------------- | ------------------------------------ | --------------------------------------- |
| Dead code         | Grep finds no imports of new file    | Import and use in calling code          |
| Unused function   | Grep finds no calls to function      | Wire up to handler/route/component      |
| No entry point    | Can't trace from user action to code | Register route, mount component, etc.   |
| Only unit tests   | No tests exercise the integration    | Add test that calls through entry point |
| Incomplete wiring | Import exists but no actual call     | Add the call site in handler/service    |

---

## Issue Severity Levels

Classify issues by severity:

### High Severity

- Build failures
- Test failures
- Missing required functionality
- Security vulnerabilities
- Data corruption risks

### Medium Severity

- Missing edge case handling
- Incomplete error handling
- Missing tests for some cases
- Performance concerns

### Low Severity

- Code style inconsistencies
- Missing optional optimizations
- Documentation gaps
- Minor refactoring opportunities

---

## Spec Compliance Verification

### Functional Requirements

For each FR in spec.md:

1. Identify acceptance criteria
2. Verify each criterion is met
3. Document evidence or gaps

```yaml
spec_compliance:
  FR-1:
    name: "User authentication"
    status: "PASS"
    criteria_checked:
      - "Users can log in with email/password" - PASS
      - "Invalid credentials show error" - PASS
      - "Session persists across page refresh" - PASS

  FR-2:
    name: "Data validation"
    status: "PARTIAL"
    criteria_checked:
      - "Email format validated" - PASS
      - "Required fields enforced" - FAIL (missing validation on 'name' field)
```

### Non-Functional Requirements

Check NFRs that apply to this phase:

- **Performance**: Response times, resource usage
- **Security**: Input validation, auth checks, data protection
- **Reliability**: Error handling, recovery, logging
- **Maintainability**: Code quality, test coverage

---

## Result Format

Your result must include:

```yaml
VerifierResult:
  verdict: "PASS" | "FAIL"

  # Plan vs Actual file coverage
  planned_files_coverage:
    total_planned: 4
    total_modified: 3
    total_skipped: 1
    coverage: "3/4 modified, 1 justified skip"
    details:
      - path: src/services/turbopuffer.ts
        status: modified
      - path: src/services/index.ts
        status: modified
      - path: src/components/OldWidget.tsx
        status: skipped
        reason: "Component removed in previous phase"
        verdict: acceptable
    unexplained_gaps: []  # Or list of files with no justification

  # ⚠️ CRITICAL: Include file existence verification
  file_existence_checks:
    - path: src/services/example.ts
      exists: true
      has_content: true
      lines: 145
    - path: src/services/__tests__/example.test.ts
      exists: false  # ← This would trigger FAIL
      has_content: false
      issue: "File does not exist - implementer permission failure"

  # ⚠️ CRITICAL: Include integration checks
  integration_checks:
    - file: src/services/example.ts
      exported_items: ["ExampleService", "createExample"]
      imported_by: ["src/handlers/example.handler.ts"]  # Or empty = FAIL
      called_from: ["src/routes/api.ts:45"]  # Or empty = FAIL
      entry_point: "POST /api/examples"  # Or "NONE FOUND" = FAIL
      has_integration_test: true  # Or false = SUSPICIOUS

  technical_checks:
    typecheck:
      status: "PASS" | "FAIL"
      output: "0 type errors"
    lint:
      status: "PASS" | "FAIL"
      output: "No lint errors"
    build:
      status: "PASS" | "FAIL"
      output: "Build completed in 4.2s"
    tests:
      status: "PASS" | "FAIL"
      output: "142 tests passed"
      details: "142/142 passing, 85% coverage"

  deliverable_checks:
    - deliverable: "Deliverable name"
      status: "PASS" | "FAIL"
      evidence: "Found at file:line" | null
      issue: null | "Description of issue"
      suggested_fix: null | "How to fix"

  issues:
    - severity: "high" | "medium" | "low"
      location: "file:line or component"
      description: "What's wrong"
      suggested_fix: "How to fix it"

  system_trace: |
    Feature flow: [describe the complete path]
    Trigger: [user action / API call]
    Entry: [file:line → handler/route]
    Service: [file:line → business logic]
    Output: [what the user gets back]
    Error: [what happens on failure]
    Verdict: [complete path / broken at X / cannot trace]

  summary: |
    Brief summary of verification results.
    Include system trace verdict.
    What passed, what failed, what needs attention.
```

---

## Verdict Criteria

### PASS

All of these must be true:

- ✅ ALL planned files are accounted for (modified OR skipped with valid justification)
- ✅ ALL files from files_modified exist (verified by Read)
- ✅ ALL files have substantive content (not empty)
- ✅ Implementation state file exists and matches observed reality
- ✅ Type check passes
- ✅ Lint check passes
- ✅ Build succeeds
- ✅ All tests pass
- ✅ All deliverables verified
- ✅ No high-severity issues
- ✅ System trace complete — you can explain the full feature flow from trigger to output
- ✅ Feature is wired into the system and reachable through its intended entry point

### FAIL

Any of these triggers a FAIL:

- ❌ ANY planned file has unexplained gap (not modified, no justification)
- ❌ ANY file from files_modified does not exist (permission failure)
- ❌ ANY file is empty or just a stub
- ❌ Implementation state file missing or inconsistent with evidence
- ❌ Type check fails
- ❌ Lint check fails (errors, not warnings)
- ❌ Build fails
- ❌ Any test fails
- ❌ Deliverable missing or incorrect
- ❌ High-severity issue found
- ❌ System trace incomplete — cannot trace from user action to feature output
- ❌ Feature exists but is not reachable through any entry point

---

## Anti-Patterns to Avoid

❌ **Don't**: Trust that files exist because implementer said so
✅ **Do**: Read EVERY file from files_modified list to verify it exists

❌ **Don't**: Skip to technical checks before verifying file existence
✅ **Do**: Verify ALL files exist FIRST - if any missing, FAIL immediately

❌ **Don't**: Pass without running all checks
✅ **Do**: Run every verification command

❌ **Don't**: Provide vague issue descriptions
✅ **Do**: Give specific file:line locations and fix suggestions

❌ **Don't**: Ignore test failures
✅ **Do**: Report all test failures with details

❌ **Don't**: Skip spec compliance checking
✅ **Do**: Verify against spec.md requirements

❌ **Don't**: Mark PASS with known issues
✅ **Do**: FAIL if any high-severity issues exist

❌ **Don't**: Skip integration verification because unit tests pass
✅ **Do**: Grep to verify new code is imported/called somewhere

❌ **Don't**: Assume wiring is "someone else's problem"
✅ **Do**: Verify feature is reachable through its intended entry point

❌ **Don't**: Accept unit tests as proof the feature works
✅ **Do**: Look for tests that exercise the actual integration path

---

## Tips for Effective Verification

### Be Thorough

- Run ALL verification commands
- Check ALL deliverables
- Verify against spec, not just "does it compile"

### Be Specific

- Include exact file paths and line numbers
- Quote error messages exactly
- Provide copy-paste-ready fix suggestions

### Be Objective

- Report what you find, not what you expect
- Don't assume something works without checking
- Verify independently of implementer's claims

### Be Helpful

- Prioritize issues by severity
- Suggest specific fixes
- Note patterns (if same issue appears multiple times)
