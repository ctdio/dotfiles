# Guided Learning Workflow

This reference describes how to guide users through understanding a codebase using top-down learning principles.

## Core Principles

1. **Start Broad, Then Narrow**: Begin with architecture, then concepts, then specific modules
2. **Build Mental Models**: Help users create frameworks for organizing knowledge
3. **Connect the Dots**: Explicitly link new information to previously learned concepts
4. **Check Understanding**: Assess knowledge level before diving deeper
5. **Adaptive Depth**: Adjust detail level based on user's background and goals

## Interaction Patterns

### Pattern 1: Initial Assessment

Before generating or presenting documentation, understand the learner:

**Questions to ask:**
```
To best guide you through this codebase:

1. What's your familiarity with [primary technology/framework]?
   - [ ] Expert - I use it daily
   - [ ] Intermediate - I've built projects with it
   - [ ] Beginner - I've read about it
   - [ ] New - Never used it

2. What's your goal?
   - [ ] Quick overview to understand what this does
   - [ ] Deep understanding to contribute code
   - [ ] Specific feature understanding
   - [ ] Architectural learning

3. Do you have specific questions or areas of interest?
```

### Pattern 2: Guided Walkthrough

Structure learning as a conversation with checkpoints:

**Step 1: Set Context**
```
We're going to explore [project name]. It's a [type] that [purpose].
The architecture follows a [pattern] approach.

Does this high-level description match what you expected?
```

**Step 2: Build Foundation**
```
Let's start with the core concepts. This codebase uses:
- [Concept 1]: [Brief explanation]
- [Concept 2]: [Brief explanation]

Which of these would you like to understand first?
```

**Step 3: Progressive Detail**
```
Now that you understand [concept], let's see how it's implemented
in the [module name] module.

[Present relevant information]

Ready to see how this connects to [related concept]?
```

**Step 4: Synthesis**
```
Let's connect what we've covered:
1. [Concept A] provides [capability]
2. [Module B] implements it by [approach]
3. Together they enable [feature]

Does this mental model make sense?
```

### Pattern 3: Exploration Mode

When user wants to explore specific areas:

**Listen for signals:**
- "How does [feature] work?"
- "I want to understand [component]"
- "Why was [decision] made?"
- "Show me [specific code]"

**Response structure:**
1. Confirm the scope: "You want to understand how [X] works, correct?"
2. Check prerequisites: "This uses [concept Y]. Are you familiar with it?"
3. Present information at appropriate depth
4. Offer next steps: "Would you like to see [related topic] or go deeper into [current topic]?"

### Pattern 4: Code Navigation

When presenting code:

**For beginners:**
- Start with high-level pseudocode or diagrams
- Explain one concept at a time
- Use analogies to familiar concepts
- Hide boilerplate initially

**For intermediate:**
- Show actual code with annotations
- Explain key decisions and trade-offs
- Reference related patterns
- Show typical usage

**For experts:**
- Present code with minimal commentary
- Focus on novel or unusual approaches
- Discuss performance implications
- Point out edge cases

## Knowledge Level Indicators

### Signals of High Expertise:
- Uses domain-specific terminology correctly
- Asks about edge cases or performance
- Questions architectural decisions
- References similar patterns from other projects

**Adjust by:**
- Reducing explanations of basics
- Focusing on unique aspects of this codebase
- Discussing trade-offs and alternatives
- Comparing to other approaches

### Signals of Learning:
- Asks "what is X?" questions
- Seeks clarification on terminology
- Requests examples
- Needs conceptual analogies

**Adjust by:**
- Providing more context
- Using analogies and examples
- Checking understanding frequently
- Breaking complex topics into smaller pieces

## Documentation Generation Strategy

### Phase 1: High-Level Documentation (Always Start Here)

Generate or reference:
1. `architecture/overview.md` - The big picture
2. `index.md` - Navigation and project stats
3. Identify 3-5 key concepts to document

**Purpose**: Give the user a mental map of the project

### Phase 2: Conceptual Documentation (On Demand)

Generate when user:
- Asks "what is [concept]?"
- Encounters unfamiliar patterns
- Needs deeper understanding

Create: `concepts/[concept-name].md`

### Phase 3: Module Documentation (Detailed Exploration)

Generate when user:
- Wants to understand specific functionality
- Plans to modify or extend code
- Needs implementation details

Create: `modules/[module-name].md`

### Phase 4: Custom Learning Paths (Advanced)

Create when user:
- Has specific learning goals
- Wants structured progression
- Is studying particular features

Create: `learning-paths/[topic-name].md`

## Conversation Flow Examples

### Example 1: Complete Beginner

```
User: "Help me understand this project"

Claude:
1. Assess: "What's your experience with [technology]?"
2. Based on response, choose starting point
3. If beginner: "Let me create a visual overview first"
4. Generate high-level architecture doc
5. Walk through it interactively
6. Ask: "What would you like to explore first?"
```

### Example 2: Experienced Developer

```
User: "Analyze the architecture"

Claude:
1. Quick check: "I see you're familiar with [tech]. Looking for anything specific?"
2. Generate comprehensive architecture doc
3. Highlight interesting/unusual decisions
4. Offer: "I can dive deeper into [notable pattern]. Interested?"
```

### Example 3: Feature-Specific Learning

```
User: "How does authentication work?"

Claude:
1. Check if concept doc exists for "authentication"
2. If not, generate it using templates
3. Show data flow specific to auth
4. Point to relevant modules
5. Offer: "Want to see the implementation in [module]?"
```

## Adaptive Questioning Techniques

### Use Open Questions for Discovery:
- "What aspects of this project interest you most?"
- "Where do you want to start?"
- "What have you explored so far?"

### Use Closed Questions for Confirmation:
- "Are you familiar with [concept]?"
- "Ready to move to [next topic]?"
- "Does this make sense?"

### Use Probing Questions for Depth:
- "What specifically about [topic] do you want to understand?"
- "How deep should we go here?"
- "What would you do with this knowledge?"

## Progress Tracking

Maintain context of what's been covered:
- Concepts explained
- Modules explored
- Documentation generated
- User's understanding level
- Areas of interest

Reference previous discussions:
```
"Earlier we discussed [concept]. This builds on that by [connection]."
"Remember when we looked at [module]? This is the other side of that interaction."
```

## Red Flags - When to Adjust

**User is lost:**
- Repeating questions
- Confusion about basic concepts
- Not engaging with material

**Action**: Step back, simplify, use analogies

**User is bored:**
- One-word responses
- Wants to skip ahead
- Says "I know this already"

**Action**: Increase pace, depth, or complexity

**User is overwhelmed:**
- Expresses frustration
- Asks to slow down
- Says "this is too much"

**Action**: Break into smaller pieces, take breaks, review
