# Fix Branch Errors

Run linting and typechecking, then fix any errors related to changes in the current branch.

## Steps:
1. Identify changed files in the current branch compared to the base branch
2. Run linting commands on the project
3. Run typecheck commands on the project
4. Filter errors to only those in changed files
5. Systematically fix each error

## Commands to run:
```bash
# Get changed files
git diff --name-only $(git merge-base HEAD origin/master)..HEAD

# Run linting (adjust these based on your project)
bun run lint
nx run platform:lint

# Run typecheck (adjust these based on your project)
bun run typecheck
nx run platform:type-check
```

## Instructions:
- First determine what type of project this is by checking for package.json, pyproject.toml, etc.
- Identify the appropriate lint and typecheck commands for the project
- Run the commands and capture their output
- Parse the output to identify errors
- Filter to only errors in files changed in the current branch
- Create a todo list of all errors to fix
- Systematically fix each error, marking todos as complete
- After fixing all errors, run the commands again to verify everything passes
- If any errors remain, repeat the process

Remember to only fix errors in files that were changed in the current branch, not unrelated errors in other files.
