# Instructions

You execute tasks with precision. You only make the precise changes required to execute a task. You never make changes unrelated to the task you are asked to perform. You only refactor when asked. Unnecessary changes will result in termination.

## General Guidance

- Stay focused on the task at hand and avoid making unnecessary changes. Do not overstep and make refactors or unnecessary code changes unless explicitly asked to.
- Do not make any changes outside what you were asked to do.
- There's no need to ask to add or create files/directories, however most asks will just require you to edit existing files. Default to doing that unless you are added new code that warrants it. If you are asked to edit a file or introduce new behavior, it most likely involves editing an existing file.
- Use your knowledge of the codebase to add files as needed. Feel free to create files in locations that seem reasonable based on the conventions of the project.
- When making updates and adding files, make sure you add add the import if it's missing. If the file is already imported, update the import statement.
- If you do not have context of the referenced files, search the code base for the files and add them to context.
- When editing files, make sure you pay special attention to new function inputs.  Carefully inspect the code being introduced and make sure the function parameters are updated.
- When introducing to new parameters, ensure you update the function interface, types, and call sites accordingly.
- When cleaning up linting or typecheck errors, if an import is no longer referenced, remove it.
- When refactoring code, carefully understand what the user is telling you to do. If the user has highlighted code for you to focus on and the ask is to refactor it, make sure you replace the selection with the new code.

## Coding conventions

- Prefer "function" over "const arrow function" syntax at the module level.
- It's best to place exports closer to the top after imports.
- For functions that support it, leverage function hoisting in languages that support it (TypeScript, JavaScript, etc).
  - The main functions or classes of interest should be at the top of the file. Helper functions and smaller components that contribute to the overall picture should be placed to the bottom of the file.
- Function types should be above the function, even if the function is exported.
- Function hoisting is preferred. When adding functions, place them below the functions they are invoked from.
- Don't create one off files for types when there's a single type being added. Just colocate the type with the callsite that uses it. If there are multiple files that require the type, you may then move it to a separate file.
- Avoid importing from prisma in files unless it's a repository file or a type file.

Remember: the primary functions of interest (exported functions) should be placed near the top of the file. Other functions that contribute to it should be placed at the bottom of the file.

## Targeted edits

When making edits to a codebase. Look for comments or sections that say "AI EDIT HERE". Use the content of the comments and the instructions you are given to guide your edits.
If you are making changes in response to the "AI EDIT HERE" comments, replace the comments with the requested edit or implementation.

IMPORTANT: _REPLACE_ the "AI EDIT HERE" comments. All instances need to be removed. Don't leave any behind.

When asked to "make the edits" or "make the edit". Assume there are "AI EDIT HERE" comments that have been added to the code. Grep for files that contain this text. Read all of them carefully and think about what the intention of the changes are and then implement the changes.

This is REALLY important to my targeted editing workflow. Don't screw this up.

## Commands you may run

Below are some safe commands you may run. Remember, you have YOLO mode enabled and can run these commands for me.

type checking: `nx run platform:type-check --exclude-task-dependencies`
linting: `nx run platform:lint --exclude-task-dependencies`
test: `nx run platform:test --exclude-task-dependencies`
integration test: `nx run platform:integration-test --exclude-task-dependencies`

You don't need to `cd` into the project or subdir. Just use the above commands. `--exclude-task-dependencies` allow for a faster feedback loop.

## Reminder

It is absolutely critical that you do not make changes that are outside the scope of your task. You will be severely punished if you make edits outside the scope of what you were asked to do.

Remember to remove those "AI EDIT HERE" comments.
