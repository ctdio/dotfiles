# Testing Guidance

This guide is for the **phase-tester** agent. Read this for detailed guidance on how to run custom verification tests against a phase implementation.

## Core Principles

1. **Graceful Degradation**: Missing capabilities are SKIPPED, not FAIL. The environment may not have every tool.
2. **Real Behavior Testing**: You verify the feature works from the outside — not that it compiles or passes unit tests (verifier handles that).
3. **Evidence-Based Results**: Every test result must include specific output, expected vs actual, and actionable fix suggestions.
4. **Non-Destructive**: You never modify the implementation. You create temporary scripts, run them, and clean up.
5. **Capability-First**: Detect what you can run BEFORE attempting anything. Don't waste time on doomed tests.

---

## Capability Detection Process

### Step-by-Step Detection

Run all capability checks before executing any tests. This prevents wasted effort on tests that can't complete.

```
1. Read package.json from project root
   → Extract devDependencies and dependencies
   → Note scripts.dev command (for server startup)
   → Note scripts.test command (for test runner detection)

2. Check eval script runner:
   → "vitest" in dependencies? → npx vitest --version
   → "jest" in dependencies? → npx jest --version
   → Neither? → node is always available as fallback
   → Record: { runner: "vitest" | "jest" | "node", available: true }

3. Check dev server:
   → Determine port (harness config > package.json > 3000)
   → curl -s -o /dev/null -w "%{http_code}" http://localhost:{port}/
   → Running? → record "already_running"
   → Not running? → Can we start it? (see Dev Server Management)
   → Record: { available: true | false, management: "already_running" | "started_by_tester" | "not_available" }

4. Check browser testing:
   → "@playwright/test" in devDependencies?
   → npx playwright install --dry-run (check if browsers are ready)
   → Record: { available: true | false, reason: null | "not installed" | "browsers missing" }
```

### Detection Results Template

```yaml
capabilities_detected:
  eval_scripts:
    available: true
    runner: "vitest"
    version: "1.2.3"
  api_smoke_tests:
    available: true
    server_management: "already_running"
    port: 3000
  browser_tests:
    available: false
    reason: "@playwright/test not in package.json"
```

---

## Eval Script Execution

Eval scripts test specific behaviors by importing from the actual implementation and asserting on outputs.

### Creating Eval Scripts

1. **Read the harness**: Parse each `### Eval:` section from the verification harness
2. **Read the implementation**: Before writing the script, read the actual source files to get correct:
   - Import paths (relative from scratchpad or absolute)
   - Export names (function names, class names)
   - Type signatures
3. **Create temp file**: Write the script to the scratchpad directory
4. **Use correct runner syntax**: Match the runner detected in capability check

### Execution Process

```
For each eval in verification harness:

  1. Parse the eval section:
     - Name, runner preference, purpose, script outline, expected outcome

  2. Read implementation files referenced by the eval:
     - Get actual export names and paths
     - Get actual function signatures

  3. Create the eval script in scratchpad:
     - /tmp/claude-{uid}/{session}/scratchpad/{eval-name}.test.ts (for vitest/jest)
     - /tmp/claude-{uid}/{session}/scratchpad/{eval-name}.ts (for node)

  4. Run the script:
     - vitest: npx vitest run {script-path} --reporter=verbose
     - jest: npx jest {script-path} --verbose
     - node: npx tsx {script-path} (for .ts) or node {script-path} (for .js)

  5. Capture output:
     - stdout and stderr
     - Exit code (0 = PASS, non-zero = FAIL)

  6. Record result:
     - PASS: Output matches expected outcome
     - FAIL: Assertion failure or runtime error

  7. Clean up:
     - Remove temp script file
```

### Import Path Handling

When creating eval scripts that import from the project:

```typescript
// If project uses path aliases (check tsconfig.json):
import { SearchService } from "@/services/search";

// If no aliases, use relative paths from scratchpad:
import { SearchService } from "../../../../src/services/search";

// Prefer the project's own patterns — check existing test files for import style
```

### Runner-Specific Patterns

**vitest:**

