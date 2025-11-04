# Documentation Templates and Patterns

This reference provides templates for generating structured learning documentation.

## Architecture Overview Template

```markdown
# Architectural Overview

## System Purpose
[What does this system do? What problems does it solve?]

## Architectural Style
[Is this a monolith, microservices, layered architecture, event-driven, etc.?]

## Key Architectural Decisions
1. **[Decision Name]**
   - **Rationale**: Why was this approach chosen?
   - **Trade-offs**: What are the benefits and drawbacks?
   - **Alternatives considered**: What else was evaluated?

## Major Components
- **[Component Name]**: [Responsibility and role]
- **[Component Name]**: [Responsibility and role]

## Data Flow
[Describe how data moves through the system]
1. Entry point: [Where does data come from?]
2. Processing: [How is data transformed?]
3. Storage: [Where is data persisted?]
4. Output: [Where does data go?]

## Integration Points
- **[External System]**: [How and why does the system integrate?]

## Technology Stack
- **Language(s)**: [Primary programming languages]
- **Framework(s)**: [Main frameworks used]
- **Database(s)**: [Data storage solutions]
- **Infrastructure**: [Deployment and hosting]

## Scalability Considerations
[How does the system handle growth? What are the bottlenecks?]

## Security Model
[How is authentication/authorization handled? What are security boundaries?]
```

## Concept Documentation Template

```markdown
# [Concept Name]

## What Is It?
[Clear, concise definition in 1-2 sentences]

## Why Does It Exist?
[The problem this concept solves or the purpose it serves]

## Where Is It Used?
[List files/modules where this concept appears]
- `path/to/file.ts`: [How it's used here]
- `path/to/another.py`: [How it's used here]

## Key Characteristics
- **[Characteristic]**: [Description]
- **[Characteristic]**: [Description]

## Related Concepts
- **[Related Concept]**: [How they relate]
- **[Related Concept]**: [How they relate]

## Example Usage
\`\`\`[language]
// Code example showing the concept in action
\`\`\`

## Common Patterns
1. **[Pattern Name]**: [When and how this pattern is used]
2. **[Pattern Name]**: [When and how this pattern is used]

## Gotchas and Edge Cases
- [Important things to know or watch out for]
```

## Module Documentation Template

```markdown
# Module: [Module Name]

## Purpose
[What is this module responsible for? What role does it play?]

## Public Interface
[What does this module export or expose?]

### Key Functions/Classes
- **[Name]**: [What it does, key parameters, return value]
- **[Name]**: [What it does, key parameters, return value]

## Dependencies
- **[Module/Package]**: [Why is this dependency needed?]
- **[Module/Package]**: [Why is this dependency needed?]

## Internal Structure
[How is this module organized internally?]
- `[file.ts]`: [Responsibility]
- `[file.ts]`: [Responsibility]

## Data Flow Within Module
1. [Input/Entry point]
2. [Processing steps]
3. [Output/Side effects]

## Usage Examples
\`\`\`[language]
// Example of how other parts of the codebase use this module
\`\`\`

## Testing
- Test location: `[path to tests]`
- Coverage: [What is tested? What isn't?]

## Future Considerations
[Known TODOs, planned improvements, or technical debt]
```

## Learning Path Template

```markdown
# Learning Path: [Topic or Feature]

## Prerequisites
Before diving into this topic, you should understand:
- [Concept or module to understand first]
- [Concept or module to understand first]

## Reading Order
Follow this sequence for optimal understanding:

1. **Start Here**: [File or concept]
   - Focus on: [What to pay attention to]
   - Skip: [What can be skipped initially]

2. **Next**: [File or concept]
   - Look for: [Key patterns or ideas]
   - Connect to: [How this relates to what you've learned]

3. **Then**: [File or concept]
   - Understand: [Core concepts to grasp]

4. **Finally**: [File or concept]
   - This will show: [What clicking together]

## Key Questions to Answer
As you explore, try to answer these questions:
1. [Question about architecture/design]
2. [Question about implementation]
3. [Question about trade-offs]

## Hands-On Exercise
[Optional: Suggest a small modification or experiment to solidify understanding]

## Common Confusion Points
- **[Confusing Topic]**: [Clarification]
- **[Confusing Topic]**: [Clarification]
```

## Knowledge Check Template

Use these questions to assess understanding before creating documentation:

1. **Project Type**: What kind of project is this? (web app, CLI, library, service, etc.)
2. **Experience Level**: How familiar are you with [relevant technology]?
3. **Learning Goal**: What specifically do you want to understand?
4. **Time Investment**: Deep dive or quick overview?
5. **Prior Context**: What have you explored already?

## Documentation Depth Levels

### Level 1: High-Level Overview (30,000 ft view)
- Architectural style and major components
- Primary technology stack
- Main data flows
- 1-2 pages maximum

### Level 2: Conceptual Understanding (10,000 ft view)
- Key abstractions and patterns
- Module responsibilities
- Integration points
- 5-10 pages

### Level 3: Detailed Implementation (Ground level)
- Function-by-function breakdown
- Detailed data structures
- Error handling patterns
- Code-level examples
- 20+ pages

## Cross-Reference Patterns

When documenting, create bidirectional links:

**In concept docs**: Link to modules that implement the concept
**In module docs**: Link to concepts the module uses
**In architecture docs**: Link to both concepts and modules

Example:
```markdown
This module implements the [Observer Pattern](../concepts/observer-pattern.md).
It is used by [EventBus](../modules/event-bus.md) for event distribution.
```
