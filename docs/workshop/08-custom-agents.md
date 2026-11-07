# Module 8: Custom Agents

## Prerequisites

- Completed Modules 1-7
- Understanding of AGENTS.md (Module 3)
- A repository to experiment with

## Learning Objectives

- Create custom agents with specialized personas
- Configure agents at repository, organization, and enterprise levels
- Use built-in agents (Explore, Task, General-purpose, Code-review, Security-review, Research, Rubber-duck, REM)
- Invoke agents explicitly in conversations
- Build subagents for complex workflows

## Concepts

### What are Custom Agents?

Custom agents are specialized versions of Copilot with:
- **Defined persona** - Role and expertise
- **Specific tools** - What they can use
- **Clear boundaries** - What they should never do
- **Domain knowledge** - Context about their specialty

Use **`.agent.md`** as the workshop convention; the CLI also derives agent IDs from `.md` files.

### Agent Profile Structure

```yaml
---
name: agent-name
description: What this agent does
model: auto # Optional: override AI model or use automatic selection
tools: # Optional: default is all tools
 - shell
 - write
skills: # Optional: eagerly load named skills
 - api-docs
 - test-writer
---

[Markdown body with detailed instructions]
```

> **Note:** The `model` field accepts model identifiers and display names. Prefer an available model's exact identifier and inspect actual dispatch: a fallback does not mean the requested model was honored.

> **Note:** The `skills` field declares which skills should be eagerly loaded when the agent is invoked. Without this field, skills are loaded on-demand based on prompt matching. Eager loading ensures the agent always has access to specific skill content.

### Creating Agents

You can create agent files manually, or use the **`/agent`** slash command in interactive mode:

1. Enter `/agent` and select **Create new agent**.
2. Choose a location:
 - **Project** (`.github/agents/` or `.claude/agents/`)
 - **User** (`~/.copilot/agents/`)
3. Choose whether to have Copilot generate the agent profile or create it yourself.
4. Configure tool access (default is all tools).
5. Inspect `/agent`; if the file is not visible, restart and check again.

> [!NOTE]
> Restarting is a reliable discovery troubleshooting step, not a universal hot-loading guarantee. Verify manual and plugin agent visibility in `/agent` and `/env`; exact live activation needs a runtime check. See [Module 7](07-plugins.md).

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
User agents (~/.copilot/agents/)
 ↓
Project .github/agents/ (cwd upward to git root)
 ↓
Project .claude/agents/ (cwd upward to git root)
 ↓
Added roots (.github/agents/, trusted by adding the directory)
 ↓
Plugin agents
 ↓