```typescript
import { describe, it, expect } from "vitest";
import { processData } from "../../src/services/processor";

describe("processData eval", () => {
  it("returns expected shape", () => {
    const result = processData({ input: "test" });
    expect(result).toHaveProperty("output");
    expect(result.output).toBeTypeOf("string");
  });
});
```

**jest:**

```typescript
import { processData } from "../../src/services/processor";

describe("processData eval", () => {
  it("returns expected shape", () => {
    const result = processData({ input: "test" });
    expect(result).toHaveProperty("output");
    expect(typeof result.output).toBe("string");
  });
});
```

**node (plain script):**

```typescript
import { processData } from "../../src/services/processor";

const result = processData({ input: "test" });

if (!result.output || typeof result.output !== "string") {
  console.error(
    "FAIL: Expected result.output to be a string, got:",
    result.output,
  );
  process.exit(1);
}

console.log("PASS: processData returns correct shape");
process.exit(0);
```

---

## API Smoke Test Execution

API smoke tests verify that endpoints respond correctly with expected status codes and response shapes.

### Execution Process

```
For each smoke test in verification harness:

  1. Parse the smoke test section:
     - Method, URL, body, expected status, response checks

  2. Verify server is available:
     - If server_management is "not_available" → skip all API tests
     - If server just started, wait for health check to pass

  3. Execute the request:
     - Use curl with timeout:
       curl -s -w "\n%{http_code}" -X {METHOD} \
         -H "Content-Type: application/json" \
         -d '{body}' \
         --max-time 10 \
         http://localhost:{port}{url}

  4. Parse response:
     - Last line = status code
     - Everything before = response body

  5. Check status code:
     - Matches expected_status? → status check PASS
     - Doesn't match? → status check FAIL (high severity if 500)

  6. Run response checks:
     - Parse response body as JSON
     - For each check in harness, verify the assertion
     - Common checks:
       - "Body contains X array" → jq '.X | length > 0'
       - "Body has field X" → jq '.X != null'
       - "Body.X equals Y" → jq '.X == "Y"'

  7. Record result per endpoint
```

### Timeout Handling

```
Request timeout: 10 seconds per request (default)
  → If harness specifies a different timeout, use that
  → On timeout: record as FAIL with "Request timed out after Xs"

Server startup timeout: 30 seconds (default)
  → Poll health endpoint every 2 seconds
  → On timeout: server_management = "not_available", skip API tests
```

### Error Response Handling

```
5xx responses → high severity (server error)
4xx responses → check if expected:
  → If expected_status is 400 and actual is 400 → PASS
  → If expected_status is 200 and actual is 404 → FAIL (medium severity)
Connection refused → server not running, mark as SKIPPED
Timeout → FAIL with evidence (slow response)
```

---

## Browser Test Execution

Browser tests verify UI behavior using Playwright in headless mode.

### Execution Process

```
For each browser test in verification harness:

  1. Parse the test section:
     - Name, page, steps, assertions

  2. Verify playwright is available:
     - If capability detection marked unavailable → skip all browser tests

  3. Create test script in scratchpad:
     - Use Playwright test syntax
     - Always use headless mode
     - Set reasonable timeouts (30s default)

  4. Run the test:
     - npx playwright test {script-path} --reporter=list

  5. On failure:
     - Capture screenshot if possible
     - Include full error output

  6. Clean up:
     - Remove temp script
```

### Playwright Test Template

```typescript
import { test, expect } from "@playwright/test";

test("{test-name}", async ({ page }) => {
  await page.goto("http://localhost:{port}{path}");

  // Steps from harness
  await page.fill('input[name="query"]', "test search");
  await page.click('button[type="submit"]');

  // Assertions from harness
  await expect(page.locator(".results")).toBeVisible();
  await expect(page.locator(".results-count")).toContainText("results");
});
```

### Screenshot Capture

```
On test failure:
  1. Attempt: await page.screenshot({ path: '/tmp/screenshot-{test-name}.png' })
  2. If screenshot captured: include path in TesterResult
  3. If screenshot fails: note "screenshot capture failed" in output
```

---

## Dev Server Management

### Detection

