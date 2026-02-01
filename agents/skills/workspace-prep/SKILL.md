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
db-worktree drop platform_wta
db-worktree drop -p 5434 vector_wta
```

### 3. Clone Fresh Databases

Create fresh database instances from the main project:

```bash
db-worktree clone platform platform_wta
db-worktree clone -p 5434 vector vector_wta
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
db-worktree drop platform_wtb
db-worktree drop -p 5434 vector_wtb

# Clone fresh databases
db-worktree clone platform platform_wtb
db-worktree clone -p 5434 vector vector_wtb

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
- **Vector database**: Uses port 5434 (flag: `-p 5434`)
- **Platform database**: Uses default port (no flag needed)
