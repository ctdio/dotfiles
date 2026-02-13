---
name: learnings
description: Manage persistent learnings that compound across sessions. Use when the user says "/learnings", wants to add a note, condense learnings, promote workspace entries, or search past learnings.
color: green
---

# Learnings System

Manage scoped, persistent learnings that auto-load every session. Mistakes only happen once, patterns are reused, progress survives session boundaries.

## Scoping Model

| Scope         | File                                                        | Shared across              | Content                                       |
| ------------- | ----------------------------------------------------------- | -------------------------- | --------------------------------------------- |
| **Global**    | `~/.ai/learnings/global.md`                                 | Everything                 | Universal mistakes, cross-project preferences |
| **Project**   | `~/.ai/learnings/projects/{repo}/project.md`                | All worktrees of same repo | Codebase patterns, architecture gotchas       |
| **Workspace** | `~/.ai/learnings/projects/{repo}/workspaces/{workspace}.md` | Nothing (isolated)         | Task progress, feature decisions, WIP notes   |

**Project name**: `git remote get-url origin | sed 's/.*\///' | sed 's/\.git$//'` — falls back to `basename $PWD`
**Workspace name**: `basename $PWD`

## Progressive Disclosure

Global and project files use a `---` separator:

- **Above `---`**: Auto-loaded every session. Keep concise, high-signal.
- **Below `---`**: Archived. Preserved and searchable, not auto-loaded.

Workspace files have no separator — fully loaded as current working context.

## Commands

### `/learnings` — Review current state

Show all learnings across all scopes for the current context. Display each scope with its content, noting what's active vs archived.

### `/learnings note <text>` — Add an entry

Add a learning entry. Auto-categorize into the appropriate section (Mistakes, Patterns, Preferences, Decisions).

**Default scope**: workspace. Override with flags:

- `--global` — add to global learnings
- `--project` — add to project learnings

**Behavior**:

1. Detect project and workspace names
2. Create the target file if it doesn't exist (use the same structure as global.md — section headers + `---` separator for global/project files, no separator for workspace files)
3. Add the entry as a bullet point under the appropriate section header, above the `---` separator
4. Confirm what was added and where

### `/learnings condense` — Compact and organize

Review all scopes and:

1. **Deduplicate** — merge entries saying the same thing
2. **Consolidate** — combine related entries into concise summaries
3. **Promote** — move recurring workspace patterns to project scope, recurring project patterns to global scope
4. **Demote** — move stale or one-off entries below the `---` separator
5. Show a summary of changes made

### `/learnings promote` — Interactive promotion

Review workspace entries and ask which should be promoted to project or global scope. Show each entry with promotion options.

### `/learnings search <query>` — Search all learnings

Search across all learnings files including archived content below `---`. Use grep across `~/.ai/learnings/`. Show results grouped by scope with file paths.

## Entry Format

Each entry is a concise bullet under the appropriate section:

```markdown
## Mistakes

- Never assume prisma client is regenerated after schema changes — run `npx prisma generate`
- The `users` table uses `uuid` not `id` as primary key

## Patterns

- All API routes use zod validation via `validateRequest` middleware
- Tests use `createTestContext()` factory — never construct manually

## Preferences

- Always use `bun` over `npm` for this project
- Prefer `vitest` over `jest`

## Decisions

- Chose Turbopuffer over Pinecone for vector search (cost + latency)
```

## Scope Guidance

| Learning type                          | Scope     |
| -------------------------------------- | --------- |
| "Never use `any` in TypeScript"        | Global    |
| "This repo uses barrel exports"        | Project   |
| "Chose approach X for feature Y"       | Workspace |
| "User prefers bun over npm"            | Global    |
| "API uses snake_case responses"        | Project   |
| "Current branch implements OAuth flow" | Workspace |

## File Creation

When creating new project/workspace files:

**Project file** (`~/.ai/learnings/projects/{repo}/project.md`):

```markdown
## Mistakes

## Patterns

## Preferences

---

# Archive
```

**Workspace file** (`~/.ai/learnings/projects/{repo}/workspaces/{workspace}.md`):

```markdown
## Decisions

## Notes
```
