# Example: implementation-guide.md

> This example shows a phased implementation guide with clear completion criteria, required tests, and verification steps.

---

```markdown
# Task Comments - Implementation Guide

## Overview

Task comments allow users to discuss tasks directly within the application, eliminating the need for external communication tools. This feature includes @mentions for notifications and real-time updates for collaboration.

## Implementation Strategy

This feature builds incrementally: data model first, then API, then UI, then integrations. Each phase produces a shippable increment that can be validated independently. The phasing ensures we can verify each layer before building on top of it.

---

## Phase 1: Data Model

**Goal**: Establish database schema for comments with user mentions.

**Deliverables**:
- [ ] Comment table with foreign keys to Task and User
- [ ] CommentMention junction table for @mentions
- [ ] Database migration
- [ ] Repository layer with CRUD operations

**Files to Create/Modify**:
- `prisma/schema.prisma` - Add Comment and CommentMention models
- `src/repositories/comment.repository.ts` - Repository layer
- `prisma/migrations/` - Migration file

**Dependencies**: None

### Completion Criteria

> **MANDATORY**: These criteria MUST ALL pass before marking this phase complete.

| Check | Command | Required | Notes |
|-------|---------|----------|-------|
| Build | `<build-command>` | PASS | Zero errors |
| Lint | `<lint-command>` | PASS | Zero warnings |
| Type-check | `<type-check-command>` | PASS | Zero errors |
| Tests | `<test-command>` | PASS | All tests pass including NEW tests |

**Required Tests** (BLOCKING - phase cannot complete without these):
| Test File | Min Tests | Coverage |
|-----------|-----------|----------|
| `comment.repository.test.ts` | 6 | CRUD operations: create, findById, findByTask, update, softDelete, createWithMentions |

**Verification Script**:
```bash
<type-check-command> && <lint-command> && <test-command>
```

**Pre-Completion Checklist** (ALL must be checked):
- [ ] Migration applies cleanly
- [ ] Database client generates without errors
- [ ] Indexes defined for taskId and authorId
- [ ] **Repository tests written and passing** (6 tests minimum)
- [ ] Verification script runs with zero failures

**Detailed Docs**: `phase-01-data-model/`

---

## Phase 2: Core API

**Goal**: Full CRUD API for comments with permissions and mention parsing.

**Deliverables**:
- [ ] Comment service with business logic
- [ ] API routes: POST, GET, PATCH, DELETE
- [ ] Mention parsing utility
- [ ] Permission checks (author-only edit/delete)
- [ ] Unit and integration tests

**Files to Create/Modify**:
- `src/services/comment.service.ts` - Service layer
- `src/utils/mention-parser.ts` - @mention parsing
- `src/routes/comments/route.ts` - List/Create endpoints
- `src/routes/comments/[id]/route.ts` - Get/Update/Delete endpoints

**Dependencies**: Phase 1 must be completed

### Completion Criteria

| Check | Command | Required | Notes |
|-------|---------|----------|-------|
| Build | `<build-command>` | PASS | Zero errors |
| Lint | `<lint-command>` | PASS | Zero warnings |
| Type-check | `<type-check-command>` | PASS | Zero errors |
| Tests | `<test-command>` | PASS | All tests pass including NEW tests |

**Required Tests** (BLOCKING - phase cannot complete without these):
| Test File | Min Tests | Coverage |
|-----------|-----------|----------|
| `comment.service.test.ts` | 12 | CRUD with permissions: create, get, update, delete × (success, forbidden, not found) |
| `mention-parser.test.ts` | 5 | Parse single mention, multiple mentions, invalid mentions, no mentions, edge cases |
| `comments-api.test.ts` (integration) | 10 | API endpoints with success and error cases |

**Verification Script**:
```bash
<type-check-command> && <lint-command> && <test-command>
```

**Pre-Completion Checklist** (ALL must be checked):
- [ ] API endpoints return correct status codes
- [ ] Permission checks enforce author-only edit/delete
- [ ] 24-hour edit window enforced
- [ ] @mentions parsed and stored correctly
- [ ] **Unit tests written and passing** (17 tests minimum)
- [ ] **Integration tests written and passing** (10 tests minimum)
- [ ] Verification script runs with zero failures

**Detailed Docs**: `phase-02-core-api/`

---

## Phase 3: Task Detail UI

**Goal**: Users can view and add comments on the task detail page.

**Deliverables**:
- [ ] Comment thread component
- [ ] Comment editor with @mention autocomplete
- [ ] Edit/delete actions for own comments
- [ ] Real-time updates via WebSocket

**Files to Create/Modify**:
- `src/components/comments/comment-thread.tsx` - Thread container
- `src/components/comments/comment-item.tsx` - Single comment display
- `src/components/comments/comment-editor.tsx` - Input with mentions
- `src/hooks/use-comment-subscription.ts` - Real-time updates

**Dependencies**: Phase 2 must be completed

### Completion Criteria

| Check | Command | Required | Notes |
|-------|---------|----------|-------|
| Build | `<build-command>` | PASS | Zero errors |
| Lint | `<lint-command>` | PASS | Zero warnings |
| Type-check | `<type-check-command>` | PASS | Zero errors |
| Tests | `<test-command>` | PASS | All tests pass including NEW tests |

**Required Tests** (BLOCKING - phase cannot complete without these):
| Test File | Min Tests | Coverage |
|-----------|-----------|----------|
| `comment-thread.test.tsx` | 4 | Render empty, render with comments, loading state, error state |
| `comment-item.test.tsx` | 5 | Render comment, show edit/delete for author, hide for others, show edited indicator, show deleted placeholder |
| `comment-editor.test.tsx` | 4 | Submit comment, validation error, mention autocomplete, cancel |

**Verification Script**:
```bash
<type-check-command> && <lint-command> && <test-command>
```

**Pre-Completion Checklist** (ALL must be checked):
- [ ] Comments display in chronological order
- [ ] Edit/delete buttons only show for comment author
- [ ] @mention autocomplete works
- [ ] Real-time updates work (test with two browser tabs)
- [ ] **Component tests written and passing** (13 tests minimum)
- [ ] Verification script runs with zero failures

**Detailed Docs**: `phase-03-ui/`

---

## Phase 4: Notifications & Search

**Goal**: @mentioned users receive notifications, comments are searchable.

**Deliverables**:
- [ ] Notification on @mention
- [ ] Comment content indexed for search
- [ ] "Comments" filter in search results

**Files to Create/Modify**:
- `src/services/notification.service.ts` - Add mention notification type
- `src/services/search-indexer.ts` - Index comment content
- `src/routes/search/route.ts` - Add comments to search results

**Dependencies**: Phase 3 must be completed

### Completion Criteria

| Check | Command | Required | Notes |
|-------|---------|----------|-------|
| Build | `<build-command>` | PASS | Zero errors |
| Lint | `<lint-command>` | PASS | Zero warnings |
| Type-check | `<type-check-command>` | PASS | Zero errors |
| Tests | `<test-command>` | PASS | All tests pass including NEW tests |

**Required Tests** (BLOCKING - phase cannot complete without these):
| Test File | Min Tests | Coverage |
|-----------|-----------|----------|
| `mention-notification.test.ts` | 4 | Notification sent on mention, no notification for self-mention, no duplicate notifications, notification links to comment |
| `comment-search.test.ts` | 3 | Comments indexed, search returns matching comments, deleted comments excluded |

**Verification Script**:
```bash
<type-check-command> && <lint-command> && <test-command>
```

**Pre-Completion Checklist** (ALL must be checked):
- [ ] @mentioned users receive in-app notification
- [ ] Notification links directly to comment
- [ ] Comments appear in search results
- [ ] Deleted comments excluded from search
- [ ] **Notification tests written and passing** (4 tests minimum)
- [ ] **Search tests written and passing** (3 tests minimum)
- [ ] Verification script runs with zero failures

**Detailed Docs**: `phase-04-notifications-search/`

---

## Cross-Phase Concerns

**Backward Compatibility**:
- Existing task detail pages continue to work
- Tasks without comments show empty state
- No changes to existing task CRUD

**Testing Strategy**:
- Repository tests in Phase 1
- Service unit tests + API integration tests in Phase 2
- Component tests in Phase 3
- Integration tests for notifications/search in Phase 4

**Rollback Plan**:
- Phase 1: Migration down script removes tables
- Phase 2-4: Revert commits, data preserved

---

## Global Completion Criteria

> **FINAL VERIFICATION**: Before the feature is considered complete, ALL of these must be true.

| Check | Command/Verification | Required |
|-------|---------------------|----------|
| All phases complete | implementation-state.md shows all phases completed | YES |
| Full test suite | `<test-command>` | PASS |
| Build succeeds | `<build-command>` | PASS |
| No lint errors | `<lint-command>` | PASS |
| No type errors | `<type-check-command>` | PASS |
| Feature works E2E | Manual: create, edit, delete comment | YES |
| @mentions work | Manual: mention user, verify notification | YES |
| Real-time works | Manual: two browser tabs, verify sync | YES |
| Search works | Manual: search for comment text | YES |
| No regressions | Existing task pages unchanged | YES |
```

