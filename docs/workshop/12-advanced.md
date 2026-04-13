# Module 12: Advanced Topics

## Prerequisites

- Completed Modules 1-11
- Comfortable with Copilot CLI basics
- Understanding of CI/CD concepts

## Learning Objectives

- Configure environment variables and paths
- Set up Copilot CLI for CI/CD pipelines
- Use advanced command-line flags
- Troubleshoot common issues
- Apply best practices for team workflows

## Concepts

### Configuration Hierarchy

```
Environment Variables
 ↓
XDG_CONFIG_HOME (~/.copilot)
 ↓
Repository Configuration
 ↓
Session Overrides (flags)
```

### Key Directories

| Directory | Purpose |
| --------- | --------- |
| `~/.copilot/` | Default config location |
| `~/.copilot/config.json` | User settings |
| `~/.copilot/mcp-config.json` | MCP servers |
| `~/.copilot/skills/` | Personal skills |
| `~/.agents/skills/` | Personal skill discovery directory (shared with VS Code extension) |
| `.github/` | Repository config |

### New Commands & Features (v1.0.3–v1.0.16)

Several commands and features have been added since v1.0.2:

#### `/pr` — Pull Request Management

> Since v1.0.4, `/pr open` has been replaced by `/pr view [local|web]`. In v1.0.5, the `/pr` command was expanded into a full PR management suite.

| Subcommand | Description |
| --- | --- |
| `/pr` | Create and view PRs |
| `/pr view local` | View PR status locally |
| `/pr view web` | Open PR in browser |

The `/pr` command can also automatically fix CI failures, address review feedback, and resolve merge conflicts.

#### Background Agents & Multi-Turn Conversations

> Since v1.0.3, background task notifications display in the timeline with expandable detail.

Starting in v1.0.5, the `write_agent` tool enables multi-turn conversations with background agents — send follow-up messages to agents spawned via the task tool.

Sub-agents launched by the task tool are assigned **human-readable IDs** based on their name (e.g., `math-helper-0`) instead of generic `agent-0` identifiers (v1.0.6).

The `read_agent` output now includes inbound messages that triggered each turn in multi-turn agents (v1.0.6).

#### `/experimental` Toggle

> Since v1.0.5, toggling experimental mode with `/experimental on|off` automatically restarts the CLI to apply changes immediately. No manual restart needed.

#### Monorepo Support

Custom instructions, MCP servers, skills, and agents are now discovered at every directory level from the working directory up to the git root, enabling full monorepo support.

#### `--effort` Shorthand

Use `--effort` as a shorthand alias for `--reasoning-effort` to control model reasoning level.

#### `--resume` Enhancements

`--resume` now accepts a task ID in addition to a session ID.

## Hands-On Exercises

### Exercise 1: Environment Variables

