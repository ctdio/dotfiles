---
name: workspace-prep
description: Prepare a clean worktree workspace for development work. Use when you need to set up a fresh environment for coding tasks - finds a clean worktree, drops/recreates databases, and runs installation/preparation steps.
---

# Workspace Preparation

Automated workflow to prepare a clean worktree workspace for development.

## When to Use

Use this skill before delegating coding work to Claude Code or other agents when:
- Starting a new feature or bug fix
- Need a clean database state
- Want to isolate work in a dedicated worktree

## Workflow

### 1. Find Clean Worktree

```bash
wt-status
```

Select a worktree **without uncommitted changes** (no `*` marker). Common clean targets: `platform-wtb`, `platform-wtc`, etc.

### 2. Clean Databases

Drop existing databases for the selected worktree (replace `wta` with your chosen letter):

```bash
db-branch drop platform_wta
db-branch -c platform-vector-db drop vector_wta
```

### 3. Clone Fresh Databases

Create fresh database instances from the main project:

```bash
db-branch clone platform platform_wta
db-branch -c platform-vector-db clone vector vector_wta
```

### 4. Install Dependencies

Navigate to the worktree and install:

```bash
cd ~/projects/private/opine/platform-wta  # or whichever worktree
npm install
```

### 5. Prepare Platform

Run the platform preparation command:

```bash
npx nx run platform:prepare
```

## Complete Example

```bash
# Check available worktrees
wt-status

# Choose platform-wtb (clean, no * marker)
cd ~/projects/private/opine/platform-wtb

# Drop old databases
db-branch drop platform_wtb
db-branch -c platform-vector-db drop vector_wtb

# Clone fresh databases
db-branch clone platform platform_wtb
db-branch -c platform-vector-db clone vector vector_wtb

# Install and prepare
npm install
npx nx run platform:prepare
```

## After Preparation

Workspace is ready for coding work. Common next step: spawn Claude Code with the worktree as `workdir`:

```bash
exec pty:true workdir:~/projects/private/opine/platform-wtb background:true command:"claude 'Your task here'"
```

## Notes

- **Worktree naming**: Follows pattern `platform-wt[letter]` (wta, wtb, wtc, etc.)
- **Database naming**: Matches worktree letter (platform_wtb, vector_wtb)
- **Vector database**: Uses container `platform-vector-db` (flag: `-c platform-vector-db`)
- **Platform database**: Uses default container `platform-db` (no flag needed)
