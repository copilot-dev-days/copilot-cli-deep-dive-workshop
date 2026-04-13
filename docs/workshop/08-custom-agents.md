# Module 8: Custom Agents

## Prerequisites

- Completed Modules 1-8
- Understanding of AGENTS.md (Module 3)
- A repository to experiment with

## Learning Objectives

- Create custom agents with specialized personas
- Configure agents at repository, organization, and enterprise levels
- Use built-in agents (Explore, Task, Plan, Code-review)
- Invoke agents explicitly in conversations
- Build subagents for complex workflows

## Concepts

### What are Custom Agents?

Custom agents are specialized versions of Copilot with:
- **Defined persona** - Role and expertise
- **Specific tools** - What they can use
- **Clear boundaries** - What they should never do
- **Domain knowledge** - Context about their specialty

Each custom agent is defined by a Markdown file with an **`.agent.md`** extension.

### Agent Profile Structure

```yaml
---
name: agent-name
description: What this agent does
model: claude-sonnet-4.6 # Optional: override AI model
tools: # Optional: default is all tools
 - shell
 - write
---

[Markdown body with detailed instructions]
```

### Creating Agents

You can create agent files manually, or use the **`/agent`** slash command in interactive mode:

1. Enter `/agent` and select **Create new agent**.
2. Choose a location:
 - **Project** (`.github/agents/`)
 - **User** (`~/.config/copilot/agents/`)
3. Choose whether to have Copilot generate the agent profile or create it yourself.
4. Configure tool access (default is all tools).
5. **Restart the CLI** to load your new custom agent.

> [!NOTE]
> Manually created `.agent.md` files require a CLI restart to take effect. However, agents installed via `/plugin install` are **hot-loaded** and available immediately without restarting. See [Module 7](07-plugins.md).

### Invoking Agents

Custom agents can be invoked in four ways:

| Method | Example |
|--------|---------|
| **Slash command** | `/agent` → select from list → enter prompt |
| **Explicit instruction** | `Use the test-agent agent on all files in /src` |
| **By inference** | A prompt that matches the agent's described expertise |
| **Programmatically** | `copilot --agent test-agent --prompt "Check /src"` |

### Agent Hierarchy

```
User agents (~/.config/copilot/agents/)
 ↓
Enterprise agents (.github-private repo)
 ↓
Organization agents (.github-private repo)
 ↓
Repository agents (.github/agents/)
 ↓
AGENTS.md (root or directory-specific)
```

> **Note:** If you have custom agents with the same name in both user and repository locations, the one in your home directory (`~/.config/copilot/agents/`) will be used.

### Built-in Agents

Copilot CLI includes specialized built-in agents:

| Agent | Purpose |
|-------|---------|
| **Explore** | Fast codebase analysis without context clutter; can use GitHub MCP tools when available |
| **Task** | Run commands with smart output handling |
| **Plan** | Create implementation plans |
| **Code-review** | High signal-to-noise code reviews |

> **Note:** Built-in agents are not included in the `/agent` list. They are invoked via the main agent's task tool.

### Configure-Copilot Sub-Agent

> Since v1.0.4, the built-in `configure-copilot` sub-agent can manage MCP servers, custom agents, and skills via the task tool. Ask Copilot to configure itself:

```
Help me set up an MCP server for my PostgreSQL database
```

Copilot delegates to the configure-copilot agent, which modifies configuration files on your behalf.

## Hands-On Exercises

### Exercise 1: Create a Repository Agent

**Goal:** Build a specialized agent for your repository.

**Steps:**

1. Create the agents directory:
 ```bash
 mkdir -p .github/agents
 ```

2. Create a test-agent:
 ```bash
 cat > .github/agents/test-agent.agent.md << 'EOF'
 ---
 name: test-agent
 description: Writes comprehensive unit tests following TDD principles. Use for creating tests, improving coverage, and validating code behavior.
 tools:
 - shell
 - write
 - read
 ---

 # Test Writing Agent

 You are a senior QA engineer specializing in test-driven development.

 ## Your Expertise
 - Unit testing with Jest, pytest, JUnit
 - Integration testing
 - Mocking and stubbing
 - Test coverage analysis
 - Edge case identification

 ## Testing Philosophy
 1. **Test behavior, not implementation** - Focus on what code does
 2. **One assertion concept per test** - Keep tests focused
 3. **Descriptive names** - Tests are documentation
 4. **AAA pattern** - Arrange, Act, Assert

 ## Test Structure Template

 ### JavaScript/TypeScript (Jest)
 ```typescript
 describe('ComponentName',  => {
 describe('methodName',  => {
 it('should [expected behavior] when [condition]',  => {
 // Arrange
 const input = setupTestData;

 // Act
 const result = component.methodName(input);

 // Assert
 expect(result).toBe(expected);
 });
 });
 });
 ```

 ### Python (pytest)
 ```python
 class TestComponentName:
 def test_method_should_behavior_when_condition(self):
 # Arrange
 input_data = setup_test_data

 # Act
 result = component.method_name(input_data)

 # Assert
 assert result == expected
 ```

 ## Edge Cases to Always Test
 - Null/undefined/None inputs
 - Empty strings and arrays
 - Boundary values (0, -1, MAX_INT)
 - Invalid types
 - Network/IO failures (mocked)

 ## Commands I Use
 - `npm test` - Run JavaScript tests
 - `pytest` - Run Python tests
 - `npm run test:coverage` - Coverage report

 ## Boundaries - DO NOT
 - Never modify source code (only test files)
 - Never skip failing tests
 - Never remove test assertions
 - Never test private methods directly
 - Never create tests that depend on test order
 EOF
 ```

