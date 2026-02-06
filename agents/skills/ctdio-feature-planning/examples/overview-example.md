# Example: overview.md

> This example shows a well-structured overview file that serves as the entry point for understanding a feature plan.

---

```markdown
# Task Comments - Overview

## Problem Statement

Users currently cannot add comments to tasks. This makes collaboration difficult as team members have no way to discuss task details, ask questions, or provide updates without using external tools. Users need a native way to communicate about tasks within the application.

## Solution Summary

Introduce a commenting system for tasks that allows users to add, edit, and delete comments. Comments will support mentions (@user) to notify team members, appear in a threaded timeline on the task detail view, and integrate with the notification system. The feature will be accessible from both the task detail page and a quick-comment action in task lists.

## Impact

**Users Affected**: All workspace members (viewers can read, editors can comment)
**Systems Affected**: Task detail view, notifications, activity feeds, search
**Estimated Complexity**: Moderate

## Implementation Phases

1. **Phase 1: Data Model** - Comment table, user mentions, database indexes
2. **Phase 2: Core API** - CRUD endpoints, permissions, mention parsing
3. **Phase 3: Task Detail UI** - Comment thread component, editor, real-time updates
4. **Phase 4: Notifications & Search** - @mention notifications, comment search indexing

## Key Technical Decisions

- **Separate Comment model** vs embedding in Task: Comments are first-class entities with their own lifecycle (edit history, soft delete). Keeping them separate enables reuse for other commentable entities later.
- **Mention parsing on write**: Parse @mentions when comment is saved, store as structured data. Enables reliable notification delivery and display.
- **Soft delete for comments**: Preserve audit trail and threading integrity. Deleted comments show "[deleted]" placeholder.

## Success Criteria

**Functional:**
- Users can add, edit, and delete comments on tasks
- @mentions notify the mentioned user
- Comments appear in chronological order with threading support
- Comments are searchable

**Quality:**
- Comments load in < 200ms for typical tasks (< 50 comments)
- Real-time updates when other users comment
- Accessible keyboard navigation in comment thread

## Next Steps

1. Read `spec.md` for requirements that MUST be met
2. Read `implementation-guide.md` for phased approach
3. Start with `phase-01-data-model/` when ready to implement
```

---

## Why This Overview Works

1. **Problem Statement**: Clear, specific problem (2-3 sentences)
2. **Solution Summary**: High-level approach without implementation details
3. **Impact**: Who and what is affected
4. **Implementation Phases**: Brief phase list with one-line summaries
5. **Key Technical Decisions**: Critical decisions with brief rationale
6. **Success Criteria**: Measurable outcomes split by category
7. **Next Steps**: Clear navigation to other documents

## Common Mistakes to Avoid

- **Too long**: Keep under 200 lines - this is an entry point, not a deep dive
- **Implementation details**: Save code examples for phase directories
- **Missing rationale**: Key decisions should have brief "why"
- **Vague phases**: Each phase should have a clear one-liner
