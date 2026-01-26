# Example: phase-N/files-to-modify.md

> This example shows a file list optimized for quick context gathering.

---

```markdown
# Phase 1: Data Model - Files to Modify

## Summary

- **New Files**: 2
- **Modified Files**: 1
- **Deleted Files**: 0

## Quick Navigation

### Core Changes
- `prisma/schema.prisma` - Add Comment and CommentMention models
- `src/repositories/comment.repository.ts` - Repository layer

### Supporting Changes
- `src/repositories/comment.repository.test.ts` - Repository tests

---

## Detailed File List

### New Files

#### `src/repositories/comment.repository.ts`
**Purpose**: Repository for Comment CRUD operations

**Dependencies**: Database client, transaction utilities

**Used By**: `comment.service.ts` (Phase 2)

**Key Exports**:
- `createComment()` - Create comment with optional mentions
- `findCommentById()` - Fetch single comment with author
- `findCommentsByTask()` - List comments for a task
- `updateComment()` - Update comment content
- `softDeleteComment()` - Soft delete comment

---

#### `src/repositories/comment.repository.test.ts`
**Purpose**: Tests for comment repository

**Test Count**: 6 minimum

**Coverage**:
- Create comment
- Create comment with mentions
- Find by ID
- Find by task
- Update comment
- Soft delete

---

### Modified Files

#### `prisma/schema.prisma`
**Current Role**: Defines all database models

**Changes Needed**:
1. Add `Comment` model with all fields and indexes
2. Add `CommentMention` junction table
3. Add `comments` relation to `Task` model
4. Add `comments` and `mentions` relations to `User` model

**Sections to Modify**:
- After existing models - Add new Comment and CommentMention models
- `Task` model - Add comments relation
- `User` model - Add comments and mentions relations

**Impact**: Requires migration, regenerates database client types

---

## Change Dependencies

**Change Order**:
1. Modify `schema.prisma` first (models and relations)
2. Generate migration file
3. Apply migration to development database
4. Regenerate database client
5. Create repository (depends on client types)
6. Create repository tests

## File References Map

Quick lookup of where to find related code:

- **Existing Task Model**: `prisma/schema.prisma` (search for `model Task`)
- **Existing User Model**: `prisma/schema.prisma` (search for `model User`)
- **Example Repository**: `src/repositories/task.repository.ts`
- **Example Repository Tests**: `src/repositories/task.repository.test.ts`
```

---

## Why This Files Document Works

1. **Summary at top**: Quick count of changes
2. **Quick navigation**: Core vs supporting changes
3. **New files have purpose**: Explains why file exists
4. **Modified files have context**: Current role + what changes
5. **Change dependencies**: Order matters and is documented
6. **File references map**: Quick lookup for related code

## Key Patterns

### Quick Navigation Section
Group files by importance:
- Core changes (most impactful)
- Supporting changes (tests, utilities)

### New File Template
For each new file include:
- Purpose
- Dependencies
- Used By
- Key Exports

### Modified File Template
For each modified file include:
- Current Role
- Changes Needed (numbered list)
- Sections to Modify (with guidance)
- Impact (what breaks/changes)

### Change Dependencies
Always specify order when:
- One change depends on another
- Generated code is involved
- Build order matters
