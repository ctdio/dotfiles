---
name: rebase
description: Guided git rebase with conflict understanding and verification. Use when user asks to rebase a branch, resolve rebase conflicts, or continue a stuck rebase. Ensures both sides of conflicts are understood and changes are verified before continuing.
color: orange
---

# Rebase

Guided git rebase that treats every conflict as a merge of two intentional changes, not a pick-one-side operation.

## Trigger

Use this skill when the user asks to:

- Rebase a branch onto another branch
- Resolve rebase conflicts
- Continue a paused/stuck rebase
- Fix a failed rebase

## Pre-Rebase Assessment

Before starting, gather context:

1. **Identify the branches** - What's being rebased onto what?
2. **Review the commit log** being rebased:
   ```bash
   git log --oneline <target>..<current>
   ```
3. **Check for uncommitted changes** - Stash or commit first
4. **Assess scope** - How many commits? How divergent are the branches?

Report the scope to the user before proceeding: number of commits, rough area of changes.

## Starting the Rebase

```bash
git rebase <target-branch>
```

If conflicts arise, enter the per-commit resolution loop below.

## Per-Commit Conflict Resolution (MANDATORY PROCESS)

For EACH commit that conflicts, follow every step. Do not skip steps.

### Step 1: Understand the Commit

Read the commit message and understand what this commit was trying to accomplish:

```bash
git log --format="%B" REBASE_HEAD -1
```

### Step 2: Identify All Conflicting Files

```bash
git diff --name-only --diff-filter=U
```

### Step 3: Understand Both Sides of EVERY Conflict

For each conflicting file, understand what BOTH sides intended:

- **Ours (target branch):** What changes landed on the target since this branch diverged?
- **Theirs (commit being replayed):** What was this commit trying to do to this file?

Use these commands to understand context:

```bash
# See what the target branch has for this file
git show :2:<file>   # "ours" - target branch version

# See what the commit being rebased has
git show :3:<file>   # "theirs" - incoming commit version

# See the common ancestor
git show :1:<file>   # base version
```

**Read the actual conflict markers in the file.** Understand the semantic intent of both sides, not just the textual diff.

### Step 4: Resolve with Intent

**The default is to incorporate BOTH sides.** Every conflict has two sides that both exist for a reason.

Resolution rules:

- **NEVER** accept only ours or only theirs wholesale across a file
- **Merge the intent** from both sides — adapt the incoming change to fit the current shape of the code
- **Account for renames and refactors** — if the target branch renamed a function or moved code, apply the incoming change to the new location/name
- **Watch for semantic conflicts** — code that merges cleanly at the text level but breaks at the logic level (duplicate imports, conflicting business rules, incompatible type changes)

### Step 5: Verify the Resolution (MANDATORY - DO NOT SKIP)

After resolving all conflicts for this commit, **before running `git rebase --continue`**:

1. **Review the diff of every resolved file:**

   ```bash
   git diff
   ```

   Check for:
   - Silently dropped changes (lines from one side missing entirely)
   - Broken references (renamed variables/functions not updated)
   - Duplicated code (same logic appearing twice)
   - Orphaned imports (imports for removed code, or missing imports for added code)

2. **Run the project's prepare/codegen script** (if available):

   Projects often have scripts that regenerate schemas, types, or other derived artifacts. These MUST run before typecheck so generated code reflects the current state.

   Discovery order — use the first one that exists:
   - Check `CLAUDE.md` or `AGENT.md` for a documented prepare command
   - Check `package.json` scripts for `prepare`, `codegen`, `generate`, or `build:types`
   - Check for `nx` projects: `nx run <project>:prepare`
   - Check for `prisma` projects: `npx prisma generate`

   Common examples:

   ```bash
   # Nx monorepo
   nx run platform:prepare

   # package.json script
   npm run prepare

   # Prisma
   npx prisma generate
   ```

3. **Run the project's type checker** (if available):

   ```bash
   # TypeScript projects
   npx tsc --noEmit

   # Or check package.json for the typecheck script
   npm run typecheck 2>/dev/null || npx tsc --noEmit
   ```

4. **Run the project's linter** (if available):

   ```bash
   # Check package.json for lint script
   npm run lint 2>/dev/null || npx eslint . 2>/dev/null
   ```

5. **Run tests** (if available):

   ```bash
   # Check package.json for test script
   npm test 2>/dev/null
   ```

6. **If any verification step fails:** Fix the issues BEFORE continuing. These failures often indicate a resolution that silently broke something.

7. **Stage the resolved files:**

   ```bash
   git add <resolved-files>
   ```

8. **Continue the rebase:**

   ```bash
   git rebase --continue
   ```

9. **If more commits conflict**, return to Step 1.

## Post-Rebase Verification

After the entire rebase completes:

1. **Verify the full commit history looks correct:**

   ```bash
   git log --oneline -20
   ```

2. **Run the prepare/codegen script** one final time to ensure all generated artifacts are current

3. **Run typecheck, lint, and tests** against the full rebased branch

4. **Compare the net diff** to ensure no changes were lost:
   ```bash
   # Show what this branch adds vs the target
   git diff <target-branch>...HEAD --stat
   ```

## Abort Policy

**Abort when uncertain.** `git rebase --abort` is always better than a bad resolution.

Abort and ask the user if:

- A conflict involves architectural changes you don't fully understand
- You're unsure whether both sides' intent can coexist
- The resolution would require significant new code beyond what either side had
- Typecheck/lint failures suggest a deeper incompatibility

```bash
git rebase --abort
```

## Common Pitfalls

| Pitfall                                        | Prevention                                      |
| ---------------------------------------------- | ----------------------------------------------- |
| Accepting `--ours` or `--theirs` globally      | Never. Resolve each file individually           |
| Skipping typecheck                             | Mandatory before every `--continue`             |
| Not reading commit messages                    | Always read REBASE_HEAD commit message first    |
| Missing renamed references                     | Check git log for renames on target branch      |
| Resolving conflicts without reading both sides | Always use `:2:` and `:3:` to understand intent |
