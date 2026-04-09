# Module 3: Custom Instructions

## Prerequisites

- Completed Modules 1-3
- Understanding of Markdown format
- A Git repository to experiment with

## Learning Objectives

- Create repository-wide instructions with `copilot-instructions.md`
- Write effective `AGENTS.md` files for agent behavior
- Understand `llm.txt` and its purpose
- Use path-specific instructions for different file types
- Implement commit conventions in agent instructions

## Concepts

### Instruction Hierarchy

Copilot CLI reads instructions from multiple sources with this priority:

```
1. Prompt (highest) - What you type
2. AGENTS.md - Nearest in directory tree
3. .github/copilot-instructions.md - Repository-wide
4. .github/instructions/*.instructions.md - Path-specific
5. Personal instructions - ~/.copilot/instructions.md
6. Default behavior (lowest)
```

*Note: `llm.txt` for copilot instructions is currently listed as an issue to be implemented. This file currently can be located within websites to allow models/LLM's to better consume and navigate the site. See [here](https://llmstxthub.com/) for examples*

### File Purposes

| File | Scope | Purpose |
| --- | --- | --- |
| `AGENTS.md` | Directory tree | Agent persona and behavior |
| `copilot-instructions.md` | Repository | Coding standards and conventions |
| `*.instructions.md` | File patterns | Language/path-specific rules |
| `llm.txt` | Website/project | LLM-optimized information about the site for a model |

### The `/instructions` Command

Use `/instructions` inside an interactive session to view and toggle which custom instruction files are active:

```
/instructions
```

This displays all discovered instruction files (AGENTS.md, copilot-instructions.md, `*.instructions.md`, personal instructions) with their status. You can enable or disable individual files without deleting them — useful for debugging which instructions are affecting behavior.

| Action | Example |
| --- | --- |
| List all instruction files | `/instructions` |
| Toggle a file on/off | Select from the displayed list |

This is especially helpful when multiple instruction files interact and you need to isolate which one is causing unexpected behavior.

### Disabling Custom Instructions

You can completely disable loading of custom instructions from AGENTS.md and related files:

```bash
# Start without any custom instructions
copilot --no-custom-instructions
```

To add extra directories for instruction discovery (beyond the git root and cwd):

```bash
# Search additional directories for instruction files
export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="/path/to/shared-instructions,/path/to/team-standards"
copilot
```

### System Message Customization

> ⚠️ **FEEDBACK**: The "customize" mode for system message configuration is available since **v1.0.7**.

You can override specific sections of the system prompt using the "customize" mode in configuration. This allows section-level control over the system message without replacing it entirely.

## Hands-On Exercises

### Exercise 1: Create Repository Instructions

**Goal:** Set up repository-wide coding standards.

**Steps:**

1. Create the `.github` directory:
   ```bash
   mkdir -p .github
   ```

2. Create `copilot-instructions.md`:
   ```bash
   cat > .github/copilot-instructions.md << 'EOF'
   # Copilot Instructions for This Project

   ## Code Style
   - Use 2 spaces for indentation
   - Prefer `const` over `let` in JavaScript/TypeScript
   - Use descriptive variable names (no single letters except loop indices)
   - Add JSDoc comments for all public functions

   ## Architecture
   - Follow MVC pattern for backend code
   - Use React functional components with hooks
   - Keep components under 200 lines

   ## Testing
   - Write unit tests for all utility functions
   - Use Jest for JavaScript testing
   - Aim for 80% code coverage

   ## Dependencies
   - Prefer native Node.js APIs over npm packages when possible
   - Document any new dependencies in PR descriptions

   ## Security
   - Never hardcode secrets or API keys
   - Validate all user input
   - Use parameterized queries for database operations
   EOF
   ```

3. Start Copilot and test:
   ```bash
   copilot
   ```
   ```
   Create a JavaScript function that fetches user data from an API
   ```

4. Observe how Copilot follows your coding standards.

**Expected Outcome:**
Generated code follows your specified style (2-space indent, const usage, JSDoc comments).

### Exercise 2: Create an AGENTS.md File

**Goal:** Define agent behavior with a persona and clear boundaries.

**Steps:**