> [!IMPORTANT]
> Use `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or `GITHUB_TOKEN` (in order of precedence) as the authentication token. These take precedence over previously stored credentials.

**Goal:** Configure Copilot CLI behavior via environment.

**Steps:**

1. **XDG_CONFIG_HOME** - Change config location:

 ```bash
 # Set custom config directory
 export XDG_CONFIG_HOME=/custom/path

 # Copilot will now use /custom/path/copilot/
 copilot
 ```

2. **GITHUB_TOKEN** - Authentication for CI/CD:

 ```bash
 export GITHUB_TOKEN="ghp_your_personal_access_token"

 # Use in scripts
 copilot -p "Run the test suite" --allow-tool 'shell'
 ```

3. **GITHUB_ASKPASS** - Credential helper:

 ```bash
 # Create a credential helper script
 cat > ~/credential-helper.sh << 'EOF'
 #!/bin/bash
 echo "$COPILOT_TOKEN"
 EOF
 chmod +x ~/credential-helper.sh

 export GITHUB_ASKPASS=~/credential-helper.sh
 export COPILOT_TOKEN="your-token"

 copilot
 ```

4. **NO_COLOR** - Disable colored output:

 ```bash
 export NO_COLOR=1
 copilot -p "List files"
 ```

5. View effective configuration:

 ```bash
 copilot --help | head -50
 ```

 > **Note:** `copilot --help` now shows comprehensive output with descriptions, examples, and sorted flags.

**Expected Outcome:**
Environment variables customize Copilot behavior.

### Exercise 2: CI/CD Integration

**Goal:** Set up Copilot CLI in automated pipelines.

**Steps:**

1. **GitHub Actions workflow:**

 ```yaml
 # .github/workflows/copilot-review.yml
 name: Copilot Code Review

 on:
 pull_request:
 types: [opened, synchronize]

 jobs:
 review:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Setup Node.js
 uses: actions/setup-node@v4
 with:
 node-version: '22'

 - name: Install Copilot CLI
 run: npm install -g @github/copilot

 - name: Run Code Review
 env:
 GITHUB_TOKEN: ${{ secrets.COPILOT_TOKEN }}
 run: |
 copilot -p "Review the changes in this PR and provide feedback" \
 --allow-tool 'shell(git)' \
 --deny-tool 'write' \
 --silent
 ```

2. **Pre-commit hook:**

 ```bash
 # .git/hooks/pre-commit
 #!/bin/bash

 # Run Copilot analysis on staged files
 STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

 if [ -n "$STAGED_FILES" ]; then
 copilot -p "Review these staged files for issues: $STAGED_FILES" \
 --allow-tool 'shell(cat)' \
 --allow-tool 'shell(git diff)' \
 --deny-tool 'write' \
 --silent
 fi
 ```

3. **Docker container usage:**

 ```dockerfile
 FROM node:22-slim

 RUN npm install -g @github/copilot

 # Set up config directory
 ENV XDG_CONFIG_HOME=/app/config

 WORKDIR /workspace

 # Entry point for CI
 ENTRYPOINT ["copilot"]
 ```

4. **Safe CI flags:**

 ```bash
 copilot -p "Your prompt" \
 --allow-tool 'shell(npm test)' \
 --allow-tool 'shell(npm run lint)' \
 --deny-tool 'shell(rm)' \
 --deny-tool 'shell(git push)' \
 --deny-tool 'write' \
 --silent
 ```

**Expected Outcome:**
Copilot CLI integrated into automated workflows.

### Exercise 3: Advanced Command-Line Flags

**Goal:** Master all available flags.

**Steps:**

1. **Output control:**

 ```bash
 # Silent mode - minimal output
 copilot -p "Count lines of code" --silent

 # Export session to markdown
 copilot -p "Analyze project" --share ./analysis.md

 # Export to GitHub Gist
 copilot -p "Generate report" --share-gist
 ```

2. **Tool control:**

 ```bash
 # Allow specific tools only
 copilot --available-tools 'shell,read'

 # Exclude specific tools
 copilot --excluded-tools 'write,web_fetch'
 ```

3. **Model selection:**

 ```bash
 # Use specific model
 copilot --model gpt-4.1

 # Use faster model for simple tasks
 copilot --model gpt-5-mini -p "What time is it?"
 ```

4. **Session control:**

 ```bash
 # Resume last session
 copilot --resume

 # Use additional MCP config temporarily
 copilot --additional-mcp-config ./custom-mcp.json
 ```

5. **Output and streaming control:**

 ```bash
 # JSON output for scripting (one JSON object per line)
 copilot -p "List files" --output-format json

 # Disable streaming for batch processing
 copilot -p "Summarize README" --stream off

 # Disable color output (also respects NO_COLOR env var)
 copilot --no-color

 # Start as Agent Client Protocol (ACP) server
 copilot --acp
 ```

6. **View all flags:**

 ```bash
 copilot --help
 ```

 > **Note:** `copilot --help` now provides comprehensive output with descriptions, usage examples, and sorted flags — much more detailed than earlier versions.

7. **Deprecated flag — `--disable-parallel-tools-execution` (removed):**

 > ⚠️ **FEEDBACK**: The `--disable-parallel-tools-execution` flag and its corresponding config option were **removed**. If you relied on this flag, parallel tool execution is now always enabled. Remove any references from your scripts or config files.

**Expected Outcome:**
Full command-line control over Copilot behavior.

### Exercise 4: Autopilot Mode

**Goal:** Use Autopilot mode for autonomous multi-step tasks.

**Steps:**

1. **What is Autopilot mode?**

 Autopilot mode allows Copilot to work autonomously through complex, multi-step tasks without requiring approval for each step. The agent:
 - Plans the full task execution path
 - Executes multiple steps sequentially
 - Handles errors and retries automatically
 - Reports progress and completion

2. **When to use Autopilot vs Interactive mode:**

 **Use Autopilot for:**
 - Repetitive multi-step tasks (e.g., creating boilerplate code)
 - Well-defined workflows (e.g., setting up test infrastructure)
 - Tasks requiring many sequential operations
 - Automation scenarios where human intervention is unnecessary

 **Use Interactive mode for:**
 - Exploratory work where you need to review each step
 - High-risk operations (database changes, deployment)
 - Learning new codebases or technologies
 - Tasks requiring human judgment at each step

3. **Enable Autopilot mode:**

 ```bash
 # Start Copilot in autopilot mode
 copilot --autopilot

 # Or use /autopilot command in an active session
 copilot
 /autopilot on
 ```

 > **Permission elevation:** When accepting a plan with autopilot, Copilot shows a permission elevation dialog to prevent auto-denied tool errors during autonomous execution.

 > **Plan approval menu:** Plan approval now shows model-curated actions with a recommended option highlighted, including an **autopilot+fleet** option for parallelizable work.

4. **Example: Set up a new Express.js API:**

 ```bash
 copilot --autopilot -p "Create a new Express.js API with:
 - User authentication endpoints
 - PostgreSQL database connection
 - Jest test setup
 - Proper error handling middleware
 - Environment variable configuration"
 ```

5. **Monitor Autopilot execution:**

 ```bash
 # Autopilot will show progress:
 # ✓ Created package.json with dependencies
 # ✓ Created src/server.js with Express setup
 # ✓ Created src/auth/routes.js with auth endpoints
 # ✓ Created src/db/connection.js with PostgreSQL config
 # ✓ Created tests/auth.test.js with Jest tests
 # ✓ Created .env.example with required variables
 # ✓ Created src/middleware/errorHandler.js
 ```

6. **Disable Autopilot mid-session:**

 ```bash
 # In an active session
 /autopilot off

 # Now you'll be prompted for approval on each action
 ```

7. **Limit autopilot continuation rounds:**

 ```bash
 # Limit to 10 continuation rounds (default: unlimited)
 copilot --autopilot --max-autopilot-continues 10 -p "Refactor all API endpoints"
 ```

8. **Safety tips:**

 ```bash
 # Still use tool restrictions with autopilot
 copilot --autopilot --deny-tool 'shell(rm)' --deny-tool 'shell(git push)'

 # Disable agent questions for fully autonomous operation
 copilot --autopilot --no-ask-user --allow-all-tools -p "Fix linting errors"

 # Review changes after autopilot completes
 git diff

 # Use in trusted directories only
 ```

**Expected Outcome:**
Copilot autonomously completes multi-step tasks with minimal human intervention.

### Exercise 5: Fleet Command for Parallel Execution

**Goal:** Use the fleet command to launch multiple sub-agents in parallel for complex tasks.

**Steps:**

1. **What is the fleet command?**

 The `/fleet` command enables:
 - **Parallel sub-agents**: Multiple AI agents working simultaneously on different parts of a task
 - **Orchestrator validation**: A supervisor agent that validates work from sub-agents
 - **Parallel dispatch**: Intelligent scheduling to maximize parallelism and speed
 - **Complex task decomposition**: Automatic breaking down of large tasks

2. **When to use /fleet:**

 **Ideal for:**
 - Large refactoring across multiple files
 - Generating test suites for multiple modules
 - Setting up multi-service architectures (frontend + backend + database)
 - Batch operations on independent components

 **Not ideal for:**
 - Small single-file tasks
 - Tasks with tight sequential dependencies
 - Simple prompts that don't benefit from parallelization

3. **Basic fleet usage:**

 ```bash
 copilot
 /fleet "Refactor all components in src/components/ to use TypeScript and add unit tests"
 ```

4. **How fleet works:**

 ```
 Your Prompt
 ↓
 Orchestrator Agent (Plans & Validates)
 ↓
 ┌─────────┬─────────┬─────────┬─────────┐
 │ Agent 1 │ Agent 2 │ Agent 3 │ Agent 4 │ (Parallel Dispatch)
 │ UserCard│ NavBar │ Footer │ Button │
 └─────────┴─────────┴─────────┴─────────┘
 ↓ ↓ ↓ ↓
 Orchestrator Validates Each Result
 ↓
 Final Consolidated Output
 ```

5. **Orchestrator validation:**

 The orchestrator agent:
 - Reviews each sub-agent's work for quality
 - Ensures consistency across parallel work
 - Catches errors before consolidation
 - Requests revisions from sub-agents if needed

 Example validation checks:
 - Code style consistency across files
 - No duplicated effort between agents
 - All tests pass
 - No breaking changes introduced

6. **Parallel dispatch optimization:**

 ```bash
 # Fleet automatically maximizes parallelism
 # Previously: Sequential sub-agent execution
 # Current behavior: More sub-agents run simultaneously

 /fleet "Generate API routes, database models, and tests for User, Product, Order entities"

 # Fleet might dispatch:
 # - 3 agents for routes (User, Product, Order) in parallel
 # - 3 agents for models in parallel
 # - 3 agents for tests in parallel
 # = 9 sub-agents potentially running concurrently
 ```

7. **Monitor fleet progress:**

 ```bash
 # Fleet shows orchestrator activity:
 # 📋 Orchestrator: Breaking down task into 6 subtasks
 # 🚀 Dispatched: Agent 1 → UserRoutes.ts
 # 🚀 Dispatched: Agent 2 → ProductRoutes.ts
 # 🚀 Dispatched: Agent 3 → OrderRoutes.ts
 # ✓ Agent 1 complete → Validating...
 # ✓ Agent 2 complete → Validating...
 # ⚠️ Agent 3 validation failed → Requesting revision...
 # ✓ Agent 3 revision complete
 # 📦 Consolidating results...
 ```

8. **Fleet with tool restrictions:**

 ```bash
 copilot --allow-tool 'write' --allow-tool 'shell(npm test)'
 /fleet "Create and test all CRUD endpoints for the API"
 ```

9. **Best practices:**
 - Let fleet handle task decomposition (don't over-specify subtasks)
 - Use for independent, parallelizable work
 - Review orchestrator validation results
 - Monitor for agent conflicts (rare but possible)
 - Works best with clear, well-scoped objectives

**Expected Outcome:**
Complex tasks are completed faster through parallel sub-agent execution with quality validation.

### Exercise 6: Advanced Shell Configuration

**Goal:** Configure advanced shell behavior and environment.

**Steps:**

1. **Using --bash-env flag:**

 The `--bash-env` flag sources your BASH_ENV file in Copilot's shell sessions:

 ```bash
 # Create a custom BASH_ENV file
 cat > ~/.copilot_env << 'EOF'
 # Custom environment for Copilot sessions
 export PROJECT_ROOT=/workspace/myproject
 export NODE_ENV=development
 export DEBUG=app:*

 # Useful aliases
 alias ll='ls -lah'
 alias gst='git status'

 # Functions
 test-and-commit {
 npm test && git commit -m "$1"
 }
 EOF

 # Set BASH_ENV
 export BASH_ENV=~/.copilot_env

 # Start Copilot with the environment
 copilot --bash-env
 ```

2. **When to use --bash-env:**
 - Project-specific environment variables needed by scripts
 - Custom aliases that your workflow depends on
 - Functions that Copilot should have access to
 - Consistent shell configuration across sessions

3. **Example with custom environment:**

 ```bash
 # In ~/.copilot_env
 export DB_HOST=localhost
 export DB_PORT=5432
 export API_KEY=${SECURE_API_KEY}

 # Start Copilot
 copilot --bash-env -p "Run the database migration script"

 # Copilot's shell commands will have access to DB_HOST, DB_PORT, etc.
 ```

4. **Shell mode access change:**

 > **Important**: shell mode is no longer accessible via Shift+Tab cycling.

 **Old behavior:**

 ```
 Shift+Tab: cycle through (chat) → (edit) → (shell)
 ```

 **New behavior:**

 ```
 Shift+Tab: cycle through (chat) ⟷ (edit) only
 ! (exclamation): direct access to shell mode
 ```

 **To enter shell mode:**

 ```bash
 copilot
 # Type ! to enter shell mode
 ! ls -la
 ! git status
 ! npm install
 ```

5. **Combining shell mode with --bash-env:**

 ```bash
 # Set up environment
 export BASH_ENV=~/.copilot_project_env
 copilot --bash-env

 # In session, use shell mode
 ! echo $PROJECT_ROOT
 # Outputs: /workspace/myproject (from BASH_ENV)

 ! test-and-commit "Add new feature"
 # Uses function from BASH_ENV
 ```

**Expected Outcome:**
Shell sessions have consistent environment configuration, and you understand the new shell mode access pattern.

### Exercise 7: LSP and Language Server Configuration

**Goal:** Configure Language Server Protocol (LSP) timeout settings.

**Steps:**

1. **What is LSP timeout configuration?**

 Copilot CLI can use language servers (TypeScript, Python, Go, etc.) for:
 - Code intelligence and completions
 - Jump to definition
 - Find references
 - Type information

 Some language servers may timeout on large codebases. The `lsp.json` config lets you adjust these timeouts.

2. **Create lsp.json configuration:**

 ```bash
 # Create LSP config in Copilot config directory
 cat > ~/.copilot/lsp.json << 'EOF'
 {
 "timeout": {
 "initialization": 30000,
 "request": 10000,
 "shutdown": 5000
 },
 "servers": {
 "typescript": {
 "timeout": {
 "initialization": 60000,
 "request": 20000
 }
 },
 "python": {
 "timeout": {
 "initialization": 45000,
 "request": 15000
 }
 }
 }
 }
 EOF
 ```

3. **Timeout values explained:**
 - `initialization`: Time allowed for LSP server to start (milliseconds)
 - `request`: Time allowed for individual LSP requests
 - `shutdown`: Time allowed for graceful shutdown

 **Default values (if not configured):**
 - initialization: 15000ms (15 seconds)
 - request: 90000ms (90 seconds) — increased from 30s
 - shutdown: 3000ms (3 seconds)

4. **When to adjust LSP timeouts:**

 ```bash
 # Increase if you see errors like:
 # "TypeScript language server initialization timeout"
 # "LSP request timeout for workspace/symbol"

 # Common scenarios:
 # - Large monorepos with thousands of files
 # - Slow file systems (network drives, container volumes)
 # - Resource-constrained environments
 # - Complex TypeScript projects with heavy type inference
 ```

5. **Per-language server configuration:**

 ```json
 {
 "servers": {
 "typescript": {
 "timeout": {
 "initialization": 90000,
 "request": 30000
 },
 "maxNumberOfProblems": 100
 },
 "rust": {
 "timeout": {
 "initialization": 120000,
 "request": 45000
 }
 }
 }
 }
 ```

6. **Verify LSP configuration:**

 ```bash
 # Check if config is valid JSON
 cat ~/.copilot/lsp.json | jq .

 # Start Copilot and check for LSP initialization
 copilot
 # Watch for language server startup messages in debug mode
 ```

7. **Debug LSP issues:**

 ```bash
 # Enable debug logging
 export COPILOT_DEBUG=1
 copilot

 # Look for LSP-related messages:
 # "Initializing TypeScript language server..."
 # "LSP initialization complete in 23457ms"
 # "LSP request: textDocument/definition"
 ```

8. **Disable LSP for specific languages:**

 ```json
 {
 "servers": {
 "javascript": {
 "enabled": false
 }
 }
 }
 ```

**Expected Outcome:**
Language server timeouts are configured for your environment, eliminating timeout errors in large projects.

### Exercise 8: Configuration File Deep Dive

**Goal:** Understand and customize config.json and related configuration files.

**Steps:**

1. View current configuration:

 ```bash
 cat ~/.copilot/config.json
 ```

2. Example full configuration:

 ```json
 {
 "trustedFolders": [
 "/home/user/projects",
 "/home/user/work"
 ],
 "model": "gpt-4.1",
 "theme": "dark",
 "autoUpdate": true
 }
 ```

3. Add trusted folders:

 ```bash
 # Using jq to update config
 jq '.trustedFolders += ["/new/path"]' ~/.copilot/config.json > tmp.json
 mv tmp.json ~/.copilot/config.json
 ```

4. Configure URL restrictions:

 ```json
 {
 "allowedUrls": [
 "https://api.github.com/*",
 "https://docs.github.com/*"
 ],
 "deniedUrls": [
 "https://evil.com/*"
 ]
 }
 ```

**Expected Outcome:**
Custom configuration for your workflow, including LSP settings from Exercise 7.

### Exercise 9: Troubleshooting Guide

**Goal:** Diagnose and fix common issues.

**Steps:**

1. **Authentication issues:**

 ```bash
 # Clear credentials and re-authenticate
 rm -rf ~/.copilot/auth*
 copilot
 # Follow OAuth flow
 ```

2. **Tool not working:**

 ```bash
 # Check if tool is allowed
 copilot -p "test" --available-tools

 # Verify MCP servers
 copilot
 /mcp show
 ```

3. **Session issues:**

 ```bash
 # Clear session data
 rm -rf ~/.copilot/sessions/

 # Start fresh
 copilot
 /clear
 ```

4. **Performance issues:**

 ```bash
 # Check context usage
 copilot
 /context

 # Compact if needed
 /compact

 # Or start fresh
 /clear
 ```

5. **Agent not found:**

 ```bash
 # Verify agent file exists
 ls -la .github/agents/

 # Check YAML syntax
 cat .github/agents/my-agent.md | head -10

 # Ensure frontmatter is valid
 ```

6. **MCP server failing:**

 ```bash
 # Check if server runs independently
 npx @modelcontextprotocol/server-memory

 # Check config syntax
 cat ~/.copilot/mcp-config.json | jq .
 ```

7. **Use `/diagnose` for quick troubleshooting:**

 The `/diagnose` command provides a diagnostic summary of your current session and environment:

 ```bash
 copilot
 /diagnose
 ```

 > **Note**: If no session has been started yet, `/diagnose` shows a helpful message guiding you to start one first. Run it inside an active session for full diagnostics.

**Expected Outcome:**
You can diagnose and resolve common problems using `/diagnose`, LSP timeout tuning, and shell mode access.

### Exercise 10: Team Workflow Patterns

**Goal:** Establish team-wide Copilot practices.

**Steps:**

1. **Standardize repository configuration:**

 ```bash
 # Create a template repository with:
 .github/
 ├── copilot-instructions.md # Team coding standards
 ├── agents/
 │ ├── reviewer.md # Code review agent
 │ └── docs.md # Documentation agent
 ├── instructions/
 │ ├── typescript.instructions.md
 │ └── tests.instructions.md
 └── hooks/
 └── hooks.json # Security guardrails

 AGENTS.md # Project-specific agent
 llm.txt # Project context for LLMs
 ```

2. **Create onboarding documentation:**

 ```markdown
 # Team Copilot CLI Guide

 ## Setup
 1. Install: `npm install -g @github/copilot`
 2. Authenticate: `copilot` and follow OAuth
 3. Clone this repo template

 ## Our Agents
 - `@reviewer` - Code review
 - `@docs` - Documentation

 ## Commit Convention
 All commits must follow Conventional Commits.

 ## Security Rules
 - Never approve `rm -rf` for session
 - Never push directly to main
 - Always use `--deny-tool 'shell(git push)'` in automation
 ```

3. **Share MCP configurations:**

 ```bash
 # Create a shared MCP config
 cat > shared-mcp-config.json << 'EOF'
 {
 "servers": {
 "team-tools": {
 "url": "https://team-mcp.example.com/",
 "requestInit": {
 "headers": {
 "Authorization": "Bearer ${TEAM_MCP_TOKEN}"
 }
 }
 }
 }
 }
 EOF
 ```

4. **Establish review checklist:**

 ```markdown
 ## PR Copilot Checklist
 - [ ] Run `@reviewer` on changes
 - [ ] Generate docs with `@docs`
 - [ ] Check context usage stayed reasonable
 - [ ] No sensitive data in session exports
 ```

**Expected Outcome:**
Team-wide standardization on Copilot usage, including shared LSP and environment configurations.

### Exercise 11: Performance Optimization

**Goal:** Get the best performance from Copilot CLI.

**Steps:**

1. **Optimize startup time:**

 ```bash
 # Pre-authenticate
 copilot --version

 # Use --silent for faster scripted operations
 copilot -p "quick task" --silent
 ```

2. **Reduce network round-trips:**

 ```bash
 # Batch operations
 copilot -p "Create user.ts, user.test.ts, and user.types.ts with related code" \
 --allow-tool 'write'

 # Instead of three separate prompts
 ```

3. **Choose appropriate models:**

 ```bash
 # Fast model for simple tasks
 copilot --model gpt-5-mini -p "Format this JSON"

 # Full model for complex analysis
 copilot --model gpt-4.1 -p "Refactor this complex module"
 ```

4. **Efficient context management:**

 ```bash
 # Use the Explore agent for overview without context cost
 # Use @path/to/file to include specific files in prompts
 # Use targeted reads instead of reading all files
 # Compact proactively, not reactively
 ```

5. **Use Autopilot for repetitive multi-step tasks:**

 ```bash
 # Instead of manual step-by-step
 copilot --autopilot -p "Set up complete testing infrastructure for all services"

 # Saves time and reduces back-and-forth
 ```

6. **Use Fleet for parallel work:**

 ```bash
 # Faster than sequential processing
 copilot
 /fleet "Migrate all 50 components to the new API format"

 # Multiple agents work in parallel
 ```

7. **Parallel sessions for independent tasks:**

 ```bash
 # Terminal 1: Frontend work
 cd frontend && copilot

 # Terminal 2: Backend work
 cd backend && copilot

 # Terminal 3: Documentation
 cd docs && copilot
 ```

**Expected Outcome:**
Maximum performance from Copilot CLI using parallelization, autopilot, and fleet features.

### Exercise 12: Deep Research and Session Insights

**Goal:** Use `/research` for deep research with exportable reports, and explore `/chronicle` for session-history insights.

**Steps:**

1. **Deep research with `/research`:**

 The `/research` command launches a deep-research workflow that investigates a topic thoroughly and produces an exportable report:

 ```bash
 copilot
 /research "Compare the trade-offs of REST vs GraphQL for mobile backends"
 ```

 Copilot will:
 - Break the topic into sub-questions
 - Investigate each area using available tools (web fetch, file reads, etc.)
 - Synthesize findings into a structured report
 - Offer to export the report as a markdown file

2. **Export research output:**

 ```bash
 # After /research completes, export the report
 /share ./research-report.md
 ```

3. **Combine with tool restrictions:**

 ```bash
 copilot --allow-tool 'web_fetch' --deny-tool 'write'
 /research "What are the latest best practices for Node.js error handling?"

 # Read-only research — Copilot can fetch web content but won't modify files
 ```

4. **Session insights with `/chronicle`:**

 > ⚠️ **FEEDBACK**: `/chronicle` is experimental. Subcommands and behavior may change in future releases.

 The `/chronicle` command analyzes your session history to provide actionable insights:

 ```bash
 copilot

 # Generate a standup summary from recent sessions
 /chronicle standup

 # Get tips based on your usage patterns
 /chronicle tips

 # Get suggestions to improve your workflow
 /chronicle improve
 ```

 `/chronicle` subcommands:
 - **`standup`** — Summarizes what you accomplished across recent sessions (useful for daily standups)
 - **`tips`** — Suggests Copilot features you may not be using effectively
 - **`improve`** — Analyzes patterns and recommends workflow improvements

**Expected Outcome:**
You can run deep-research workflows and extract insights from your session history.

## Configuration Reference

> 💡 For a comprehensive configuration reference including all config options, environment variables, and CLI flags, see [Module 13: Configuration & Environment](13-configuration.md).

### Configuration Files

| File | Purpose | Version Added |
| ------ | --------- | --------------- |
| `~/.copilot/config.json` | User settings | Base |
| `~/.copilot/mcp-config.json` | MCP servers | Base |
| `~/.copilot/lsp.json` | LSP timeout configuration | |
| `~/.copilot/skills/` | Personal skills | Base |
| `~/.agents/skills/` | Personal skill discovery (shared with VS Code) | v1.0.11+ |
| `.github/copilot-instructions.md` | Repository instructions | Base |

### Key Command-Line Flags

| Flag | Description |
| ------ | ------------- |
| `-p, --prompt` | Programmatic mode prompt |
| `-i, --interactive` | Interactive mode with auto-executed prompt |
| `--model` | Select AI model |
| `--resume` | Resume last session (accepts session ID or task ID) |
| `--yolo` / `--allow-all` | Allow all tools, paths, and URLs |
| `--allow-tool` / `--deny-tool` | Allow/deny specific tools |
| `--allow-url` / `--deny-url` | Allow/deny specific URLs |
| `--silent` | Suppress output |
| `--output-format` | Output as `text` or `json` (JSONL) |
| `--share PATH` | Export to markdown |
| `--share-gist` | Export to Gist |
| `--additional-mcp-config` | Add MCP config |
| `--autopilot` | Enable autonomous multi-step execution |
| `--max-autopilot-continues` | Limit autopilot continuation rounds |
| `--no-ask-user` | Disable agent questions (fully autonomous) |
| `--acp` | Start as Agent Client Protocol server |
| `--stream` | Enable/disable streaming (on/off) |
| `--bash-env` | Source BASH_ENV in shell sessions |
| `--experimental` | Enable experimental features |
| `--mouse` / `--no-mouse` | Mouse behavior |
| `--effort` | Shorthand for `--reasoning-effort` |
| `--secret-env-vars` | Redact env var values |
| `--no-custom-instructions` | Disable AGENTS.md loading |
| `--screen-reader` | Screen reader optimizations |
| `--no-color` | Disable color output |

### Slash Commands

| Command | Description |
| --------- | ------------- |
| `/help` | Show all available commands |
| `/clear` | Abandon session and start fresh |
| `/new [prompt]` | Start new conversation (old session backgrounded) |
| `/context` | View token usage |
| `/compact` | Compress session history |
| `/plan` | Create implementation plan |
| `/review` | Run code review agent |
| `/delegate` | Hand off to cloud agent |
| `/fleet` | Launch parallel sub-agents for complex tasks |
| `/autopilot on\|off` | Toggle autopilot mode |
| `/research` | Launch deep-research workflow with exportable reports |
| `/chronicle` | Session-history insights (standup, tips, improve) — experimental |
| `/diagnose` | Show diagnostic summary of session and environment |
| `/undo` | Undo last turn and revert file changes |
| `/rewind` | Timeline picker to roll back to any point (also double-Esc) |
| `/copy` | Copy last response to clipboard |
| `/ide` | Connect to IDE workspace |
| `/streamer-mode` | Toggle streamer mode |
| `/mcp` | Manage MCP servers |
| `/mcp auth` | Re-authenticate MCP OAuth servers |
| `/share html` | Export session as interactive HTML |
| `/allow-all [on\|off\|show]` | Enable, disable, or check allow-all mode |

### Shell Mode Access

> **Changed**: Shell mode removed from Shift+Tab cycle

| Method | Description |
| -------- | ------------- |
| `!` | Direct access to shell mode |
| `Shift+Tab` | Cycle (chat) ⟷ (edit) only |

### Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc

# Quick Copilot start
alias cop='copilot'

# Read-only analysis
alias cop-analyze='copilot --deny-tool write'

# Safe automation mode
alias cop-safe='copilot --allow-tool "shell(cat)" --allow-tool "shell(grep)" --deny-tool write'

# Full autonomy (careful!)
alias cop-yolo='copilot --yolo'

# Resume session
alias cop-resume='copilot --resume'
```