3. Restart the CLI to load the new agent, then test it:
 ```bash
 copilot
 ```
 ```
 Use the test-agent agent to create tests for the user authentication module
 ```
 Or use the `/agent` slash command:
 ```
 /agent
 ```
 Select **test-agent** from the list, then enter your prompt.

**Expected Outcome:**
Agent creates comprehensive tests following your specifications.

### Exercise 2: Create a Documentation Agent

**Goal:** Build an agent specialized in documentation.

**Steps:**

1. Create the agent file:
 ```bash
 cat > .github/agents/docs-agent.agent.md << 'EOF'
 ---
 name: docs-agent
 description: Creates and maintains technical documentation. Use for README files, API docs, architecture docs, and user guides.
 tools:
 - read
 - write
 ---

 # Documentation Specialist

 You are a technical writer who creates clear, comprehensive documentation.

 ## Documentation Types

 ### README.md Structure
 ```markdown
 # Project Name

 Brief description (1-2 sentences)

 ## Features
 - Feature 1
 - Feature 2

 ## Installation
 Step-by-step instructions

 ## Usage
 Code examples

 ## Configuration
 Options and environment variables

 ## Contributing
 How to contribute

 ## License
 License information
 ```

 ### API Documentation Format
 ```markdown
 ## Endpoint Name

 `METHOD /path`

 ### Description
 What this endpoint does.

 ### Authentication
 Required auth method.

 ### Parameters
 | Name | Type | Required | Description |
 |------|------|----------|-------------|

 ### Request Body
 ```json
 { "example": "request" }
 ```

 ### Response
 ```json
 { "example": "response" }
 ```

 ### Errors
 | Code | Description |
 |------|-------------|
 ```

 ## Style Guide
 - Use active voice
 - Keep sentences short (max 25 words)
 - Include code examples for every feature
 - Use consistent terminology
 - Add diagrams for complex concepts

 ## Process
 1. Read the source code thoroughly
 2. Understand the user's perspective
 3. Write clear, actionable documentation
 4. Include working examples
 5. Review for completeness

 ## DO NOT
 - Never use jargon without explanation
 - Never assume prior knowledge
 - Never leave TODOs in final docs
 - Never copy-paste code that hasn't been tested
 EOF
 ```

2. Restart the CLI, then test the agent:
 ```bash
 copilot
 ```
 ```
 Use the docs-agent agent to create a comprehensive README for this project
 ```

**Expected Outcome:**
Agent creates well-structured documentation.

### Exercise 3: Using Built-in Agents

**Goal:** Leverage Copilot's built-in specialized agents.

**Steps:**

1. **Use the Explore agent** for codebase analysis:
 ```bash
 copilot
 ```
 ```
 How is authentication implemented in this codebase?
 ```

 Copilot will automatically delegate to the Explore agent when it determines codebase analysis is needed. The Explore agent:
 - Performs fast analysis
 - Doesn't clutter main context
 - Great for learning codebases

2. **Use the Task agent** for running commands:
 ```
 Run the test suite and summarize results
 ```

 The Task agent:
 - Runs commands intelligently
 - Brief summary on success
 - Full output on failure

3. **Use the Plan agent** for implementation planning:
 ```
 Create a plan to add user profile editing feature
 ```

 The Plan agent:
 - Analyzes dependencies
 - Creates step-by-step plans
 - Identifies potential blockers

4. **Use the Code-review agent** for reviews:
 ```
 Review the changes in the last 3 commits
 ```

 The Code-review agent:
 - High signal-to-noise feedback
 - Focuses on real issues
 - Actionable suggestions

