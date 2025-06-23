# Platform Project Rules

## Validation Commands

Run these commands after completing implementation to ensure code quality.
You don't need to run all of them, use the ones that feel most relevant to your work.

- **Type checking:** `nx run platform:type-check --exclude-task-dependencies`
- **Linting:** `nx run platform:lint --exclude-task-dependencies`
- **Testing:** `nx run platform:test --exclude-task-dependencies`
- **Integration testing:** `nx run platform:integration-test --exclude-task-dependencies`

## Usage Notes

- Run commands from the project root directory
- `--exclude-task-dependencies` flag enables faster feedback loops
- Address any errors or warnings before considering tasks complete

## Project Convention Discovery

Before implementing any changes, always look for and follow existing project conventions by checking these common configuration files:

- **CLAUDE.md** - Project-specific Claude instructions (root or .claude/ directory)
- **.cursorrules** - Cursor IDE project rules and conventions
- **AGENT.md** - OpenAI agent instructions and project guidelines
- **README.md** - Project setup and development guidelines
- **package.json** - Dependencies, scripts, and project metadata
- **tsconfig.json** - TypeScript configuration and path mappings
- **.eslintrc** - Code style and linting rules

Follow the patterns, naming conventions, architectural decisions, and coding standards established in these files.

## Project-Specific Conventions

- **Server/Client code separation:** Never mix server-side and client-side code. Do not import services or repositories in client components unless the component is explicitly a React Server Component
- **Prisma imports:** Only import from `@prisma/client` in repository layer files (files that directly interact with the database). Do not import Prisma in service, controller, or other layers
- Follow nx monorepo structure and naming conventions

## Architecture: Services and Repositories

**Repository Layer:**
- Repositories are classes that handle data access and database operations
- Only repositories should import and use Prisma directly
- Naming convention: `*Repository` (e.g., `UserRepository`, `PostRepository`)
- Export both the class and an instance

```typescript
// user.repository.ts
import { PrismaClient } from '@prisma/client';

export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async create(data: { email: string; name: string }) {
    return this.prisma.user.create({ data });
  }
}

// Export both class and instance
export const userRepository = new UserRepository(prisma);
```

**Service Layer:**
- Services are classes that contain business logic
- Services should never import or use Prisma directly
- Services use repositories for data access
- Naming convention: `*Service` (e.g., `UserService`, `PostService`)
- Export both the class and an instance

```typescript
// user.service.ts
import { UserRepository, userRepository } from './user.repository';

export class UserService {
  constructor(private userRepository: UserRepository) {}

  async getUserById(id: string) {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  }

  async createUser(email: string, name: string) {
    // Business logic here
    if (!email.includes('@')) {
      throw new Error('Invalid email');
    }

    return this.userRepository.create({ email, name });
  }
}

// Export both class and instance
export const userService = new UserService(userRepository);
```

**Usage Guidelines:**
- Controllers and API handlers should use services, not repositories directly
- Services handle business logic and validation
- Repositories handle pure data access operations
- Both layers should be easily testable through dependency injection

## Error Handling and Telemetry

**Exception Capture Guidelines:**
- Import the `captureException` function from `@/lib/telemetry`: `import { captureException } from '@/lib/telemetry'`
- Capture exceptions using `captureException(err)` in scenarios where:
  - The exception is being thrown but NOT being propagated (rethrown)
  - The error represents a meaningful failure worth collecting feedback on
  - Consider the caller or callsite context before capturing

**When to capture exceptions:**
- Terminal error handlers (errors that end a process flow)
- Business logic failures that should be monitored
- Infrastructure errors (database, external API failures)
- Validation errors that indicate data integrity issues

**When NOT to capture exceptions:**
- If the error is being rethrown (`throw err`) - let the upstream handler capture it
- Transient errors that are expected and handled gracefully
- Control flow exceptions (like breaking out of loops)

```typescript
try {
  await riskyOperation();
} catch (err) {
  logger.error({ err, context }, 'Operation failed');
  
  // Capture if this is a terminal error (not being rethrown)
  captureException(err);
  
  // Return graceful response instead of rethrowing
  return { success: false, error: 'Operation failed' };
}

// vs.

try {
  await riskyOperation();
} catch (err) {
  logger.error({ err, context }, 'Operation failed');
  
  // Don't capture here - let upstream handler decide
  throw err; // Being rethrown
}
```
