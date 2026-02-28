---
name: code-reviewing
description: Методология code review — 10 измерений, приоритизация по контексту, стандарты качества. Загружается агентом dev-code-reviewer.
---

# Code Review Methodology

Comprehensive code review methodology for ensuring production-ready quality and maintainable architecture.

## Review Dimensions

Perform systematic analysis across these 10 dimensions:

### 1. Architectural Patterns

- Evaluate adherence to established architectural patterns (MVC, MVVM, Clean Architecture, etc.)
- Assess design patterns usage (Factory, Strategy, Observer, etc.)
- Verify layer separation and dependency direction
- Check for architectural anti-patterns (circular dependencies, god objects, tight coupling)

### 2. Separation of Concerns

- Validate single responsibility principle compliance
- Examine module boundaries and cohesion
- Review business logic vs presentation logic separation
- Assess data layer abstraction and persistence logic isolation

**Good practices:**
- One file = one responsibility (UserService in one file, PaymentService in another)
- Functions < 50 lines; if larger, break into smaller functions
- Maximum 3 levels of nesting; use early returns to reduce nesting
- High-level modules should not depend on low-level details

### 3. Code Readability & Maintainability

- Evaluate naming conventions (variables, functions, classes)
- Assess code organization and file structure
- Check for appropriate use of comments and documentation
- Review complexity metrics (cyclomatic complexity, nesting depth)
- Verify consistent code style and formatting

**Good practices:**
- Meaningful comments focus on "why" rather than obvious "what"
- DRY principle: extract repeated code into functions/modules
- Readable > clever: clear code is better than short but cryptic code
- No magic numbers: extract to named constants (`MAX_UPLOAD_SIZE` not `5242880`)

### 4. Error Handling

- Examine error propagation strategy
- Verify appropriate use of try-catch blocks
- Check error messages clarity and actionability
- Assess graceful degradation and fallback mechanisms
- Review logging practices for debugging and monitoring

**Good practices:**
- Always use try-catch for operations that can fail (API calls, DB operations, file I/O)
- Log with context: include user_id, action, resource_id, error message, stack trace
- Don't swallow errors: always re-throw after logging (unless explicitly handling)
- Fail fast: validate inputs early; throw errors immediately when invalid
- User-friendly errors: show generic message to users, log details internally

### 5. Type Safety (TypeScript/typed languages)

For TypeScript or other typed codebases:

- Validate type definitions completeness and accuracy
- Check for inappropriate use of `any` type (TypeScript) or equivalent loose typing
- Assess interface and type alias design
- Review generic type usage and constraints
- Verify null/undefined handling and optional chaining
- Check for type assertions and their justification

### 6. Testing Coverage

- Evaluate unit test presence and quality
- Assess test coverage for critical paths
- Review test organization and naming
- Check for integration and E2E test needs
- Verify mocking strategies and test isolation
- Assess edge case and error scenario coverage

**Good practices:**
- Tests needed for: business logic, validations, transforms, error handling
- Tests not needed for: simple getters/setters, one-line configs, trivial updates
- Rule: if mocking >3 dependencies → wrong test type, use integration test

### 7. Dependencies Management

- Review new dependencies necessity and appropriateness
- Check for dependency version conflicts
- Assess bundle size impact
- Verify security vulnerabilities (outdated packages)
- Evaluate licensing compatibility

**Good practices:**
- Verify imports exist before using: read source files to confirm exports match expected usage
- Check function signatures: ensure signatures match how you're calling them
- Prefer well-maintained packages: check npm/PyPI activity, security advisories
- Pin major versions: use `^` (caret) for npm to allow patch updates

### 8. Security Considerations

- Check for security vulnerabilities (injection, XSS, CSRF)
- Verify secrets management (no hardcoded credentials)
- Assess input validation and sanitization
- Review authentication and authorization logic
- Check for sensitive data exposure

**Good practices:**
- Never hardcode secrets: use environment variables (`.env`) for all sensitive data
- Always validate input: check types, formats, ranges before processing
- Sanitize user data: before database operations, API calls, or displaying
- Add to .gitignore: `.env`, `*.key`, `credentials.json`, `secrets/`

### 9. Performance Implications

- Identify potential performance bottlenecks
- Review algorithmic complexity
- Check for unnecessary re-renders (React) or recomputations
- Assess memory leak risks
- Evaluate database query efficiency

**Good practices:**
- Avoid N+1 queries: use batch operations, eager loading, or caching
- Cache expensive computations: use memoization for functions
- Prevent memory leaks: clean up event listeners, timers, subscriptions in cleanup functions
- Use pagination for large datasets: don't load all records at once
- Profile before optimizing: measure actual bottlenecks before making changes

### 10. Cross-File Consistency

For the code under review, verify correctness of function/class usage:

**Process:**
1. When code CALLS a function from another file → Read that file, verify signature matches
2. When code USES a class/method → Read class definition, verify method exists and signature matches
3. When code IMPORTS something → Verify import path is correct

**What to check:**
- Function called with correct arguments
- Method exists on the class
- Import paths are valid
- Types match (if TypeScript)

**Report as issue if:**
- Function called with wrong arguments (runtime crash)
- Method doesn't exist (runtime crash)
- Import path broken (load failure)

Read the source files where functions/classes are defined to verify signatures match.

## Dimension Prioritization

Focus on dimensions based on code context:

| Context | Prioritize | Reason |
|---------|------------|--------|
| Auth/login code | Security (8), Error Handling (4) | Auth vulnerabilities are critical |
| User input handling | Security (8), Type Safety (5) | Input validation prevents attacks |
| Database queries | Security (8), Performance (9) | SQL injection, N+1 queries |
| New feature | Architecture (1), Testing (6) | Foundation for future changes |
| Refactoring | Cross-File (10), Testing (6) | Avoid breaking existing code |
| Performance fix | Performance (9), Dependencies (7) | Target the actual bottleneck |
| Typed codebase | Type Safety (5), Cross-File (10) | Type errors cause runtime crashes |

## Review Process

1. **Initial Scan**: Quick overview to understand scope and context
2. **Deep Analysis**: Systematic review of each dimension listed above
3. **Cross-Reference**: Compare implementation against userspec, techspec, and project standards
4. **Issue Categorization**: Classify findings by severity:
   - **critical** → blocking issues that must be fixed
   - **major** → significant concerns that should be addressed
   - **minor** → improvements that are valuable but optional
5. **Recommendation Formulation**: Provide specific, actionable suggestions

## Quality Standards

Be thorough but pragmatic:
- Focus on issues that materially impact code quality, security, or maintainability
- Distinguish between critical problems and stylistic preferences
- Provide constructive feedback with specific examples
- Acknowledge good practices when present
- Consider project context and constraints from project documentation (if available)
- Balance idealism with practical delivery needs

## Communication Style

- Be direct and specific — avoid vague feedback
- Use technical precision appropriate for senior developers
- Provide code examples in recommendations when helpful
- Explain the "why" behind each issue, not just the "what"
- Maintain professional, respectful tone
- Prioritize actionability over completeness

Goal: ensure production-ready code that is secure, maintainable, and aligned with project standards.
