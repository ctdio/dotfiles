# TypeScript Rules

## Try-Catch Guidelines

**CRITICAL: Variable naming in catch blocks is MANDATORY:**
- **ALWAYS** use `err` in catch blocks (never `error`, `e`, `ex`, or other variations)
- This is a REQUIRED convention - no exceptions
- Violating this rule is considered a critical error

```typescript
try {
  // code that might throw
} catch (err) {
  // handle error using 'err'
}
```

**INCORRECT examples (NEVER use these):**
```typescript
// ❌ WRONG - Do not use 'error'
try {
  await operation();
} catch (error) {
  logger.error(error);
}

// ❌ WRONG - Do not use 'e' 
try {
  await operation();
} catch (e) {
  console.log(e);
}

// ❌ WRONG - Do not use 'ex'
try {
  await operation();
} catch (ex) {
  throw ex;
}
```

**CORRECT example (ALWAYS use this):**
```typescript
// ✅ CORRECT - Always use 'err'
try {
  await operation();
} catch (err) {
  logger.error({ err }, 'Operation failed');
}
```

## Logger Integration

**MANDATORY: Structured logging pattern:**
- **ALWAYS** use bunyan/pino/winston style loggers that accept an object first, then message
- **ALWAYS** place the error in the object as-is under the `err` key
- **NEVER** extract error properties like `err.message` or `err.stack`
- Error objects will be automatically serialized by the logger

```typescript
try {
  await riskyOperation();
} catch (err) {
  logger.error({ err, userId, operationType: 'create' }, 'Failed to create user');
  throw err; // or handle appropriately
}
```

**CRITICAL RULES for error logging:**
- **ALWAYS** use the `err` key in the log object (not `error` or other names)
- **ALWAYS** pass the complete error object intact to the logger
- **NEVER** destructure or extract properties from the error for logging
- **ALWAYS** include relevant context alongside the error

**Exception: Type casting for error handling logic is allowed:**
- You may cast the error to a specific type to safely check properties for business logic
- This is acceptable for conditional error handling, but still log the complete error object

```typescript
try {
  await operation();
} catch (err) {
  // ✅ ALLOWED - Type casting for business logic
  if ((err as { code?: string }).code === 'ENOENT') {
    // Handle file not found specifically
    logger.error({ err, path }, 'File not found');
    return null;
  }
  
  // ✅ CORRECT - Still log complete error
  logger.error({ err, operation: 'file-read' }, 'Operation failed');
  throw err;
}
```

**INCORRECT logging examples (NEVER do this):**
```typescript
// ❌ WRONG - Don't extract error message
catch (err) {
  logger.error({ message: err.message }, 'Failed');
}

// ❌ WRONG - Don't use 'error' key
catch (err) {
  logger.error({ error: err }, 'Failed');
}

// ❌ WRONG - Don't pass error as string
catch (err) {
  logger.error('Failed: ' + err.message);
}
```

**CORRECT logging examples (ALWAYS do this):**
```typescript
// ✅ CORRECT - Pass complete error under 'err' key
catch (err) {
  logger.error({ err, userId, action: 'delete' }, 'Failed to delete user');
}

// ✅ CORRECT - Include business context
catch (err) {
  logger.error({ err, orderId, customerId }, 'Order processing failed');
}
```

## Type Safety Rules

**CRITICAL: Never use `any` types as a solution to type errors:**
- Using `any` defeats the purpose of TypeScript and removes all type safety
- `any` is a cop-out solution that creates technical debt and runtime risks
- **ALWAYS** find the proper type solution instead of defaulting to `any`

**FORBIDDEN patterns (NEVER do this):**
```typescript
// ❌ WRONG - Don't use 'any' to bypass type errors
const data: any = await fetchData();
const result: any = processData(data);

// ❌ WRONG - Don't cast to 'any' to fix type issues
const user = (userData as any).profile.settings;

// ❌ WRONG - Don't use 'any' for function parameters
function handleEvent(event: any) {
  return event.target.value;
}
```

**CORRECT solutions (ALWAYS do this instead):**
```typescript
// ✅ CORRECT - Define proper interfaces
interface ApiResponse {
  data: UserData[];
  status: number;
}
const response: ApiResponse = await fetchData();

// ✅ CORRECT - Use proper type assertions with specific types
interface UserProfile {
  profile: {
    settings: UserSettings;
  };
}
const user = (userData as UserProfile).profile.settings;

// ✅ CORRECT - Define specific event types
function handleEvent(event: React.ChangeEvent<HTMLInputElement>) {
  return event.target.value;
}

// ✅ CORRECT - Use unknown for truly unknown data, then narrow
function processUnknownData(data: unknown) {
  if (typeof data === 'object' && data !== null && 'id' in data) {
    // Now TypeScript knows data has an 'id' property
    return (data as { id: string }).id;
  }
  throw new Error('Invalid data format');
}
```

**Acceptable alternatives to `any`:**
- `unknown` - for truly unknown data that needs runtime type checking
- Specific type assertions with interfaces
- Union types for multiple possible types
- Generic types for reusable components
- `object` or `Record<string, unknown>` for loose object types

**When encountering type errors:**
1. **First**: Understand what the actual type should be
2. **Second**: Define proper interfaces or types
3. **Third**: Use type assertions with specific types
4. **Last resort**: Use `unknown` and add proper type guards
5. **NEVER**: Use `any` as a solution
