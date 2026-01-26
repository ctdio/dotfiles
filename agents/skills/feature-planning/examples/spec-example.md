# Example: spec.md

> This example shows how to write a comprehensive specification that serves as the authoritative source of requirements.

---

```markdown
# Task Comments - Specification

> **This document defines the requirements that MUST be met for this feature to be complete.**
> Implementation agents should reference this spec continuously and verify all requirements are satisfied.

## Functional Requirements

### FR-1: Create Comment

**Description**: Users with Editor+ role can add comments to tasks they have access to.

**Acceptance Criteria**:
- [ ] Comment has required field: content (string, max 10000 chars)
- [ ] Comment is associated with exactly one task (taskId)
- [ ] Comment is associated with the creating user (authorId)
- [ ] Comment stores createdAt and updatedAt timestamps
- [ ] Empty or whitespace-only comments are rejected
- [ ] Creating a comment triggers a `COMMENT_ADDED` event for notifications

**Verification**: Unit tests for service, integration tests for API endpoint

---

### FR-2: Edit Comment

**Description**: Users can edit their own comments within 24 hours of creation.

**Acceptance Criteria**:
- [ ] Only the comment author can edit their comment
- [ ] Edits are allowed within 24 hours of creation
- [ ] Edits after 24 hours are rejected with clear error message
- [ ] Edit updates the content and updatedAt timestamp
- [ ] Edit history is preserved (editedAt timestamp visible to users)

**Verification**: Unit tests for edit logic, integration tests with time-based scenarios

---

### FR-3: Delete Comment

**Description**: Users can delete their own comments.

**Acceptance Criteria**:
- [ ] Only the comment author can delete their comment
- [ ] Deletion is soft delete (deletedAt timestamp)
- [ ] Deleted comments show "[Comment deleted]" placeholder in thread
- [ ] Deleted comments preserve threading structure (replies remain visible)
- [ ] Admins can hard-delete comments if needed (separate admin endpoint)

**Verification**: Integration tests for delete, UI tests for placeholder display

---

### FR-4: @Mention Users

**Description**: Comments can mention other users using @username syntax.

**Acceptance Criteria**:
- [ ] @username syntax is parsed and converted to structured mention data
- [ ] Mentioned users are validated (must exist and have task access)
- [ ] Invalid mentions are displayed as plain text (no error)
- [ ] Mentioned users receive a notification
- [ ] Mentions are displayed as clickable links to user profile

**Verification**: Unit tests for mention parsing, integration tests for notifications

---

### FR-5: Display Comment Thread

**Description**: Comments are displayed in a threaded timeline on the task detail view.

**Acceptance Criteria**:
- [ ] Comments display in chronological order (oldest first)
- [ ] Each comment shows: author avatar, author name, content, timestamp
- [ ] Edited comments show "edited" indicator with edit timestamp
- [ ] Deleted comments show "[Comment deleted]" placeholder
- [ ] Long comments are truncated with "Show more" expansion
- [ ] Thread supports keyboard navigation (Tab, Enter, Escape)

**Verification**: Component tests, accessibility audit

---

### FR-6: Real-time Updates

**Description**: Comment thread updates in real-time when other users add comments.

**Acceptance Criteria**:
- [ ] New comments appear without page refresh
- [ ] Comment edits update in real-time
- [ ] Comment deletions update in real-time
- [ ] Real-time updates work across browser tabs
- [ ] Graceful fallback to polling if WebSocket unavailable

**Verification**: Integration tests with multiple clients, E2E tests

---

## Non-Functional Requirements

### NFR-1: Performance

**Description**: Comment operations should be fast even for tasks with many comments.

**Acceptance Criteria**:
- [ ] Create comment: < 300ms response time
- [ ] Load comments: < 200ms for tasks with < 50 comments
- [ ] Load comments: < 500ms for tasks with < 200 comments (paginated)
- [ ] Real-time updates delivered within 1 second

**Verification**: Load testing, performance benchmarks

---

### NFR-2: Security & Permissions

**Description**: Proper authorization for all comment operations.

**Acceptance Criteria**:
- [ ] Only users with task access can view comments
- [ ] Only Editor+ can create comments
- [ ] Only comment author can edit/delete their comments
- [ ] @mentions only work for users with task access
- [ ] API endpoints validate permissions before any operation

**Verification**: Permission tests for each endpoint, security review

---

### NFR-3: Error Handling

**Description**: Clear error messages for invalid operations.

**Acceptance Criteria**:
- [ ] Validation errors return specific field errors (e.g., "content too long")
- [ ] Permission errors return 403 with clear message
- [ ] Not found errors return 404
- [ ] Rate limiting returns 429 with retry-after header
- [ ] All errors are logged with request context

**Verification**: Error scenario tests

---

## Constraints

### C-1: Maximum Comment Length

**Constraint**: Comments are limited to 10,000 characters.

**Reason**: Prevents abuse, ensures reasonable page load times, aligns with similar products.

---

### C-2: Soft Delete Required

**Constraint**: Comments must be soft-deleted, never hard-deleted (except by admin).

**Reason**: Preserves threading integrity and audit trail.

---

### C-3: Edit Window

**Constraint**: Comments can only be edited within 24 hours of creation.

**Reason**: Prevents revisionist history, maintains trust in comment thread.

---

## Out of Scope

- Rich text formatting (bold, italic, etc.) - plain text only for MVP
- File attachments on comments
- Emoji reactions to comments
- Comment pinning
- Nested replies (threading beyond one level)
- Comment templates
- Bulk comment operations

---

## Testing Requirements

### Unit Tests

| Test File | Description | Requirements |
|-----------|-------------|--------------|
| `comment.service.test.ts` | Service layer CRUD operations | FR-1, FR-2, FR-3 |
| `mention-parser.test.ts` | @mention parsing logic | FR-4 |

### Integration Tests

| Test File | Description | Requirements |
|-----------|-------------|--------------|
| `comments-api.test.ts` | API endpoints CRUD | FR-1, FR-2, FR-3, FR-4 |
| `comments-permissions.test.ts` | Permission checks | NFR-2 |
| `comments-realtime.test.ts` | WebSocket updates | FR-6 |

---

## Verification Checklist

### Functional Requirements
- [ ] FR-1: Create Comment - All criteria met
- [ ] FR-2: Edit Comment - All criteria met
- [ ] FR-3: Delete Comment - All criteria met
- [ ] FR-4: @Mention Users - All criteria met
- [ ] FR-5: Display Comment Thread - All criteria met
- [ ] FR-6: Real-time Updates - All criteria met

### Non-Functional Requirements
- [ ] NFR-1: Performance - All criteria met
- [ ] NFR-2: Security & Permissions - All criteria met
- [ ] NFR-3: Error Handling - All criteria met

### Constraints
- [ ] C-1: Maximum Comment Length - Enforced
- [ ] C-2: Soft Delete Required - Implemented
- [ ] C-3: Edit Window - Enforced

---

## Requirement Traceability

| Requirement | Phase | Primary Files |
|-------------|-------|---------------|
| FR-1 | 1, 2 | schema, comment.service.ts, route.ts |
| FR-2 | 2 | comment.service.ts, route.ts |
| FR-3 | 2 | comment.service.ts, route.ts |
| FR-4 | 2 | mention-parser.ts, notification.service.ts |
| FR-5 | 3 | comment-thread.tsx, comment-item.tsx |
| FR-6 | 3 | comment-subscription.ts, websocket |
```

---

## Why This Spec Works

1. **Clear structure**: Each requirement has description, acceptance criteria, and verification
2. **Testable criteria**: Every criterion is specific and verifiable
3. **Traceability**: Requirements map to phases and files
4. **Completeness**: Covers functional, non-functional, constraints, and out-of-scope
5. **Verification checklist**: Easy to track what's done

## Key Patterns

### Requirement IDs
- Use `FR-N` for functional requirements
- Use `NFR-N` for non-functional requirements
- Use `C-N` for constraints

### Acceptance Criteria Format
Each criterion should be:
- Specific (not vague)
- Testable (can write a test for it)
- Binary (pass or fail)

### Verification Section
Always specify HOW to verify:
- Unit tests
- Integration tests
- Manual verification
- Performance benchmarks