## Summary

- ✅ Environment variables customize behavior globally
- ✅ CI/CD integration enables automated workflows
- ✅ Advanced flags give precise control
- ✅ **Autopilot mode** enables autonomous multi-step task execution
- ✅ **Fleet command** parallelizes complex tasks with orchestrator validation
- ✅ **--bash-env** sources custom environment for shell sessions
- ✅ **--experimental** enables experimental features
- ✅ **Configurable status line** displays dynamic session info via custom shell scripts
- ✅ **Environment loading indicator** shows skills, MCPs, and plugins being loaded at startup
- ✅ **Status line responsive layout** auto-switches to two-line layout on narrow terminals
- ✅ **Expanded `--help` output** with descriptions, examples, and sorted flags
- ✅ **`/research` command** for deep-research workflows with exportable reports
- ✅ **`--disable-parallel-tools-execution` removed** — parallel tool execution is now always enabled
- ✅ **`/chronicle` command** (experimental) for session-history insights: standup, tips, improve
- ✅ **`--mouse`/`--no-mouse` flag** controls mouse behavior
- ✅ **`--effort` flag** shorthand for `--reasoning-effort`
- ✅ **Monorepo support** discovers instructions, MCPs, skills, and agents from cwd to git root
- ✅ **`/diagnose` command** for troubleshooting session and environment issues
- ✅ **`--max-autopilot-continues`** limits autopilot continuation rounds
- ✅ **`--no-ask-user`** enables fully autonomous operation without questions
- ✅ **`--acp`** starts Agent Client Protocol server
- ✅ **`--output-format json`** enables JSONL output for scripting
- ✅ **`--stream`** controls streaming mode
- ✅ **`-i, --interactive`** starts interactive mode with auto-executed prompt
- ✅ **LSP configuration** controls language server timeouts; default request timeout is 90s
- ✅ **Shell mode access** via `!` command
- ✅ config.json and lsp.json persist preferences
- ✅ Team standardization ensures consistency
- ✅ Performance optimization maximizes productivity

## Next Steps

→ Continue to [Module 13: Configuration & Environment](13-configuration.md)

## References

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot CLI - GitHub Docs](https://docs.github.com/copilot/how-tos/copilot-cli)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [Copilot CLI Blog Posts](https://github.blog/tag/copilot/)
- [GitHub Community Discussions](https://github.com/orgs/community/discussions)
- [agentskills.io](https://agentskills.io/)
