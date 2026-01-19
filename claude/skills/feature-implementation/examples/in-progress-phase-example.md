# Example: In-Progress Phase State

> This example shows how to track state when actively working on a phase, including test status (red/green) and task progress.

---

```markdown
## Phase 2: Core API

**Status**: in_progress
**Started**: 2026-01-16
**Commit**: ⏳ Pending (create after verification passes)

### Spec Requirements to Address
- FR-1 (completion): Service layer and CRUD endpoints
- FR-2: Edit Comment with 24h window
- FR-3: Delete Comment (soft delete)
- FR-4 (completion): Mention parsing and storage
- NFR-2: Security & Permissions
- NFR-3: Error Handling

### Tests Written (TDD)

> **TDD Approach**: Write tests FIRST (they should fail), then implement to make them pass.

**Unit Tests**:
- ✅ `create - should create comment when user has access` - Passing
- ✅ `create - should reject when user lacks task access` - Passing
- ✅ `create - should parse and store mentions` - Passing
- ✅ `create - should ignore invalid mentions` - Passing
- ✅ `get - should return comment when user has access` - Passing
- ✅ `get - should reject when user lacks access` - Passing
- ✅ `get - should return 404 for non-existent comment` - Passing
- 🔴 `update - should update when user is author` - FAILING (implementing now)
- 🔴 `update - should reject when user is not author` - FAILING
- ⏳ `update - should reject after 24 hours` - Not written yet
- ⏳ `update - should return 404 for non-existent comment` - Not written yet
- ⏳ `delete - should soft delete when user is author` - Not written yet
- ⏳ `delete - should reject when user is not author` - Not written yet
- ⏳ `delete - should return 404 for non-existent comment` - Not written yet
- ⏳ `list - should return comments for task` - Not written yet
- ⏳ `list - should exclude soft-deleted comments` - Not written yet
- ⏳ `list - should reject when user lacks task access` - Not written yet

**Integration Tests**:
- ✅ `POST /comments - should create comment` - Passing
- ✅ `POST /comments - should create comment with mentions` - Passing
- ✅ `POST /comments - should reject invalid input` - Passing
- ✅ `GET /comments - should list task comments` - Passing
- ✅ `GET /comments/:id - should get single comment` - Passing
- ✅ `GET /comments/:id - should return 404 for non-existent` - Passing
- 🔴 `PATCH /comments/:id - should update comment` - FAILING (blocked by unit tests)
- ⏳ `PATCH /comments/:id - should reject after 24h` - Not written yet
- ⏳ `DELETE /comments/:id - should soft delete comment` - Not written yet
- ⏳ `DELETE /comments/:id - should return 404 for non-existent` - Not written yet

### Test Summary
- **Total**: 27 tests planned
- **Written**: 17 tests
- **Passing**: 13 tests ✅
- **Failing**: 4 tests 🔴
- **Pending**: 10 tests ⏳

### Completed Tasks
- ✅ Created CommentService with basic structure
- ✅ Implemented createComment with permission checks
- ✅ Implemented getComment with permission checks
- ✅ Implemented listComments with permission checks
- ✅ Created API routes for POST and GET
- ✅ Wrote unit tests for create (4 tests)
- ✅ Wrote unit tests for get (3 tests)
- ✅ Wrote integration tests for POST (3 tests)
- ✅ Wrote integration tests for GET (3 tests)

### In Progress
- 🔄 Implementing updateComment method
  - Tests written but failing (expected in TDD)
  - Working on author-only permission check
  - Need to add 24-hour window validation

### Pending Tasks
- ⏳ Write unit tests for update (2 more tests needed)
- ⏳ Write unit tests for delete (3 tests)
- ⏳ Write unit tests for list (3 tests)
- ⏳ Implement deleteComment (soft delete)
- ⏳ Write integration tests for PATCH (2 tests)
- ⏳ Write integration tests for DELETE (2 tests)
- ⏳ Run full verification script

### Blocked Tasks
None currently

### Current Notes
- Following existing service patterns from task.service.ts
- Using permission helpers for task access checks
- Author-only edit/delete uses direct userId comparison
- Need to clarify: should edit window be configurable per workspace?

### Session Context
- Working on update functionality
- Next step: Finish updateComment to make failing tests pass
- After that: Write delete tests (TDD), then implement delete
```

---

## Key Patterns for In-Progress Tracking

### Test Status Indicators
- ✅ Passing
- 🔴 FAILING (expected in TDD - actively working on)
- ⏳ Not written yet

### Test Summary Stats
Track aggregate progress:
- Total planned
- Written
- Passing
- Failing
- Pending

### Session Context
At the bottom, note:
- What you were actively working on
- Immediate next step
- Any pending questions/decisions

## TDD Workflow in State Tracking

1. **Write tests FIRST** - Mark them as 🔴 FAILING
2. **Implement code** - Note which tests you're making pass
3. **Tests pass** - Update to ✅
4. **Refactor** - Note any cleanup done
5. **Move to next feature** - Write new failing tests

This creates a clear audit trail of your TDD approach.