1. Create `AGENTS.md` in your project root:
   ````bash
   cat > AGENTS.md << 'EOF'
   # Agent Instructions

   You are a senior software engineer specializing in full-stack TypeScript development.

   ## Your Role
   - Write clean, maintainable, well-documented code
   - Follow SOLID principles
   - Prioritize readability over cleverness
   - Consider edge cases and error handling

   ## Project Context
   - This is a Node.js/Express backend with React frontend
   - Database: PostgreSQL with Prisma ORM
   - Authentication: JWT tokens
   - API style: RESTful with OpenAPI documentation

   ## Commit Conventions
   All commits must follow Conventional Commits v1.0.0:

   Format: `<type>(<scope>): <description>`

   Types:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation only
   - `style`: Formatting, no code change
   - `refactor`: Code change that neither fixes nor adds
   - `test`: Adding or updating tests
   - `chore`: Maintenance tasks

   Examples:
   - `feat(auth): add password reset endpoint`
   - `fix(api): handle null user in profile route`
   - `docs(readme): update installation steps`

   ## Boundaries - DO NOT
   - Never modify database migration files without explicit permission
   - Never commit directly to main branch
   - Never remove tests, even if they're failing
   - Never hardcode environment-specific values
   - Never expose internal errors to API responses

   ## File Structure
   ```
   src/
   ├── controllers/  # Request handlers
   ├── services/     # Business logic
   ├── models/       # Database models
   ├── middleware/   # Express middleware
   ├── utils/        # Helper functions
   └── routes/       # Route definitions
   ```

   ## Preferred Patterns

   ### Error Handling
   ```typescript
   try {
     const result = await service.doSomething();
     return res.json(result);
   } catch (error) {
     logger.error('Operation failed', { error });
     return res.status(500).json({ error: 'Internal server error' });
   }
   ```

   ### Service Pattern
   ```typescript
   export class UserService {
     constructor(private readonly db: Database) {}

     async findById(id: string): Promise<User | null> {
       return this.db.user.findUnique({ where: { id } });
     }
   }
   ```
   EOF
   ````

2. Test the agent behavior:
   ```bash
   copilot
   ```
   ```
   Create a new endpoint for updating user preferences
   ```

3. Verify it follows your patterns and conventions.

4. Test commit message generation:
   ```
   I added a new login feature. What commit message should I use?
   ```

**Expected Outcome:**
Copilot acts as a senior TypeScript engineer and suggests conventional commits.

### Exercise 3: Path-Specific Instructions

**Goal:** Apply different rules to different file types.

**Steps:**

1. Create instructions directory:
   ```bash
   mkdir -p .github/instructions
   ```

2. Create TypeScript-specific instructions:
   ```bash
   cat > .github/instructions/typescript.instructions.md << 'EOF'
   ---
   applyTo: "**/*.ts,**/*.tsx"
   ---

   > [!TIP]
   > Since v1.0.6, `applyTo` accepts both a comma-separated string and a YAML array:
   > ```yaml
   > # String (original format)
   > applyTo: "**/*.ts,**/*.tsx"
   > # Array (v1.0.6+)
   > applyTo:
   >   - "**/*.ts"
   >   - "**/*.tsx"
   > ```

   # TypeScript Instructions

   - Use strict TypeScript (`"strict": true` in tsconfig)
   - Prefer interfaces over types for object shapes
   - Use enums for fixed sets of values
   - Avoid `any` type - use `unknown` if type is truly unknown
   - Export types from dedicated `.types.ts` files
   - Use barrel exports (index.ts) for public APIs
   EOF
   ```

3. Create test-specific instructions:
   ```bash
   cat > .github/instructions/tests.instructions.md << 'EOF'
   ---
   applyTo: "**/*.test.ts,**/*.spec.ts,**/tests/**"
   ---

   # Test File Instructions

   - Use descriptive test names: `it('should return 404 when user not found')`
   - Follow AAA pattern: Arrange, Act, Assert
   - One assertion concept per test
   - Use factories for test data, not fixtures
   - Mock external dependencies, not internal modules
   - Test edge cases: null, undefined, empty arrays, boundary values
   EOF
   ```