Remote organization/enterprise agents
```

> **Note:** Deduplication uses **file-derived IDs**, not display names. The first same-ID definition wins. `agents/team/reviewer.agent.md` yields `team--reviewer`; same display names with different IDs can both load. `AGENTS.md` is instructions, not an agent tier.

### Instruction Inheritance and Model Policy

Custom subagents need `include-custom-instructions: true` to receive repository instructions. Session agents and general-purpose subagents receive them; built-in Explore/Task/Code-review do not. Parent-only extra instruction directories are not inherited; `--no-custom-instructions` disables repository loading even with opt-in.

Use `model` for the authored model, `model-policy: preferred` to permit overrides, and `model-policy: required` to enforce the authored model in delegated subagents. A conflicting explicit dispatch model is replaced by the required authored model; an unavailable required subagent model fails dispatch. `reasoning-effort` sets authored effort. Do not rely on `models` overriding `model`, or on camelCase `modelPolicy` / `reasoningEffort` frontmatter: these fields can be ignored without a visible warning.

Session selection with `--agent` is distinct from delegated subagent policy: an unavailable authored model can produce a warning and session-model fallback even with `model-policy: required`. Explicit dispatch values, per-subagent settings, account availability, and Auto routing affect resolution; Auto subagents inherit the resolved session model. Inspect dispatch/UI evidence, not an agent's self-reported model.

Agent-scoped `hooks` run alongside session hooks while that local agent is selected, subject to workspace trust and disable/policy controls. Remote agent definitions do not execute scoped hooks (Module 9).

### Built-in Agents

Copilot CLI includes specialized built-in agents:

| Agent | Purpose | How it runs |
|-------|---------|-------------|
| **Explore** | Fast codebase analysis in separate context; inspect its actual tool inventory rather than assuming GitHub access | May be selected by the main agent |
| **Task** | Run development commands (tests, builds, linters, formatters) with smart output handling | Selected automatically |
| **General-purpose** | Same capabilities as the main agent, in a separate context window | Selected automatically |
| **Code-review** | High signal-to-noise review of staged, unstaged, or branch diffs | Selected automatically, or `/review` |
| **Rubber-duck** | Constructive critique of plans, designs, implementations, and tests, on a complementary model | Use `/rubber-duck`; do not assume automatic activation |
| **Security-review** | Security-focused review of staged, unstaged, and branch diffs across 11 vulnerability categories | `/security-review` |
| **Research** | Deep research across code, repositories, and web sources | `/research` |
| **REM** | Background memory consolidation that updates the dynamic context board | Background only |

> **Note:** Built-in agents are not included in the `/agent` list. They are invoked via the main agent's task tool. Research, Security-review, and REM are not selected automatically — Research and Security-review run from their slash commands, and REM runs in the background.

> **Note:** Use built-ins through the main agent or advertised slash commands for these exercises. `--agent NAME -p` runtime support, automatic activation, and actual model reporting require targeted authenticated checks; parser acceptance alone does not prove them.

### Sub-Agent Depth and Concurrency Limits

> Copilot CLI enforces **depth and concurrency limits** on sub-agents:
> - **Depth limit**: Prevents infinite sub-agent recursion (agent spawning agent spawning agent...)
> - **Concurrency limit**: Controls how many sub-agents can run simultaneously
>
> These limits prevent runaway resource consumption and ensure predictable behavior when agents delegate to other agents. Configure them with the `subagents.maxDepth` and `subagents.maxConcurrency` settings, which apply to usage-based billing accounts. Use `subagents.disabledSubagents` to turn individual sub-agents off, and `/subagents` to set per-agent model, effort, and context-tier overrides.

### Managing Configuration from a Session

> Use `/agent`, `/mcp`, `/skills`, and `/plugin` to add, edit, enable, and disable custom agents, MCP servers, skills, and plugins without leaving the session. `/settings` writes user settings, and `/settings --repo` / `/settings --local` target repository settings.

## Hands-On Exercises

### Exercise 1: Create a Repository Agent

**Goal:** Build a specialized agent for your repository.

**Steps:**

1. Create the agents directory:
 ```bash
 mkdir -p .github/agents
 ```

2. Create a test-agent:
 ````bash
 cat > .github/agents/test-agent.agent.md << 'EOF'
 ---
 name: test-agent
 description: Writes comprehensive unit tests following TDD principles. Use for creating tests, improving coverage, and validating code behavior.
 include-custom-instructions: true
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
 describe('ComponentName', () => {
 describe('methodName', () => {
 it('should [expected behavior] when [condition]', () => {
 // Arrange
 const input = setupTestData();

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
         input_data = setup_test_data()

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
 ````

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
 `````bash
 cat > .github/agents/docs-agent.agent.md << 'EOF'
 ---
 name: docs-agent
 description: Creates and maintains technical documentation. Use for README files, API docs, architecture docs, and user guides.
 include-custom-instructions: true
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
 ````markdown
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
 ````

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
 `````

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

 Copilot may delegate to Explore; inspect `/tasks` rather than assuming activation. The Explore agent:
 - Performs fast analysis
 - Reduces parent-context pressure; returned summaries still consume context and usage
 - Great for learning codebases

2. **Use the Task agent** for running commands:
 ```
 Run the test suite and summarize results
 ```

 The Task agent:
 - Runs commands intelligently
 - Brief summary on success
 - Full output on failure

3. **Use plan mode for implementation planning:**
 ```
 /plan Add user profile editing feature
 ```

 Plan mode:
 - Analyzes dependencies
 - Creates step-by-step plans
 - Identifies potential blockers

 > **Note:** Planning is a session **mode**, not a built-in agent. You can also start the CLI in it with `copilot --mode plan`.

4. **Use the Code-review agent** for reviews:
 ```
 Review the changes in the last 3 commits
 ```

 The Code-review agent:
 - High signal-to-noise feedback
 - Focuses on real issues
 - Actionable suggestions

5. **Use the Research agent** for deep investigations:
 ```
 /research Compare the trade-offs of REST and GraphQL for this project
 ```

 The Research agent:
 - Breaks topics into sub-questions
 - Searches available code, repositories, and web sources
 - Produces structured findings

6. **Use fleet mode for parallel subagent work:**
 ```
 /fleet Add tests for each independent service module
 ```

 Fleet mode:
 - Decomposes complex work into parallel subagent tasks
 - Coordinates results through an orchestrator
 - Works best for independent, parallelizable changes

 > **Note:** Fleet is a session **mode**, not a built-in agent. It orchestrates subagents rather than being one.

7. **Use the Security-review agent** for a security pass:
 ```
 /security-review
 ```

 The Security-review agent:
 - Analyzes staged, unstaged, and branch diffs
 - Covers 11 vulnerability categories
 - Minimizes false positives

> **Note:** Use `/tasks` to observe actual delegation. Request Research, Security-review, and Rubber-duck through their slash commands; do not infer universal activation from help listings.

> Fleet can also start at launch: `copilot --fleet -i "Add tests for independent service modules"`. Permissions still apply; parallel work consumes usage and needs bounded scope.

**Expected Outcome:**
Each built-in agent provides specialized assistance.

### Exercise 4: Agent with Tool Restrictions

**Goal:** Create an agent with limited tool access.

**Steps:**

1. Create a read-only analysis agent:
 ````bash
 cat > .github/agents/analyzer.agent.md << 'EOF'
 ---
 name: analyzer
 description: Analyzes code for quality, security, and performance issues without making changes. Use for code audits and reviews.
 include-custom-instructions: true
 strict-tools-list: true
 tools:
 - read
 - search
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

 ## Analysis Tools
 - Search text patterns with search tools
 - Inspect files with read tools
 - Locate JavaScript files with search tools
 - Report suggested linter checks; do not run shell programs

 ## IMPORTANT: READ-ONLY
 I analyze but NEVER modify files. My purpose is to report findings.
 For fixes, hand off to appropriate agents or developers.
 EOF
 ````

2. Notice the `tools` section excludes **both writing and shell execution**. `strict-tools-list: true` limits the delegated analyzer to its authored read/search groups. A selected session agent can still receive `skill` and session `sql` tools: inspect the effective inventory separately for session agents and subagents. Denying `write` alone does not prevent shell-based writes; persona boundaries alone are guidance.

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

4. The delegated analyzer has `view`, `grep`, and `glob`, without file-write, shell, or delegation tools. Selecting it with `--agent` can also expose `skill` and session `sql`; that is not an exclusively read/search inventory.

**Expected Outcome:**
Agent performs read/search analysis. Confirm the effective tool inventory contains no file-modifying, shell, or delegation tools before relying on its restrictions; this is not whole-process OS isolation. Use actual tool events and available-tool telemetry rather than a model's description of its capabilities.

### Exercise 5: User-Level Agents

**Goal:** Understand user-level agent deployment.

**Steps:**

1. User-level agents go in your home directory:
 ```
 ~/.copilot/agents/AGENT-NAME.agent.md
 ```

 User-level agents are available across repositories and take priority over repository agents with the same **file-derived ID**.

2. Create a user-level agent:
 ```bash
 mkdir -p ~/.copilot/agents
 test ! -e "$HOME/.copilot/agents/security-reviewer.agent.md" &&
 cat > ~/.copilot/agents/security-reviewer.agent.md << 'EOF'
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

