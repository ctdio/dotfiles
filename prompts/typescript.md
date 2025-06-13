# TypeScript Rules

## Try-Catch Guidelines

**Variable naming:**
- Always use `err` in catch blocks (not `error`, `e`, or other variations)

```typescript
try {
  // code that might throw
} catch (err) {
  // handle error using 'err'
}
```

## Logger Integration

**Structured logging pattern:**
- Use bunyan/pino/winston style loggers that accept an object first, then message
- Place the error in the object as-is under the `err` key
- Error objects will be automatically serialized by the logger

```typescript
try {
  await riskyOperation();
} catch (err) {
  logger.error({ err, userId, operationType: 'create' }, 'Failed to create user');
  throw err; // or handle appropriately
}
```

**Additional context:**
- Include relevant context properties in the log object alongside `err`
- Keep the error object intact - don't extract properties like `err.message`
- Let the logger handle error serialization automatically
