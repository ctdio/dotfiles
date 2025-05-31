# Platform Project Commands

## Validation Commands

Run these commands after completing implementation to ensure code quality:

- **Type checking:** `nx run platform:type-check --exclude-task-dependencies`
- **Linting:** `nx run platform:lint --exclude-task-dependencies`  
- **Testing:** `nx run platform:test --exclude-task-dependencies`
- **Integration testing:** `nx run platform:integration-test --exclude-task-dependencies`

## Usage Notes

- Run commands from the project root directory
- `--exclude-task-dependencies` flag enables faster feedback loops
- Address any errors or warnings before considering tasks complete

## Project-Specific Conventions

- Avoid importing from prisma in files unless it's a repository file or a type file
- Follow nx monorepo structure and naming conventions