> **Note:** Built-in agents are not listed in the `/agent` menu. They are invoked automatically by the main agent when it determines their expertise is needed.

**Expected Outcome:**
Each built-in agent provides specialized assistance.

### Exercise 4: Agent with Tool Restrictions

**Goal:** Create an agent with limited tool access.

**Steps:**

1. Create a read-only analysis agent:
 ```bash
 cat > .github/agents/analyzer.agent.md << 'EOF'
 ---
 name: analyzer
 description: Analyzes code for quality, security, and performance issues without making changes. Use for code audits and reviews.
 tools:
 - read
 - shell
 ---

 # Code Analyzer

 You are a code analysis expert who reviews but never modifies code.

 ## Analysis Categories

 ### Security Review
 - SQL injection vulnerabilities
 - XSS vulnerabilities
 - Authentication issues
 - Secret exposure
 - Dependency vulnerabilities

 ### Performance Review
 - N+1 queries
 - Memory leaks
 - Inefficient algorithms
 - Unnecessary re-renders (React)
 - Missing indexes (SQL)

 ### Quality Review
 - Code duplication
 - Complex functions (cyclomatic complexity)
 - Missing error handling
 - Inconsistent naming
 - Dead code

 ## Output Format

 ```markdown
 ## Analysis Report

 ### Summary
 - Critical: X
 - Warning: Y
 - Info: Z

 ### Critical Issues
 1. **Issue title** (file:line)
 - Problem: Description
 - Risk: Impact description
 - Recommendation: How to fix

 ### Warnings
 ...

 ### Suggestions
 ...
 ```

 ## Commands I Use
 - `grep -r "pattern" .` - Search for patterns
 - `wc -l` - Count lines
 - `find . -name "*.js"` - Find files
 - Linter commands (read-only)

 ## IMPORTANT: READ-ONLY
 I analyze but NEVER modify files. My purpose is to report findings.
 For fixes, hand off to appropriate agents or developers.
 EOF
 ```

2. Notice the `tools` section excludes `write`.

3. Restart the CLI, then test the agent:
 ```bash
 copilot
 ```
 ```
 Use the analyzer agent to review the authentication module for security issues
 ```

 Or invoke programmatically:
 ```bash
 copilot --agent analyzer --prompt "Review the authentication module for security issues"
 ```

4. The agent can only read and run shell commands, not write.

**Expected Outcome:**
Agent performs analysis without modification capabilities.

### Exercise 5: User-Level Agents

**Goal:** Understand user-level agent deployment.

**Steps:**

1. User-level agents go in your home directory:
 ```
 ~/.config/copilot/agents/AGENT-NAME.agent.md
 ```

 User-level agents are available across all repositories and take priority over repository agents with the same name.

2. Create a user-level agent:
 ```bash
 mkdir -p ~/.config/copilot/agents
 cat > ~/.config/copilot/agents/security-reviewer.agent.md << 'EOF'
 ---
 name: security-reviewer
 description: Reviews code for security compliance with personal standards.
 ---

 # Security Review Agent

 You review code for security best practices.

 ## Required Checks
 - OWASP Top 10 compliance
 - Secrets detection
 - Input validation
 - Authentication and authorization issues
 EOF
 ```

3. Restart the CLI. The agent is now available in all your repositories.

4. Priority order (highest to lowest):
 - **User agents** (`~/.config/copilot/agents/`) — highest priority
 - Enterprise agents (`.github-private` repo, enterprise level)
 - Organization agents (`.github-private` repo, org level)
 - **Repository agents** (`.github/agents/`)

> **Note:** Enterprise and organization-level agents are configured by admins in a `.github-private` repository. See the [GitHub Docs](https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-organization/prepare-for-custom-agents) for details.

> ⚠️ **FEEDBACK**: The `customAgents.defaultLocalOnly` config option allows you to default to only local custom agents, skipping remote org/enterprise agents. Set it in `~/.copilot/config.json`:
> ```json
> { "customAgents": { "defaultLocalOnly": true } }
> ```

**Expected Outcome:**
You understand how to deploy user-level agents and the priority hierarchy.

### Exercise 6: Subagents and Delegation

**Goal:** Use agents that delegate to other agents.

**Steps:**