```bash
# Check if server is running on the configured port
curl -s -o /dev/null -w "%{http_code}" http://localhost:{port}/

# If response (any status) → already running
# If connection refused → not running
```

### Starting the Server

```bash
# 1. Determine start command (priority order):
#    a. verification-harness.md "Start Command" field
#    b. package.json scripts.dev
#    c. Default: npm run dev

# 2. Start in background, capture PID
{start_command} > /tmp/dev-server-stdout.log 2>&1 &
DEV_SERVER_PID=$!

# 3. Wait for health (poll every 2s, max 30s)
for i in $(seq 1 15); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:{port}/ 2>/dev/null)
  if [ "$STATUS" != "000" ]; then
    echo "Server ready (status: $STATUS)"
    break
  fi
  sleep 2
done

# 4. If still not responding after 30s → SKIPPED
```

### Health Endpoint

Priority for health check URL:

1. verification-harness.md "Health Endpoint" field
2. `http://localhost:{port}/api/health`
3. `http://localhost:{port}/health`
4. `http://localhost:{port}/` (root — any response means alive)

### Stopping the Server

```bash
# ONLY stop if we started it (server_was_running was false)
if [ "$SERVER_STARTED_BY_US" = true ]; then
  kill $DEV_SERVER_PID 2>/dev/null
  wait $DEV_SERVER_PID 2>/dev/null
fi
# If server was already running, leave it alone
```

### Port Detection

Priority for port number:

1. verification-harness.md "Port" field
2. Parse from package.json `scripts.dev` (look for `--port {N}` or `-p {N}`)
3. Parse from `.env` or `.env.local` (`PORT=`)
4. Default: `3000`

---

## Issue Severity Classification

### High Severity

Triggers FAIL verdict. Feature is demonstrably broken.

| Issue                             | Example                        |
| --------------------------------- | ------------------------------ |
| Server error on expected endpoint | POST /api/search returns 500   |
| Eval script assertion failure     | Expected array, got undefined  |
| Browser test crash                | Page navigation timeout        |
| Data corruption                   | POST creates duplicate records |
| Missing endpoint                  | Expected route returns 404     |

### Medium Severity

Noted in issues but doesn't alone trigger FAIL.

| Issue             | Example                                  |
| ----------------- | ---------------------------------------- |
| Partial response  | Status 200 but missing optional fields   |
| Timing issue      | Response takes 5s (harness expects < 2s) |
| Flaky test        | Passes 2/3 runs                          |
| Warning in output | Deprecation warning during eval          |

### Low Severity

Suggestion only, included for completeness.

| Issue                | Example                                            |
| -------------------- | -------------------------------------------------- |
| Slow response        | Over general threshold but no specific requirement |
| Console warnings     | Non-critical warnings in browser console           |
| Missing nice-to-have | Optional response field absent                     |

---

## Anti-Patterns to Avoid

**Testing Anti-Patterns:**

- **Don't**: Fail because a capability isn't available
  **Do**: SKIP with documented reason

- **Don't**: Modify any implementation files
  **Do**: Create temp scripts in scratchpad only

- **Don't**: Install missing packages or browsers
  **Do**: Report what's missing as SKIPPED

- **Don't**: Leave orphan processes (dev servers, background tasks)
  **Do**: Track PIDs and clean up in all code paths

- **Don't**: Create scripts with assumed import paths
  **Do**: Read actual files first to get correct paths and exports

- **Don't**: Run API tests without confirming server health
  **Do**: Always check health endpoint before running smoke tests

**Reporting Anti-Patterns:**

- **Don't**: Vague descriptions ("it didn't work")
  **Do**: Specific evidence (actual status 500, expected 200, response body: {...})

- **Don't**: Report SKIPPED as FAIL
  **Do**: SKIPPED means "couldn't test", FAIL means "tested and failed"

- **Don't**: Omit suggested fixes
  **Do**: Every issue must have an actionable suggested_fix

- **Don't**: Duplicate verifier/reviewer work
  **Do**: Focus on behavioral verification only

---

## TesterResult Examples

### Example: PASS (all capabilities ran)

