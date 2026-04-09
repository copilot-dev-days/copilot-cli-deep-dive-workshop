# Module 6: Agent Skills

## Prerequisites

- Completed Modules 1-6
- Understanding of Markdown and YAML frontmatter
- A project to practice with

## Learning Objectives

- Understand the Agent Skills framework
- Create project-specific skills
- Create personal skills for cross-project use
- Discover and install community skills
- Use progressive disclosure for efficient context

## Concepts

### What are Agent Skills?

Skills are specialized capabilities that:
- Work across multiple AI agents (Copilot CLI, VS Code, coding agent)
- Reduce repetition - create once, use everywhere
- Load progressively - only relevant content enters context
- Can be shared publicly via agentskills.io

### Skills vs Instructions vs Agents

| Feature | Instructions | Skills | Agents |
|---------|--------------|--------|--------|
| Scope | Coding standards | Capabilities | Personas |
| Trigger | Always applied | On-demand | Explicitly invoked |
| Location | `.github/` | `.github/skills/` | `.github/agents/` |
| Context | Full file loaded | Progressive loading | Full profile loaded |

### Skill Discovery Levels

```
Level 1: Discovery → Copilot reads name/description (always)
Level 2: Instructions → Copilot loads SKILL.md body (when relevant)
Level 3: Resources → Copilot accesses supporting files (as needed)
```

## Hands-On Exercises

### Exercise 1: Create a Project Skill

**Goal:** Build a skill for generating API documentation.

**Steps:**

1. Create the skills directory:
 ```bash
 mkdir -p .github/skills/api-docs
 ```

2. Create the skill definition file at `.github/skills/api-docs/SKILL.md` with the following contents:
 ~~~markdown
 ---
 name: api-docs
 description: Generates comprehensive API documentation from source code. Use when asked to document APIs, create OpenAPI specs, or write endpoint documentation.
 ---

 # API Documentation Generator

 You are an expert technical writer specializing in API documentation.

 ## Capabilities
 - Generate OpenAPI/Swagger specifications
 - Write human-readable API guides
 - Create request/response examples
 - Document authentication flows

 ## Documentation Style
 - Use clear, concise language
 - Include code examples in multiple languages
 - Document all parameters with types and descriptions
 - Include error responses and status codes

 ## Output Format

 ### For OpenAPI specs:
 ```yaml
 openapi: 3.0.0
 info:
 title: API Name
 version: 1.0.0
 paths:
 /resource:
 get:
 summary: Short description
 parameters: []
 responses:
 '200':
 description: Success
 ```

 ### For Markdown documentation:
 ````markdown
 ## Endpoint Name

 `METHOD /path`

 ### Description
 Brief description of what this endpoint does.

 ### Parameters
 | Name | Type | Required | Description |
 |------|------|----------|-------------|

 ### Response
 ```json
 { "example": "response" }
 ```
 ````

 ## Instructions
 1. First, examine the source code to understand the API structure
 2. Identify all endpoints, parameters, and response types
 3. Generate documentation following the style guide above
 4. Include practical examples that users can copy-paste
 ~~~

3. Test the skill:
 ```bash
 copilot
 ```
 ```
 Document the API endpoints in this project
 ```

4. Copilot should use the api-docs skill automatically.

**Expected Outcome:**
API documentation generated following your skill's style guide.

### Exercise 2: Create a Testing Skill with Resources

**Goal:** Build a skill with supporting example files.

**Steps:**

1. Create the skill directory:
 ```bash
 mkdir -p .github/skills/test-writer
 ```

2. Create the skill file at `.github/skills/test-writer/SKILL.md` with the following contents:

 ~~~markdown
 ---
 name: test-writer
 description: Writes comprehensive unit and integration tests. Use when asked to create tests, improve test coverage, or write test cases.
 ---

 # Test Writing Specialist

 You are a QA engineer who writes thorough, maintainable tests.

 ## Testing Philosophy
 - Test behavior, not implementation
 - One assertion concept per test
 - Use descriptive test names
 - Follow the AAA pattern (Arrange, Act, Assert)

 ## Framework Detection
 Detect the testing framework from:
 - `package.json` dependencies (Jest, Mocha, Vitest)
 - `pytest.ini` or `pyproject.toml` (pytest)
 - `Cargo.toml` (Rust tests)
 - Existing test files

 ## Test Categories
 1. **Unit tests** - Test individual functions in isolation
 2. **Integration tests** - Test component interactions
 3. **Edge cases** - Test boundaries and error conditions

 ## Examples
 See `examples/` directory for framework-specific templates.

 ## Commands
 - Run tests: Check `package.json` scripts or use framework defaults
 - Coverage: Look for coverage configuration

 ## DO NOT
 - Remove failing tests without understanding why
 - Skip edge cases
 - Create tests that depend on external services without mocking
 ~~~