4. Create documentation instructions:
   ```bash
   cat > .github/instructions/docs.instructions.md << 'EOF'
   ---
   applyTo: "**/*.md,**/docs/**"
   ---

   # Documentation Instructions

   - Use ATX-style headers (# not underlines)
   - Include code examples for all features
   - Keep line length under 100 characters
   - Use reference-style links for repeated URLs
   - Include a table of contents for files > 200 lines
   EOF
   ```

5. Test with different file types:
   ```bash
   copilot
   ```
   ```
   Create a test file for a UserService class
   ```

   Then:
   ```
   Create documentation for the API endpoints
   ```

**Expected Outcome:**
Different instructions apply based on file type.


### Exercise 4: Nested AGENTS.md for Subdirectories

**Goal:** Use different agent behaviors in different parts of the codebase.

**Steps:**

1. Create a subdirectory with its own instructions:
   ```bash
   mkdir -p src/database
   ```

2. Create a specialized AGENTS.md:
   ```bash
   cat > src/database/AGENTS.md << 'EOF'
   # Database Agent Instructions

   You are a database specialist focusing on PostgreSQL and Prisma.

   ## Your Expertise
   - Database schema design
   - Query optimization
   - Migration safety
   - Data integrity

   ## Rules
   - Always include indexes for foreign keys
   - Use transactions for multi-table operations
   - Add `createdAt` and `updatedAt` to all tables
   - Use soft deletes (`deletedAt`) for user data

   ## Migration Safety
   Before creating migrations:
   1. Check for data that would be affected
   2. Consider backward compatibility
   3. Plan rollback strategy

   ## DO NOT
   - Drop columns in production without data backup
   - Use `CASCADE` deletes without explicit approval
   - Create migrations that lock tables for extended periods
   EOF
   ```

3. Test from different directories:
   ```bash
   cd src/database
   copilot
   ```
   ```
   Create a migration to add a comments table
   ```

4. Compare with root directory behavior:
   ```bash
   cd ../..
   copilot
   ```
   ```
   Create a migration to add a comments table
   ```

**Expected Outcome:**
The database directory uses specialized database agent behavior.

### Exercise 5: Commit Convention Enforcement

**Goal:** Ensure Copilot suggests proper commit messages.

**Steps:**

1. Ensure AGENTS.md has commit conventions (from Exercise 2).

2. Make some changes:
   ```bash
   echo "console.log('hello');" > feature.js
   git add feature.js
   ```

3. Ask Copilot for commit message:
   ```bash
   copilot
   ```
   ```
   I've added a new JavaScript file. Suggest a commit message.
   ```

4. Copilot should suggest conventional format:
   ```
   feat: add feature.js with hello world logging
   ```

5. Test with a bug fix scenario:
   ```
   I fixed a null pointer exception in the user service. Commit message?
   ```

   Expected:
   ```
   fix(user): handle null pointer in user service
   ```

**Expected Outcome:**
Commit messages follow Conventional Commits format.

## Best Practices

### AGENTS.md Writing Tips

1. **Be specific about persona:**
   ```markdown
   ❌ "You are a helpful assistant"
   ✅ "You are a senior React developer with 10 years of experience"
   ```

2. **Include explicit boundaries:**
   ```markdown
   ## DO NOT
   - Never modify package-lock.json directly
   - Never remove error handling
   ```

3. **Provide code examples:**
   ````markdown
   ## Preferred Error Pattern
   ```typescript
   throw new AppError('User not found', 404);
   ```
   ````

4. **Document file structure:**
   ```markdown
   ## Project Structure
   - `/src` - Source code
   - `/tests` - Test files
   ```

## Summary

- ✅ `copilot-instructions.md` sets repository-wide standards
- ✅ `AGENTS.md` defines agent persona and boundaries
- ✅ Path-specific instructions target file types with `applyTo`
- ✅ `llm.txt` provides LLM-optimized project context
- ✅ Nested AGENTS.md files enable directory-specific behavior
- ✅ Commit conventions should be explicitly documented
- ✅ `--no-custom-instructions` disables all instruction file loading
- ✅ `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` adds extra instruction search paths
- ✅ `applyTo` accepts both string and array formats (v1.0.6+)

## Next Steps

→ Continue to [Module 4: Tools & Permissions](04-tools.md)

## References

- [Custom Instructions - GitHub Docs](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [How to Write Great AGENTS.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [llms.txt Specification](https://github.com/AnswerDotAI/llms-txt)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
