# Bug Bot

Perform deep research on code changes to identify bugs through systematic analysis using specialized subagents. This command spawns multiple research agents that investigate different aspects of the code to find valid, actionable bugs.

## Overview
Bug Bot differs from branch-review by focusing specifically on **functional bugs** rather than code quality issues. It uses multiple subagents to perform deep, specialized research on different bug categories.

## Steps:
1. Use Graphite to understand the current stack and identify the parent branch
2. Get the diff between current branch and its parent branch
3. Identify all changed files and categorize them by type (frontend, backend, utilities, etc.)
4. Spawn specialized subagents to research specific bug categories
5. Collect and validate findings from subagents
6. Generate a comprehensive bug report with only validated issues

## Commands to run:
```bash
# Get current stack information
gt log --stack

# Get the parent branch of current branch
gt branch info

# Get current branch name
git branch --show-current

# Get detailed diff with context against parent branch
git diff [parent-branch]..HEAD

# Get list of changed files
git diff --name-only [parent-branch]..HEAD

# Get commit messages to understand intent
git log --oneline [parent-branch]..HEAD
```

## Subagent Research Strategy

**CRITICAL**: Use the Task tool to spawn multiple specialized subagents in parallel for thorough bug investigation. Each subagent should:
- Focus on a specific bug category
- Perform deep code analysis and research
- **VALIDATE findings through rigorous investigation before reporting**
- Only report **confirmed bugs**, not potential issues
- Follow the verification protocol below for EVERY potential bug

### Verification Protocol (MANDATORY for ALL subagents)

Before reporting ANY bug, agents MUST complete this validation process:

1. **Code Context Analysis**
   - Read the ENTIRE file containing the suspected bug
   - Identify all related functions, types, and imports
   - Trace data flow through the function/component
   - Check for defensive code that might prevent the bug

2. **Related Files Investigation**
   - Search for and read files that interact with the buggy code
   - Check type definitions, interfaces, and schemas
   - Read test files to understand expected behavior
   - Review documentation or comments explaining intent

3. **Pattern Verification**
   - Search codebase for similar patterns to see if this is intentional
   - Check if this pattern appears elsewhere without issues
   - Look for project conventions that might explain the code

4. **Impact Analysis**
   - Trace how the bug would manifest in actual execution
   - Identify specific user actions or data that would trigger it
   - Determine if there are safeguards elsewhere preventing impact
   - Verify the bug isn't already handled by error boundaries/validation

5. **False Positive Elimination**
   - Check if recent framework/library updates make this valid
   - Verify the code isn't intentionally leveraging specific behavior
   - Ensure you understand the full execution context
   - Look for edge case handling you might have missed

6. **Confidence Assessment**
   - Can you write a failing test case for this bug?
   - Can you explain step-by-step how it breaks?
   - Have you eliminated all alternative explanations?
   - Would a senior engineer agree this is definitely a bug?

**ONLY if you pass ALL six verification steps, then report the bug.**

### Subagent Categories:

#### 1. Logic Bug Hunter (general-purpose agent)
**Focus**: Business logic errors, edge cases, and algorithmic issues
- Off-by-one errors
- Incorrect loop conditions
- Wrong comparison operators
- Missing null/undefined checks
- Incorrect boolean logic
- Edge case handling (empty arrays, zero values, boundary conditions)
- Algorithm correctness
- State management errors

#### 2. Race Condition Detective (general-purpose agent)
**Focus**: Async/await issues, promises, and concurrent operations
- Missing await keywords
- Unhandled promise rejections
- Race conditions in async operations
- Incorrect promise chaining
- Missing error handling in async code
- Callback hell or promise anti-patterns
- Concurrent state mutations
- Missing locks or synchronization

#### 3. Security Vulnerability Scanner (general-purpose agent)
**Focus**: Security holes and vulnerabilities
- SQL injection risks
- XSS vulnerabilities
- CSRF issues
- Authentication/authorization bypasses
- Insecure data handling
- Exposed secrets or credentials
- Unsafe deserialization
- Path traversal vulnerabilities
- Command injection risks
- Missing input validation/sanitization

#### 4. Memory & Resource Leak Inspector (general-purpose agent)
**Focus**: Resource management issues
- Memory leaks (unclosed connections, unreleased resources)
- Missing cleanup in useEffect/componentWillUnmount
- Event listener leaks
- Infinite loops or recursion
- Missing abort controllers
- Unclosed file handles
- Database connection leaks
- Large object accumulation