3. Add example templates:
 ```bash
 mkdir -p .github/skills/test-writer/examples

 cat > .github/skills/test-writer/examples/jest.ts << 'EOF'
 import { describe, it, expect, beforeEach } from 'jest';
 import { MyService } from '../src/my-service';

 describe('MyService',  => {
 let service: MyService;

 beforeEach( => {
 service = new MyService;
 });

 describe('methodName',  => {
 it('should return expected value for valid input',  => {
 // Arrange
 const input = 'valid';

 // Act
 const result = service.methodName(input);

 // Assert
 expect(result).toBe('expected');
 });

 it('should throw error for invalid input',  => {
 // Arrange
 const input = null;

 // Act & Assert
 expect( => service.methodName(input)).toThrow('Invalid input');
 });
 });
 });
 EOF

 cat > .github/skills/test-writer/examples/pytest.py << 'EOF'
 import pytest
 from src.my_service import MyService


 class TestMyService:
 @pytest.fixture
 def service(self):
 return MyService

 def test_method_returns_expected_for_valid_input(self, service):
 # Arrange
 input_value = "valid"

 # Act
 result = service.method_name(input_value)

 # Assert
 assert result == "expected"

 def test_method_raises_for_invalid_input(self, service):
 # Arrange
 input_value = None

 # Act & Assert
 with pytest.raises(ValueError, match="Invalid input"):
 service.method_name(input_value)
 EOF
 ```

4. Test the skill with examples:
 ```bash
 copilot
 ```
 ```
 Write tests for the user authentication module
 ```

5. Ask specifically about examples:
 ```
 Show me a pytest example for testing the API client
 ```

**Expected Outcome:**
Skill uses example files to generate framework-appropriate tests.

### Exercise 3: Create Personal Skills

**Goal:** Create skills that work across all your projects.

> [!NOTE]
> In Exercises 1-2 we created skills under `.github/skills/` — those are **project skills**, scoped to a single repository and shared with your team via Git. In this exercise we use `~/.copilot/skills/` — these are **personal skills**, stored in your home directory and available in every project you open with Copilot CLI. You can also use `~/.agents/skills/` as a personal skill discovery directory (shared with the VS Code extension). Use project skills for repo-specific tasks; use personal skills for workflows you want everywhere.

**Steps:**

1. Create personal skills directory:
 ```bash
 mkdir -p ~/.copilot/skills/git-workflow
 ```

2. Create a Git workflow skill at `~/.copilot/skills/git-workflow/SKILL.md`:

 ~~~markdown
 ---
 name: git-workflow
 description: Manages Git operations following best practices. Use for commits, branches, PRs, and Git troubleshooting.
 ---

 # Git Workflow Assistant

 You help with Git operations following established conventions.

 ## Commit Messages
 Follow Conventional Commits:
 ```
 <type>(<scope>): <description>

 [optional body]

 [optional footer(s)]
 ```

 Types: feat, fix, docs, style, refactor, test, chore

 ## Branching Strategy
 - `main` - Production-ready code
 - `develop` - Integration branch
 - `feature/xxx` - New features
 - `fix/xxx` - Bug fixes
 - `hotfix/xxx` - Urgent production fixes

 ## PR Workflow
 1. Create feature branch from develop
 2. Make atomic commits with clear messages
 3. Push and create PR
 4. Address review feedback
 5. Squash and merge when approved

 ## Common Tasks

 ### Undo last commit (keep changes)
 ```bash
 git reset --soft HEAD~1
 ```

 ### Interactive rebase last N commits
 ```bash
 git rebase -i HEAD~N
 ```

 ### Clean up merged branches
 ```bash
 git branch --merged | grep -v "main\|develop" | xargs git branch -d
 ```
 ~~~