3. Restart the CLI. The agent is available in all your repositories.

4. Priority order (highest to lowest):
 - **User agents** (`~/.copilot/agents/`) — highest priority
 - Project `.github/agents/` (deepest first)
 - Project `.claude/agents/` (deepest first)
 - Added-root `.github/agents/`
 - Plugin agents
 - Remote organization/enterprise agents

> **Note:** Enterprise and organization-level agents are configured by admins in a `.github-private` repository. See the [GitHub Docs](https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-organization/prepare-for-custom-agents) for details.

> The `customAgents.defaultLocalOnly` setting allows you to default to only local custom agents, skipping remote org/enterprise agents. Set it in `~/.copilot/settings.json`:
> ```json
> { "customAgents": { "defaultLocalOnly": true } }
> ```

> [!WARNING]
> Put user settings in `~/.copilot/settings.json`, or edit them with `/settings`. The `~/.copilot/config.json` file next to it is managed automatically and stores your authentication token — never print, paste, or share it, especially while screen-sharing.

**Expected Outcome:**
You understand how to deploy user-level agents and the priority hierarchy.

### Exercise 6: Subagents and Delegation

**Goal:** Use agents that delegate to other agents.

**Steps:**

1. Create a coordinator agent:
 ````bash
 cat > .github/agents/project-lead.agent.md << 'EOF'
 ---
 name: project-lead
 description: Coordinates development tasks by delegating to specialized agents. Use for complex features requiring multiple types of work.
 include-custom-instructions: true
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
 ````

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
 | Agent not found | Check file location: `.github/agents/name.agent.md`, `.claude/agents/name.agent.md`, or `~/.copilot/agents/name.agent.md` |
 | Wrong behavior | Check YAML frontmatter syntax |
 | Tools not working | Verify tools list in frontmatter |
 | Description missing | Add description field |
 | Agent not loading | Check `/agent` and `/env`, then restart; live activation is not assumed |

