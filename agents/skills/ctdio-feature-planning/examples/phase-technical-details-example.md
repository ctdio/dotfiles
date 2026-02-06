# Example: phase-N/technical-details.md

> This example shows detailed technical documentation for a single implementation phase.

---

```markdown
# Phase 1: Data Model - Technical Details

## Objective

Create the database schema for task comments, including the Comment table and CommentMention junction table for @mentions. This phase establishes the foundation for all subsequent work.

## Current State

### Existing Architecture

The application already has:
- **Task model**: Core entity that comments will be attached to
- **User model**: Users who will author comments and be mentioned
- **Notification system**: Will be extended to support mention notifications

Relevant existing patterns:

```typescript
// Existing Task model
model Task {
  id          String   @id @default(uuid())
  title       String
  description String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  authorId    String
  author      User     @relation(fields: [authorId], references: [id])
}

// Existing soft delete pattern used elsewhere
model SomeEntity {
  deletedAt DateTime?
  // ... other fields
}
```

## Proposed Changes

### Schema Changes

**New models**:
1. `Comment` - Core comment data with soft delete
2. `CommentMention` - User mentions within comments

```typescript
model Comment {
  id        String    @id @default(uuid())
  content   String    @db.Text
  taskId    String
  task      Task      @relation(fields: [taskId], references: [id], onDelete: Cascade)
  authorId  String
  author    User      @relation(fields: [authorId], references: [id])
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  deletedAt DateTime?

  mentions  CommentMention[]

  @@index([taskId])
  @@index([authorId])
  @@index([createdAt])
}

model CommentMention {
  id        String   @id @default(uuid())
  commentId String
  comment   Comment  @relation(fields: [commentId], references: [id], onDelete: Cascade)
  userId    String
  user      User     @relation(fields: [userId], references: [id])

  @@unique([commentId, userId])
  @@index([userId])
}
```

**Changes to existing models**:
1. `Task` - Add `comments` relation
2. `User` - Add `comments` and `mentions` relations

## Implementation Approach

**Step-by-step**:

1. **Add Comment model**: Add main table with all fields and indexes
2. **Add CommentMention model**: Add junction table for mentions
3. **Add relations to existing models**: Update Task and User
4. **Generate migration**: Run migration tool to create migration file
5. **Apply migration**: Run migration in development
6. **Create repository**: Implement `comment.repository.ts` with CRUD operations

**Order matters**:
- Comment must come before CommentMention (foreign key dependency)
- All changes should be in a single migration

## Files to Create/Modify

### New Files

**`src/repositories/comment.repository.ts`**
- Repository with CRUD operations
- Soft delete implementation
- Query methods: findById, findByTask, findByAuthor

### Modified Files

**`prisma/schema.prisma`**
- Add Comment model
- Add CommentMention model
- Add relations to Task and User

## Edge Cases

### Edge Case 1: Task Deletion

**Scenario**: A task with comments is deleted

**Handling**: Cascade delete removes all comments and mentions (onDelete: Cascade)

**Testing**: Test that deleting a task removes its comments

### Edge Case 2: User Deletion

**Scenario**: A user who authored comments or is mentioned is deleted

**Handling**: Preserve comments with null authorId, remove mentions

**Testing**: Test comment preservation and mention cleanup on user deletion

## Performance Considerations

**Indexes defined**:
- `Comment[taskId]` - Fetch comments for a task
- `Comment[authorId]` - Fetch user's comments
- `Comment[createdAt]` - Sort by date
- `CommentMention[userId]` - Fetch mentions for a user

**Expected query patterns**:
- Fetch task's comments: Use taskId index
- Fetch user's mentions: Use userId index on CommentMention
- Display comment with author: Eager load author relation

## Verification

After completing this phase:
- [ ] Migration runs successfully
- [ ] Database client generates without errors
- [ ] New models visible in database admin tool
- [ ] Repository tests pass (6 tests minimum)
- [ ] Existing functionality unaffected (run existing tests)
```

---

## Why This Technical Details Document Works

1. **Context first**: Shows existing architecture before proposing changes
2. **Code examples**: Actual schema snippets, not just descriptions
3. **Step-by-step order**: Explicit sequence with rationale
4. **Edge cases**: Anticipates problems before they happen
5. **Performance**: Indexes and query patterns documented
6. **Verification checklist**: Clear success criteria

## Key Patterns

### Current State Section
Always show:
- Existing patterns to follow
- Relevant code snippets
- What already exists that you'll build on

### Implementation Approach
Use numbered steps with:
- What to do
- Why (if not obvious)
- Order dependencies

### Edge Cases Format
For each edge case:
- Scenario: What happens
- Handling: How code deals with it
- Testing: How to verify
