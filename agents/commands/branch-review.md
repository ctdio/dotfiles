# Branch Review

Perform a thorough branch review by comparing the current branch against the base branch, looking for code quality issues and violations of project guidelines.

## Steps:
1. Use Graphite to understand the current stack and identify the parent branch
2. Get the diff between current branch and its parent branch in the stack
3. Check for project guidelines (CLAUDE.md, AGENT.md, .cursor/rules, etc.)
4. Analyze the diff for code quality issues
5. Generate a critical review report

## Commands to run:
```bash
# Get current stack information
gt log --stack

# Get the parent branch of current branch
gt branch info

# Get current branch name
git branch --show-current

# Get detailed diff with context against parent branch
# Note: gt branch info will show the parent branch, use that instead of assuming master
git diff [parent-branch]..HEAD

# Get list of changed files
git diff --name-only [parent-branch]..HEAD

# Get commit messages to understand intent
git log --oneline [parent-branch]..HEAD
```

## Important Notes:
- **Use Graphite (gt) to identify the correct parent branch** - don't assume it's master/main
- The parent branch is shown in `gt branch info` output
- In stacked PRs, always compare against the immediate parent, not the trunk
- Assume Graphite is already installed and available

## Review Checklist:

### Critical Issues to Identify:
1. **AI Slop Detection**
   - Overly verbose comments that state the obvious
   - Unnecessary explanations in code
   - Comments like "// This function does X" when the function name already says that
   - Excessive use of phrases like "Let's", "We'll", "Now we", etc. in comments
   - Comments that repeat what the code already clearly expresses

2. **Code Quality Issues**
   - **CRITICAL: Duplicated code blocks** - Any copied/pasted logic should be extracted into shared functions
   - **DRY violations** - Repeated patterns that should be abstracted
   - Similar functions that could be parameterized or generalized
   - Copy-paste programming instead of proper abstraction
   - Unused variables, functions, or imports
   - Dead code paths
   - Console.log statements (should be removed or replaced with proper logging)
   - **Commented out code** - Should be removed entirely unless there's a clear TODO/FIXME with explanation
     * No commented function definitions
     * No commented import statements
     * No commented blocks of implementation
     * If code might be needed later, use version control history instead

3. **Error Handling Problems**
   - Simply logging errors without proper handling
   - Catch blocks that only console.log without re-throwing or handling
   - Missing error boundaries or try-catch blocks where needed
   - Swallowing errors silently
   - Not using the project's error reporting mechanisms

4. **Project Guideline Violations**
   - Check CLAUDE.md for:
     * Function organization (imports → types → constants → exports → helpers)
     * Use of arrow functions at module level (forbidden)
     * Mixed exports and helpers (forbidden)
     * Proper use of 'err' in catch blocks
   - Check AGENT.md, .cursor/rules for additional project-specific rules
   - Verify naming conventions are followed
   - Check that code structure matches project patterns

5. **Implementation vs Intent**
   - Compare commit messages with actual changes
   - Verify the code achieves what the commits claim
   - Look for incomplete implementations
   - Check if all requirements from commit messages are met

## Instructions:
1. First use Graphite (`gt branch info`) to identify the correct parent branch
2. Read all project guideline files (CLAUDE.md, AGENT.md, .cursor/rules, README.md)
3. Analyze the diff against the parent branch systematically, file by file
4. Be **highly critical** - this is about maintaining code quality
5. Create a structured report with:
   - Summary of changes (including Graphite stack context)
   - Critical issues found (with file:line references)
   - Violations of project guidelines
   - Recommendations for fixes
   - Assessment of whether code achieves stated intent

## Graphite-Specific Considerations:
- In stacked PRs, changes may depend on parent branches
- Always review against the immediate parent, not trunk
- Use `gt log --stack` to understand the full stack context
- Check if changes make sense within the stack structure

## Output Format:
```
## Branch Review Report

### Summary
- Branch: [current branch]
- Parent: [parent branch from Graphite stack]
- Stack position: [from gt log --stack]
- Files changed: [count]
- Lines added/removed: +X/-Y

### Critical Issues Found

#### 1. AI Slop
- `file.ts:45` - Obvious comment: "// This adds two numbers"
- `component.tsx:23` - Verbose explanation that repeats code logic

#### 2. Code Quality
- `utils.ts:89` - **CRITICAL: Duplicated logic**, same as lines 45-60 - Extract into shared function
- `api.ts:34` - console.log statement left in production code
- `service.ts:156-178` - **DRY violation**: Similar error handling pattern repeated 5 times
- `handlers.ts:23` - Copy-pasted validation logic from handlers.ts:67
- `components.tsx:45-67` - **Commented out code block** - Remove entirely, use git history if needed
- `api.ts:12` - Commented out import statements should be removed
- `helpers.ts:89-92` - Commented function with no explanation - delete or add TODO with reason

#### 3. Error Handling
- `service.ts:78` - Error only logged, not properly handled
- `handler.ts:123` - Empty catch block swallowing errors

#### 4. Guideline Violations  
- `newFile.ts` - Arrow functions used at module level (violates CLAUDE.md)
- `helper.ts:45` - Helper function mixed with exports (violates organization rules)

#### 5. Intent vs Implementation
- Commit claims "Add error handling" but errors are only logged
- Feature incomplete: missing validation mentioned in commit

### Recommendations
1. **Extract all duplicated code into shared functions** - DRY principle is non-negotiable
2. Remove all console.log statements
3. Refactor similar functions to use parameters instead of copy-paste
4. Abstract repeated patterns (error handling, validation, etc.)
5. Implement proper error handling with error reporting
6. Fix function organization violations
7. Complete missing features from commits

### Verdict
[PASS/FAIL] - The code [does/does not] meet quality standards and achieve stated intent.
```

Remember: Be thorough and critical. Good code review prevents technical debt.