3. Create a code review skill at `~/.copilot/skills/code-review/SKILL.md`:

 ```bash
 mkdir -p ~/.copilot/skills/code-review
 ```

 ~~~markdown
 ---
 name: code-review
 description: Performs thorough code reviews focusing on quality, security, and maintainability. Use when reviewing PRs or code changes.
 ---

 # Code Review Expert

 You provide constructive, actionable code review feedback.

 ## Review Checklist
 1. **Correctness** - Does it work as intended?
 2. **Security** - Any vulnerabilities?
 3. **Performance** - Efficient algorithms and queries?
 4. **Maintainability** - Clear and well-structured?
 5. **Testing** - Adequate test coverage?

 ## Feedback Style
 - Be specific and actionable
 - Explain the "why" behind suggestions
 - Distinguish between blocking issues and suggestions
 - Acknowledge good patterns

 ## Categories
 - 🔴 **Blocking** - Must fix before merge
 - 🟡 **Suggestion** - Recommended improvement
 - 🟢 **Nitpick** - Optional style preference
 - 💡 **Question** - Needs clarification

 ## Example Feedback

 🔴 **Blocking**: SQL injection vulnerability
 ```javascript
 // Current (vulnerable)
 db.query(`SELECT * FROM users WHERE id = ${userId}`);

 // Suggested (safe)
 db.query('SELECT * FROM users WHERE id = ?', [userId]);
 ```

 🟡 **Suggestion**: Consider extracting to a helper function for reuse.
 ~~~

4. Test personal skills in any project:
 ```bash
 cd ~/any-project
 copilot
 ```
 ```
 Review the changes in my last commit
 ```

**Expected Outcome:**
Personal skills are available in all projects.

### Exercise 4: Discover and Install Community Skills

**Goal:** Find and use community-created skills.

**Steps:**

