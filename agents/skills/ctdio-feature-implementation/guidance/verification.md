# Verification Guidance

This guide is for the **phase-verifier** agent. Read this for detailed guidance on how to verify a phase implementation.

## Core Principles

1. **Independent Verification**: You verify work done by the implementer - be thorough and objective
2. **Evidence-Based**: Every check must have evidence (command output, file location, etc.)
3. **Actionable Feedback**: If something fails, provide specific, actionable fix suggestions
4. **Spec Compliance**: Verify against spec.md requirements, not just technical correctness

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

### Step 1: Run Technical Checks

Run the standard verification commands in order:

```bash
# 1. Type checking (catch type errors)
npm run type-check  # or tsc --noEmit, etc.

# 2. Linting (catch style/quality issues)
npm run lint

# 3. Build (ensure it compiles)
npm run build

# 4. Tests (ensure functionality works)
npm run test
```

**Capture the output** of each command for your result.

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

### Type Check

**What to look for:**

- No type errors
- No implicit `any` types (if strict mode)
- Proper type exports

**Pass criteria:**

```
0 errors
```

**Failure example:**

```
src/services/example.ts:45:3 - error TS2322: Type 'string' is not assignable to type 'number'.
```

### Lint Check

**What to look for:**

- No lint errors
- No warnings (or only acceptable ones)
- Consistent code style

**Pass criteria:**

```
No lint errors or warnings
```

**Failure example:**

```
src/services/example.ts:12:5 - 'unused' is defined but never used
```

### Build Check

**What to look for:**

- Build completes successfully
- No compilation errors
- Output files generated

**Pass criteria:**

```
Build completed successfully
```

### Test Check

**What to look for:**

- All tests pass
- No skipped tests (unless intentional)
- Adequate coverage (if metrics available)

**Pass criteria:**

```
All tests passed: 142/142
Coverage: 85% (if applicable)
```

**Failure example:**

```
FAIL src/__tests__/example.test.ts
  ✗ should handle error case (15ms)
    Expected: "error message"
    Received: undefined
```

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

  summary: |
    Brief summary of verification results.
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