4. Preview YAML frontmatter (this is not parser validation):
 ```bash
 # Inspect the opening frontmatter
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
name: lowercase-hyphenated # Optional display name; defaults to file-derived ID
description: What this agent does # Required
---
```

### Optional Fields

```yaml
---
name: agent-name
description: Description
model: auto # Optional: specify AI model or use auto selection
tools: # Optional, defaults to all
 - shell
 - write
 - read
 - web_fetch
 - mcp-server-name
skills: # Optional: eagerly load named skills
 - skill-name
---
```

> **Note:** Unrecognized frontmatter can be ignored without a visible warning and without blocking agent load. Verify effective tool, model-policy, and effort settings rather than treating successful loading as schema validation.
>
> **Note:** Agent self-report is not proof of the actual dispatch model; inspect session/task UI and available diagnostics.

### Agent Locations

| Location | Scope | Example Path |
|----------|-------|--------------|
| User | All repos (highest priority) | `~/.copilot/agents/name.agent.md` |
| Repository | Single repo | `.github/agents/name.agent.md` or `.claude/agents/name.agent.md` |
| Organization | All org repos | `.github-private/agents/name.agent.md` |
| Enterprise | All enterprise repos | Same as org, enterprise level |

> **Note:** User agents override same-ID project agents; display names do not deduplicate profiles.

### Naming Conventions

- Use lowercase with hyphens: `test-agent`, `docs-writer`
- Be descriptive: `security-reviewer` not `sr`
- Keep IDs short and descriptive; do not apply skill-specific name limits to agent fields

## Summary

- ✅ Custom agents defined with `.agent.md` extension
- ✅ Create agents via `/agent` command or manually in `.github/agents/` or `.claude/agents/`
- ✅ Invoke agents via `/agent` slash command, explicit instruction, inference, or `--agent` flag
- ✅ User-level agents (`~/.copilot/agents/`) override repo-level agents
- ✅ Built-in specialists handle common tasks when dispatched; inspect `/tasks` and use advertised slash commands
- ✅ Research and Security-review run from `/research` and `/security-review`; REM consolidates memory in the background
- ✅ Plan and fleet are session modes, not agents
- ✅ Explore uses separate context; actual GitHub tool access requires inventory/runtime checks
- ✅ Agent model preferences interact with Auto routing, account access, model policy, and per-subagent overrides
- ✅ Tool restrictions limit what agents can do
- ✅ Organization agents provide team-wide standards
- ✅ Agents can delegate to other agents for complex workflows
- ✅ Check agent visibility after editing/installing; restart when needed, and validate live loading separately
- ✅ `/agent`, `/mcp`, `/skills`, `/plugin`, and `/settings` manage configuration from inside a session
- ✅ Agent `model` field accepts model identifiers and display names; inspect availability and actual dispatch
- ✅ Agent `skills` field eagerly loads named skills
- ✅ `subagents.maxDepth` and `subagents.maxConcurrency` bound sub-agent recursion and parallelism
- ✅ User settings belong in `~/.copilot/settings.json`; `~/.copilot/config.json` is managed automatically and holds credentials

## Next Steps

→ Continue to [Module 9: Hooks](09-hooks.md)

## References

- [About Custom Agents - GitHub Docs](https://docs.github.com/en/copilot/concepts/customizations/custom-agents)
- [Create Custom Agents for CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [Custom Agents Configuration - GitHub Docs](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Comparing CLI Customization Features - GitHub Docs](https://docs.github.com/en/copilot/concepts/customizations/comparing-customizations)
- [How to Write Great AGENTS.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