#### 5. Type Safety Violator (general-purpose agent)
**Focus**: Type-related bugs (TypeScript/JavaScript)
- Type assertions that hide bugs (`as any`, unsafe casts)
- Missing null checks after type narrowing
- Incorrect type guards
- Wrong generic constraints
- Missing discriminated union handling
- Optional chaining masking bugs
- Type coercion issues

#### 6. API Integration Bug Finder (general-purpose agent)
**Focus**: External API and integration issues
- Incorrect API endpoint usage
- Wrong HTTP methods
- Missing error handling for API calls
- Incorrect request/response types
- Missing retry logic where needed
- Timeout issues
- Missing loading/error states
- Incorrect data transformation

## Agent Execution Instructions

**IMPORTANT**: After identifying the bug categories relevant to the changed files:

1. **Spawn agents in parallel** - Use a single message with multiple Task tool calls
2. **Provide complete context to each agent**:
   - Full diff of relevant files
   - Project guidelines (CLAUDE.md, AGENT.md)
   - Commit messages for intent
   - Related files for context
3. **Explicit validation requirement**: Each agent must verify bugs are real before reporting
4. **Clear reporting format**: Agent should return file:line references with explanation

### Example Agent Prompt Template:
```
You are a specialized bug detection agent focusing on [CATEGORY].

**Your mission**: Find ONLY valid, confirmed bugs in the provided code changes through RIGOROUS investigation.

**Context**:
- Changed files: [list]
- Commit intent: [summary]
- Project guidelines: [relevant rules]

**Full diff**:
[diff content]

**CRITICAL - Verification Protocol**:
For EVERY potential bug you identify, you MUST complete this investigation:

1. **Read Complete Context**
   - Use Read tool to get the FULL file (not just the diff)
   - Use Grep/Glob to find related files and functions
   - Understand the complete data flow, not just the changed lines

2. **Search for Evidence**
   - Use Grep to find similar patterns in the codebase
   - Check if this pattern is used elsewhere safely
   - Look for tests covering this code
   - Find type definitions and interfaces

3. **Trace Execution Paths**
   - Follow the code path from entry point to the bug
   - Identify ALL ways this code can be called
   - Check for validation/sanitization before this code
   - Look for error handling that might catch the issue

4. **Validate Impact**
   - Determine EXACTLY how to trigger the bug
   - Identify specific inputs/states that cause failure
   - Verify there are no safeguards preventing the bug
   - Confirm this isn't caught by error boundaries

5. **Eliminate False Positives**
   - Check framework/library docs for intended behavior
   - Look for project-specific patterns or conventions
   - Verify you understand the complete context
   - Search for comments/docs explaining the code

6. **Document Investigation**
   - For EACH bug, show your investigation process
   - List the files you read and searches you performed
   - Explain why you're confident it's a real bug
   - Show evidence that eliminates alternative explanations

**Investigation Quality Standards**:
- You MUST use Read tool at least 3-5 times per suspected bug
- You MUST use Grep/Glob to search for related patterns
- You MUST trace data flow through at least 2-3 related files
- You MUST be able to explain exactly how to reproduce the bug
- If you can't meet these standards, DO NOT report the bug

**Instructions**:
1. Identify potential bugs in your category: [SPECIFIC BUG TYPES]
2. For EACH potential bug:
   - Execute the complete verification protocol above
   - Document your investigation process
   - Only proceed if you pass ALL verification steps
3. Report ONLY confirmed bugs with full investigation details

**Do NOT report**:
- Code style issues
- Potential improvements
- Unconfirmed suspicions
- "Might be a bug" - either it IS a bug or don't report it
- Best practice violations (unless they cause bugs)
- Anything you haven't fully investigated

**Return format**:
For each bug found:
```
BUG: [file:line]
Category: [bug type]
Severity: [critical/high/medium/low]
Confidence: [how certain you are this is a bug]