---

## Why This Implementation Guide Works

1. **Clear phase goals**: Each phase has a single goal statement
2. **Concrete deliverables**: Specific checkboxes for what must be done
3. **Files listed**: Exact paths make implementation clear
4. **Dependencies explicit**: Clear ordering and blockers
5. **Required Tests are BLOCKING**: Every phase specifies exact test files with minimum counts - no phase can complete without them
6. **Pre-Completion Checklist**: Explicit checklist that MUST be fully checked before marking complete
7. **Verification script**: Runnable command to validate all checks pass
8. **Risks identified**: Known challenges called out early

## Key Patterns

### Required Tests Section (CRITICAL)
Every phase MUST have a "Required Tests" table that specifies:
- **Test file name**: Exact file that must exist
- **Minimum test count**: How many tests are required
- **Coverage description**: What the tests must cover

This prevents "phase complete with no tests" scenarios. The agent cannot mark a phase complete unless these tests exist and pass.

### Pre-Completion Checklist
Replace vague "Phase-Specific Checks" with explicit checklist:
- Use `- [ ]` checkboxes
- Bold the test requirements: `**Unit tests written and passing**`
- Always include: `Verification script runs with zero failures`

### Completion Criteria Table
Every phase needs:
- Standard checks (build, lint, type-check, tests)
- Note that tests must include NEW tests, not just existing
- A runnable verification script

### Deliverables as Checkboxes
Use `- [ ]` for deliverables so implementation can track completion.

### Cross-Phase Concerns
Document once at the end:
- Backward compatibility strategy
- Testing strategy overview
- Rollback plan