```yaml
TesterResult:
  verdict: "PASS"

  capabilities:
    eval_scripts:
      status: "PASS"
      reason: null
      scripts_created:
        - name: "search-service-eval"
          file: "/tmp/scratchpad/search-service-eval.test.ts"
          status: "PASS"
          output: "1 test passed (0.3s)"
      issues: []

    api_smoke_tests:
      status: "PASS"
      reason: null
      server_management: "already_running"
      tests_run:
        - endpoint: "POST /api/search"
          expected_status: 200
          actual_status: 200
          response_checks:
            - check: "Body contains results array"
              status: "PASS"
            - check: "Results have id and title fields"
              status: "PASS"
      issues: []

    browser_tests:
      status: "SKIPPED"
      reason: "@playwright/test not in package.json"
      tests_run: []
      issues: []

  issues: []

  summary: |
    Eval scripts: 1/1 passed. API smoke tests: 1/1 passed (server already running).
    Browser tests: skipped (playwright not installed).
    Feature behaves correctly for all testable scenarios.
```

### Example: FAIL (API endpoint broken)

```yaml
TesterResult:
  verdict: "FAIL"

  capabilities:
    eval_scripts:
      status: "PASS"
      reason: null
      scripts_created:
        - name: "search-service-eval"
          file: "/tmp/scratchpad/search-service-eval.test.ts"
          status: "PASS"
          output: "1 test passed (0.3s)"
      issues: []

    api_smoke_tests:
      status: "FAIL"
      reason: null
      server_management: "started_by_tester"
      tests_run:
        - endpoint: "POST /api/search"
          expected_status: 200
          actual_status: 500
          response_checks:
            - check: "Body contains results array"
              status: "FAIL"
      issues:
        - severity: "high"
          description: "Search endpoint returns 500"
          evidence: 'Response: {"error": "Cannot read properties of undefined (reading ''query'')"}'
          suggested_fix: "Request body parsing may be missing. Check if body-parser middleware is configured for the route."

    browser_tests:
      status: "SKIPPED"
      reason: "@playwright/test not in package.json"
      tests_run: []
      issues: []

  issues:
    - severity: "high"
      capability: "api_smoke_tests"
      description: "Search endpoint returns 500 instead of 200"
      evidence: 'Response: {"error": "Cannot read properties of undefined (reading ''query'')"}'
      suggested_fix: "Request body parsing may be missing. Check if body-parser middleware is configured for the route."

  summary: |
    Eval scripts: 1/1 passed. API smoke tests: 0/1 passed — POST /api/search returns 500.
    Browser tests: skipped. FAIL due to broken search endpoint.
```

### Example: SKIPPED (nothing could run)

```yaml
TesterResult:
  verdict: "SKIPPED"

  capabilities:
    eval_scripts:
      status: "SKIPPED"
      reason: "Neither vitest nor jest found in package.json"
      scripts_created: []
      issues: []

    api_smoke_tests:
      status: "SKIPPED"
      reason: "Dev server not running, no scripts.dev in package.json to start it"
      server_management: "not_available"
      tests_run: []
      issues: []

    browser_tests:
      status: "SKIPPED"
      reason: "@playwright/test not in package.json"
      tests_run: []
      issues: []

  issues: []

  summary: |
    All capabilities skipped: no test runner available, no dev server,
    no playwright. Environment does not support custom verification tests.
    This is non-blocking — verifier and reviewer results determine pass/fail.
```

---

## Tips for Effective Testing

### Read Before You Write

Before creating any eval script:

1. Read the actual implementation files referenced in the harness
2. Get correct import paths, export names, function signatures
3. Check existing test files for import patterns and test utilities

### Be Conservative

- SKIP rather than guess
- Short timeouts rather than hanging
- Simple assertions rather than complex chains
- Clean up always, even on failure

### Focus on Behavioral Verification

You are NOT a unit tester. You verify:

- Does the endpoint actually respond?
- Does the data have the right shape?
- Does the UI render the expected content?
- Does the feature work end-to-end?

Leave code quality, patterns, and technical checks to the reviewer and verifier.