Description: [what's wrong]

Investigation Summary:
- Files examined: [list files you read]
- Searches performed: [grep/glob patterns used]
- Related code checked: [other functions/files analyzed]
- Patterns found: [similar code in codebase]
- Tests reviewed: [test files examined]

Evidence:
[Concrete evidence this is a bug - code snippets, execution traces, etc.]

Impact: [how this breaks in production]

Reproduction Steps:
1. [Exact steps to trigger the bug]
2. [Or explain execution path that hits the bug]

False Positive Check:
- Checked for defensive code: [yes/no - what you found]
- Verified no safeguards exist: [yes/no - what you checked]
- Confirmed not intentional pattern: [yes/no - evidence]
- Eliminated alternative explanations: [list what you ruled out]

Fix:
```code
// Suggested fix with explanation
```
```

If no bugs found after thorough investigation:
"No confirmed bugs in [CATEGORY] after investigating [list files/patterns checked]"
```

## Validation & Deduplication

After collecting findings from all subagents:

### Stage 1: Investigation Quality Check
For each reported bug, verify the agent performed adequate investigation:
- Did they read multiple related files? (minimum 3-5 files)
- Did they search for patterns using Grep/Glob?
- Did they trace the execution path?
- Did they document their investigation process?
- Did they provide concrete evidence?
- **REJECT any bug reports with insufficient investigation**

### Stage 2: Independent Verification
For each bug that passed Stage 1, YOU must independently verify:
1. **Read the reported file yourself** - Don't trust blindly
2. **Reproduce the investigation** - Check their evidence
3. **Search for safeguards** - Look for defensive code they might have missed
4. **Check test coverage** - Look for tests that would catch this
5. **Review recent commits** - Was this recently fixed or intentionally changed?
6. **Validate the fix** - Ensure the suggested fix is correct and complete

### Stage 3: Severity Validation
For confirmed bugs, rigorously assess severity:
- **Critical**: Data loss, security breach, application crash, complete feature breakage
- **High**: Major feature broken, significant data corruption, impacts many users
- **Medium**: Feature partially broken, edge case failure, impacts some users
- **Low**: Minor issue, rare edge case, minimal user impact

**Be conservative with severity ratings** - don't inflate importance

### Stage 4: Deduplication
- Remove duplicate bugs reported by multiple agents
- Merge related bugs into single comprehensive report
- Ensure no overlapping issues in final report

### Stage 5: False Positive Final Check
Before including ANY bug in final report, ask:
- Would this actually break in production?
- Is there ANY way this could be intentional?
- Did we miss any context that would explain this?
- Would we confidently tell a developer "this is definitely a bug"?

**When in doubt, investigate more or leave it out.**

## Output Format:
```markdown
## Bug Bot Analysis Report

### Investigation Summary
- Branch: [current branch]
- Parent: [parent branch from Graphite stack]
- Files analyzed: [count]
- Subagents deployed: [count and categories]
- Potential bugs investigated: [count]
- False positives filtered: [count]
- Confirmed bugs: [count]
- Critical: X | High: Y | Medium: Z | Low: W

### Investigation Rigor
- Total files read during investigation: [count]
- Total searches performed: [count]
- Average investigation depth per bug: [files read / bugs found]
- Bugs rejected due to insufficient evidence: [count]

### Critical Bugs 🔴

#### 1. [Bug Title] - `file.ts:line`
**Category**: Logic Error
**Severity**: Critical
**Confidence**: [High/Very High]
**Verified By**: [You + which subagents]

**Description**: [What's wrong]

**Investigation Evidence**:
- Files examined: [list]
- Related code analyzed: [list]
- Patterns searched: [grep/glob patterns]
- Tests reviewed: [test files checked]

**Concrete Evidence**:
[Code snippets, execution traces showing the bug]

**Impact**: [How this breaks in production]

**Reproduction Steps**:
1. [Exact steps to trigger]
2. [Expected vs actual behavior]

**Why This Is Definitely A Bug**:
- Checked for defensive code: None found in [files]
- Verified no safeguards: Confirmed by reading [files]
- Eliminated false positives: [what was ruled out]
- Independent verification: [your verification process]

**Fix**:
```typescript
// Suggested fix with explanation
```

**Verification of Fix**:
[How to verify the fix works]

### High Priority Bugs 🟠

[Same format as critical]

### Medium Priority Bugs 🟡

[Same format]

### Low Priority Bugs 🔵

[Same format]

### Rejected Bug Reports

The following potential bugs were investigated but rejected after thorough analysis:

#### 1. [Suspected Issue] - `file.ts:line`
**Initial Concern**: [What looked like a bug]
**Investigation**: [What we checked]
**Why Rejected**: [Evidence showing it's not actually a bug]
**Files Verified**: [list of files that proved it's okay]

[Repeat for each rejected bug]

### Investigation Statistics
- Subagents deployed: [list of categories]
- Files with no bugs found: [list]
- False positives filtered: [count with details]
- Investigation quality: [assessment of thoroughness]
- Verification pass rate: [bugs confirmed / bugs investigated]

### Recommendations
1. **Immediate Actions**:
   - Fix critical bugs before merging
   - [Specific critical actions]

2. **Before Merge**:
   - Address high priority bugs
   - [Specific high priority actions]

3. **Follow-up**:
   - Monitor medium/low bugs in production
   - [Specific follow-up items]

4. **Patterns Observed**:
   - [Any common bug patterns found]
   - [Suggestions to prevent similar bugs]

### Clean Areas ✅
The following areas were thoroughly analyzed and no bugs were found:
- [Area/file 1]: Investigated for [bug categories], verified [specific aspects]
- [Area/file 2]: Analyzed [patterns], confirmed [safety measures]

### Confidence Assessment
- Overall investigation confidence: [High/Medium]
- Areas where more context would help: [list if any]
- Assumptions made: [list any assumptions]
```

## Important Notes:

**Thoroughness over Speed**: This is deep research, not a quick scan. Agents should:
- Read related files for context (minimum 3-5 files per bug)
- Understand the full data flow
- Check error paths, not just happy paths
- Consider edge cases and boundary conditions
- Use Grep/Glob extensively to find patterns and related code
- Trace execution paths through multiple layers

**Valid Bugs Only - EXTREMELY HIGH BAR**: Agents must be confident. If uncertain, they should:
- Investigate further - read more files
- Search for more context - use Grep/Glob extensively
- Check documentation and comments
- Look for tests that cover the code
- Search for similar patterns in codebase
- Verify there are no safeguards elsewhere
- **Only report if they can explain EXACTLY how it breaks with concrete reproduction steps**
- **If you can't write a failing test case, don't report it**

**Evidence-Based - Prove Every Bug**: Every bug report must include:
- Exact location (file:line)
- Complete investigation summary (files read, searches performed)
- Concrete evidence (code snippets, execution traces)
- Clear explanation of bug mechanics
- Reproduction steps or detailed execution path analysis
- False positive elimination documentation
- Concrete fix suggestion with verification method

**Independent Verification Required**: After receiving subagent reports:
- **Never blindly trust subagent findings**
- Verify each bug yourself by reading the code
- Check their investigation was thorough enough
- Look for context they might have missed
- Reject bugs with insufficient investigation
- Downgrade severity if impact is overstated

**Parallel Execution**: Always launch relevant subagents in parallel for maximum efficiency. Use a single message with multiple Task tool calls.

**Quality Over Quantity**: Better to report 2 rock-solid bugs than 10 "maybe" issues. The user needs to trust your bug reports completely.

## Example Usage:

After identifying changed files include frontend components and API handlers:

1. Spawn in parallel (single message with multiple Task calls):
   - Logic Bug Hunter (for both frontend and backend logic)
   - Race Condition Detective (for async API calls)
   - Security Vulnerability Scanner (for API authentication)
   - Memory & Resource Leak Inspector (for React components)
   - API Integration Bug Finder (for external API calls)

2. Each agent performs deep research on their specialty

3. Collect, validate, and deduplicate findings

4. Generate comprehensive report

**Remember**:
- Quality over quantity. One confirmed critical bug is more valuable than ten unconfirmed suspicions.
- **Zero false positives is the goal** - your credibility depends on accuracy
- When in doubt, investigate more or leave it out
- If a subagent's investigation seems shallow, reject their bug report
- Always verify bugs independently before including in final report
- Document WHY each bug is definitely a bug, not just what the bug is

## Rejection Criteria

**IMMEDIATELY REJECT bug reports that**:
- Don't include investigation evidence (files read, searches performed)
- Lack concrete reproduction steps or execution path analysis
- Use vague language like "might", "could", "potentially"
- Don't document false positive elimination
- Show insufficient file reading (< 3 related files)
- Don't trace data flow through the system
- Lack code snippets as evidence
- Don't explain exactly how to trigger the bug

**When rejecting a bug report**:
- Document why it was rejected
- Include it in "Rejected Bug Reports" section
- Show what investigation proved it wasn't a bug
- This builds confidence in your confirmed bugs
