# Instructions

You execute tasks with precision. You make only the changes required to complete the requested task, including necessary supporting changes like imports, types, and function signatures.

## Scope Guidelines

**Core Principle:** Make changes that are directly required or logically necessary to complete the task.

**Allowed changes:**
- Direct implementation of the requested feature/fix
- Adding imports when introducing new dependencies
- Updating function signatures and types when adding parameters
- Creating files when new functionality requires separate modules
- Removing unused imports during cleanup tasks

**Prohibited changes:**
- Refactoring existing code unless explicitly requested
- Style changes unrelated to the task
- Adding features not requested
- Modifying unrelated files or functions

## File Management

- **Default approach:** Edit existing files when implementing new behavior
- **Create new files when:** Adding functionality that warrants separate modules based on project conventions
- **File location:** Use existing project structure and naming conventions
- **Imports:** Always add required imports and update existing import statements as needed

## Coding Conventions

**Core principle:** Always follow existing codebase patterns and conventions when adding new code.

**Discovery process:**
- Before writing new code, examine existing similar files to understand patterns
- Check imports in existing files to see what libraries/frameworks are used
- Look at neighboring components/functions to understand naming conventions
- Follow established project architecture and file organization

**Function syntax and organization:**
- Prefer "function" over "const arrow function" syntax at the module level
- Place exports closer to the top after imports
- Use function hoisting in supported languages (TypeScript, JavaScript)

**Function placement hierarchy:**
1. **Top of file:** Main exported functions, classes, variables, and constants
2. **Bottom of file:** Helper functions and supporting components
3. **Above functions:** Function types, even for exported functions

**Type management:**
- **Single use:** Colocate types with their callsite
- **Multiple files need the type:** Move to a separate shared type file
- **Decision point:** If 3+ files use the same type, create a dedicated type file

**Library and framework usage:**
- NEVER assume a library is available - always verify it's already used in the codebase
- Check package.json, imports in similar files, or existing usage patterns
- When creating new components, study existing components for framework choice and patterns
- Match existing code style, naming conventions, and architectural decisions

**Import patterns:**
- Avoid dynamic imports with `await import()` unless absolutely necessary for code splitting or conditional loading
- Prefer static imports at the top of files for better tree shaking and bundle analysis
- Only use dynamic imports when the module needs to be loaded conditionally at runtime

## Implementation Guidelines

**Function changes:**
- Pay attention to function parameters when introducing new code
- When adding parameters: update function interfaces, types, and all call sites
- Verify all call sites still work after parameter changes

**Error handling:**
- If changes break existing functionality, fix the breakage as part of the task
- Run validation commands after implementation to catch issues
- Address compilation errors before considering the task complete

**Cleanup tasks specifically include:**
- Removing unused imports
- Fixing linting errors
- Updating deprecated patterns

## Targeted Edits

When making edits to a codebase:
1. Look for comments marked "AI EDIT HERE" (or shorthand "AEH")
2. Use comment content and given instructions to guide your implementation
3. **Always replace "AI EDIT HERE"/"AEH" comments** with the actual implementation - do not leave any behind

## Command Shortcuts

**AEH** - Shorthand for "AI EDIT HERE" - place in comments to mark edit locations
**PEH** - "Plan the edit" - analyze and plan the approach without implementing anything
**mte** - "Make the edit" - search for AEH/AI EDIT HERE comments and implement all marked changes
**c** - "continue" - proceed with the current task or implementation

When asked to "make the edits" or "mte":
1. Search for files containing "AI EDIT HERE" or "AEH"
2. Read all instances carefully to understand the intended changes.
3. Read surrounding context to understand the task and any constraints.
4. Implement the changes and remove all "AI EDIT HERE"/"AEH" comments

## Validation

- Run appropriate validation commands after completing implementation
- Address any errors or warnings before considering the task complete
- Check project-specific prompt files for validation commands if available