1. The [Agent Skills specification](https://agentskills.io/) defines the open standard for skills. Example skills are hosted at [github.com/anthropics/skills](https://github.com/anthropics/skills).

2. Browse the example skills repository:
 ```bash
 # View available skills
 curl -s https://api.github.com/repos/anthropics/skills/contents/skills | jq '.[].name'
 ```

3. Install a skill from the repository (example: `mcp-builder`):
 ```bash
 # Download skill to project
 mkdir -p .github/skills/mcp-builder
 curl -o .github/skills/mcp-builder/SKILL.md \
 https://raw.githubusercontent.com/anthropics/skills/main/skills/mcp-builder/SKILL.md
 ```

4. Or install to personal skills so it works across all projects:
 ```bash
 mkdir -p ~/.copilot/skills/mcp-builder
 curl -o ~/.copilot/skills/mcp-builder/SKILL.md \
 https://raw.githubusercontent.com/anthropics/skills/main/skills/mcp-builder/SKILL.md
 ```

5. Verify the skill was downloaded:
 ```bash
 cat .github/skills/mcp-builder/SKILL.md | head -10
 ```

6. Test the installed skill:
 ```bash
 copilot
 ```
 ```
 Build a simple MCP server in TypeScript that provides a calculator tool with add, subtract, multiply, and divide operations
 ```

> [!TIP]
> Skills follow the open [Agent Skills](https://agentskills.io/) format and work across multiple AI agents — not just Copilot CLI. Any SKILL.md file from the community can be dropped into `.github/skills/` or `~/.copilot/skills/`.

**Expected Outcome:**
Community skills enhance your Copilot capabilities.

### Exercise 5: Skill with Scripts

**Goal:** Create a skill that includes executable scripts.

**Steps:**

1. Create a deployment skill:
 ```bash
 mkdir -p .github/skills/deploy
 ```

2. Create the skill file at `.github/skills/deploy/SKILL.md` with the following contents:

 ~~~markdown
 ---
 name: deploy
 description: Handles deployment tasks including build, test, and deploy to various environments. Use for deployment operations.
 ---

 # Deployment Assistant

 You manage deployments following this project's CI/CD pipeline.

 ## Environments
 - `development` - Auto-deploy on merge to develop
 - `staging` - Manual trigger, production-like
 - `production` - Manual trigger with approval

 ## Deployment Steps
 1. Run tests: `./scripts/test.sh`
 2. Build: `./scripts/build.sh`
 3. Deploy: `./scripts/deploy.sh <environment>`

 ## Scripts
 See `scripts/` directory for deployment scripts.

 ## Pre-deployment Checklist
 - [ ] All tests passing
 - [ ] No security vulnerabilities
 - [ ] Database migrations reviewed
 - [ ] Feature flags configured
 - [ ] Rollback plan documented

 ## Common Commands

 ### Deploy to staging
 ```bash
 ./scripts/deploy.sh staging
 ```

 ### Check deployment status
 ```bash
 ./scripts/status.sh <environment>
 ```
 ~~~

3. Add helper scripts:
 ```bash
 mkdir -p .github/skills/deploy/scripts

 cat > .github/skills/deploy/scripts/deploy.sh << 'EOF'
 #!/bin/bash
 ENV=${1:-staging}
 echo "Deploying to $ENV..."
 # Add actual deployment logic
 EOF

 chmod +x .github/skills/deploy/scripts/deploy.sh
 ```

4. Test:
 ```bash
 copilot
 ```
 ```
 Deploy the current build to staging
 ```

**Expected Outcome:**
Skill provides deployment guidance and can reference scripts.

### Exercise 6: Understanding Skill Auto-Selection

**Goal:** Observe how Copilot automatically selects skills based on your prompt.

**Steps:**

1. Ensure you have multiple skills from earlier exercises (api-docs, test-writer, deploy).

2. Start Copilot:
 ```bash
 copilot
 ```

3. Ask a question that matches the **test-writer** skill:
 ```
 Write unit tests for a function that validates email addresses
 ```
 Observe: the output should follow AAA pattern (Arrange, Act, Assert) as defined in the test-writer skill.

4. Ask a question that matches the **api-docs** skill:
 ```
 Document a REST endpoint POST /users that creates a new user
 ```
 Observe: the output should follow the OpenAPI/Markdown format from the api-docs skill.

5. Ask a question that matches the **deploy** skill:
 ```
 What are the steps to deploy to staging?
 ```
 Observe: the output should reference the deployment checklist and scripts from the deploy skill.

6. Explicitly reference a skill by name to ensure it's used:
 ```
 Using the api-docs skill, generate OpenAPI specs for a todo list API
 ```

> [!TIP]
> Copilot selects skills by matching your prompt against the `name` and `description` in each SKILL.md frontmatter. Write clear, specific descriptions to improve auto-selection accuracy.

**Expected Outcome:**
Different prompts trigger different skills, producing output that follows each skill's specific guidelines and format.

## Skill Structure Reference

### Required Files

```
.github/skills/
└── skill-name/
 └── SKILL.md # Required: Skill definition
```

### Optional Files

```
.github/skills/
└── skill-name/
 ├── SKILL.md # Required
 ├── examples/ # Example code
 │ ├── example1.ts
 │ └── example2.py
 ├── templates/ # Code templates
 │ └── template.ts
 └── scripts/ # Helper scripts
 └── helper.sh
```

### SKILL.md Frontmatter

```yaml
---
name: skill-name # Required: lowercase, hyphens, max 64 chars
description: What this skill does and when to use it # Required: max 1024 chars
license: MIT # Optional: License identifier
---
```

### Skill Locations

| Location | Scope | Priority |
|----------|-------|----------|
| `.github/skills/` | Project | Higher |
| `~/.copilot/skills/` | Personal | Lower |
| `~/.agents/skills/` | Personal (shared with VS Code) | Lower |
| `~/.claude/skills/` | Personal (legacy) | Lower |

## Summary

- ✅ Skills are specialized capabilities that work across AI agents
- ✅ Progressive disclosure loads only relevant content
- ✅ Project skills in `.github/skills/`, personal in `~/.copilot/skills/`
- ✅ Include examples and templates for better output quality
- ✅ Community skills available at [github.com/anthropics/skills](https://github.com/anthropics/skills)
- ✅ Copilot auto-selects skills based on your request
- ✅ YAML array syntax for `allowed-tools` in skill files now loads correctly
- ✅ Skill files saved with UTF-8 BOM (common on Windows) now load correctly

## Next Steps

→ Continue to [Module 7: Plugins](07-plugins.md)

## References

- [Agent Skills - VS Code Docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [About Agent Skills - GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [Agent Skills Specification](https://agentskills.io/)
- [Example Skills Repository](https://github.com/anthropics/skills)