1. Create a coordinator agent:
 ```bash
 cat > .github/agents/project-lead.agent.md << 'EOF'
 ---
 name: project-lead
 description: Coordinates development tasks by delegating to specialized agents. Use for complex features requiring multiple types of work.
 ---

 # Project Lead Agent

 You are a technical lead who coordinates work across specialized agents.

 ## Your Team
 - `@test-agent` - Writing tests
 - `@docs-agent` - Documentation
 - `@analyzer` - Code review

 ## Workflow for New Features

 1. **Analysis Phase**
 Ask @analyzer to review related code

 2. **Implementation Phase**
 Work directly on code changes

 3. **Testing Phase**
 Ask @test-agent to create tests

 4. **Documentation Phase**
 Ask @docs-agent to update docs

 ## Example Delegation

 When asked to implement a feature:
 ```
 First, let me have @analyzer review the existing code...

 [After implementation]

 Now @test-agent should write tests for this...

 Finally, @docs-agent will update the documentation...
 ```

 ## Communication Style
 - Explain the plan before starting
 - Summarize each phase completion
 - Highlight any blockers or concerns
 - Provide status updates
 EOF
 ```

2. Restart the CLI, then test delegation:
 ```bash
 copilot
 ```
 ```
 Use the project-lead agent to implement a user preferences feature end-to-end
 ```

 Or programmatically:
 ```bash
 copilot --agent project-lead --prompt "Implement a user preferences feature end-to-end"
 ```

3. Observe how the coordinator delegates to specialists.

**Expected Outcome:**
Complex workflows coordinated across multiple agents.

### Exercise 7: Debugging Agent Configuration

**Goal:** Troubleshoot agent issues.

**Steps:**

1. Check if agents are loaded:
 ```bash
 copilot
 ```
 ```
 /agent
 ```

 Your custom agents should appear in the list.

2. Test agent invocation directly:
 ```
 Use the test-agent agent to say hello
 ```

3. Common issues and fixes:

 | Problem | Solution |
 |---------|----------|
 | Agent not found | Check file location: `.github/agents/name.agent.md` |
 | Wrong behavior | Check YAML frontmatter syntax |
 | Tools not working | Verify tools list in frontmatter |
 | Description missing | Add description field |
 | Agent not loading | Restart the CLI after creating/editing `.agent.md` files (plugin-installed agents load immediately) |

4. Validate YAML frontmatter:
 ```bash
 # Check for syntax errors
 cat .github/agents/test-agent.agent.md | head -20
 ```

5. Test in isolation:
 ```bash
 copilot --agent test-agent --prompt "Describe yourself and your capabilities"
 ```

**Expected Outcome:**
You can diagnose and fix agent configuration issues.

## Agent Profile Reference

### Required Fields

```yaml
---
name: lowercase-hyphenated # Required, max 64 chars
description: What this agent does # Required, max 1024 chars
---
```

### Optional Fields

```yaml
---
name: agent-name
description: Description
model: gpt-4.1 # Optional: specify AI model
tools: # Optional, defaults to all
 - shell
 - write
 - read
 - web_fetch
 - mcp-server-name
---
```

> **Note:** Unknown frontmatter fields now produce a warning instead of blocking agent load, making agents more forward-compatible.
>
> **Note:** Agents are model-aware — when asked which model is powering them, they can respond accurately.

### Agent Locations

| Location | Scope | Example Path |
|----------|-------|--------------|
| User | All repos (highest priority) | `~/.config/copilot/agents/name.agent.md` |
| Repository | Single repo | `.github/agents/name.agent.md` |
| Organization | All org repos | `.github-private/agents/name.agent.md` |
| Enterprise | All enterprise repos | Same as org, enterprise level |

> **Note:** User-level agents override repository-level agents with the same name.

### Naming Conventions

- Use lowercase with hyphens: `test-agent`, `docs-writer`
- Be descriptive: `security-reviewer` not `sr`
- Maximum 64 characters

## Summary

- ✅ Custom agents defined with `.agent.md` extension
- ✅ Create agents via `/agent` command or manually in `.github/agents/`
- ✅ Invoke agents via `/agent` slash command, explicit instruction, inference, or `--agent` flag
- ✅ User-level agents (`~/.config/copilot/agents/`) override repo-level agents
- ✅ Built-in agents (Explore, Task, Plan, Code-review) handle common tasks
- ✅ Explore agent can use GitHub MCP tools when available
- ✅ Agent `model` field overrides the default AI model
- ✅ Tool restrictions limit what agents can do
- ✅ Organization agents provide team-wide standards
- ✅ Agents can delegate to other agents for complex workflows
- ✅ Restart the CLI after creating new `.agent.md` files (plugin-installed agents hot-load without restart)
- ✅ `configure-copilot` built-in sub-agent manages MCP, agents, and skills (v1.0.4+)

## Next Steps

→ Continue to [Module 9: Hooks](09-hooks.md)

## References

- [About Custom Agents - GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [Create Custom Agents for CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [Custom Agents Configuration - GitHub Docs](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Comparing CLI Customization Features - GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/comparing-cli-features)
- [How to Write Great AGENTS.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
