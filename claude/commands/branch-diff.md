# Branch Diff

Get a comprehensive diff of the current branch against its parent, including stack context from Graphite, commit history, and detailed changes to understand what has been done.

## Steps:
1. Use Graphite to understand the current stack structure
2. Identify the parent branch from the stack
3. Read all commits in the current branch
4. Get comprehensive diff against parent branch
5. Analyze changes to understand context

## Commands to run:
```bash
# First check if Graphite is available
which gt

# Get current stack information
gt log --stack

# Get the parent branch and current branch info
gt branch info

# Get current branch name
git branch --show-current

# Get list of commits in current branch (from parent)
git log --oneline [parent-branch]..HEAD

# Get detailed commit messages with full context
git log --format="=== Commit: %h ===%n%s%n%n%b%n" [parent-branch]..HEAD

# Get comprehensive diff with context against parent branch
git diff [parent-branch]..HEAD

# Get list of changed files
git diff --name-only [parent-branch]..HEAD

# Get statistics of changes
git diff --stat [parent-branch]..HEAD
```

## Important Notes:
- **Use Graphite (gt) to identify the correct parent branch** - don't assume it's master/main
- The parent branch is shown in `gt branch info` output
- If Graphite is not installed, fall back to using `git merge-base HEAD origin/master`
- In stacked PRs, always compare against the immediate parent, not the trunk
- Read commit messages to understand the intent behind changes

## Context Building Process:

### 1. Stack Understanding
- Review `gt log --stack` output to understand:
  - Position in the stack
  - Dependencies on other branches
  - Related work in adjacent branches

### 2. Commit Analysis
- Read each commit message thoroughly to understand:
  - What was intended
  - Why changes were made
  - Any referenced issues or tickets
  - Breaking changes or important notes

### 3. Change Review
- Analyze the diff to understand:
  - What files were modified
  - Nature of changes (features, fixes, refactors)
  - Patterns in the changes
  - Dependencies or impacts

### 4. Context Summary
After running commands, provide:
- Current branch and its parent
- Position in the Graphite stack
- Summary of commits and their purposes
- Overview of changes made
- Any important patterns or decisions observed

## Output Format:
```
## Context Summary

### Stack Position
- Current branch: [branch name]
- Parent branch: [parent from Graphite]
- Stack structure: [visual representation from gt log --stack]

### Commits in Branch
1. [hash] - [commit message]
   - [key changes or notes]
2. [hash] - [commit message]
   - [key changes or notes]

### Changes Overview
- Files modified: [count]
- Lines changed: +[added] -[removed]
- Key areas affected:
  - [area 1]: [description]
  - [area 2]: [description]

### Understanding
Based on the commits and changes:
- [Main purpose of this branch]
- [Key decisions or patterns observed]
- [Any important context for future work]
```

This command helps quickly get up to speed on what has been done in a branch by combining Graphite's stack awareness with Git's detailed history and diff capabilities.