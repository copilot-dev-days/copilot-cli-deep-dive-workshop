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

The diagram is a schematic of inputs, **not a universal precedence order**: `COPILOT_HOME` selects storage, individual keys have their own override rules, and managed policy can constrain overrides. See Module 13 and installed configuration help.

```
Environment Variables
 ↓
COPILOT_HOME (~/.copilot)
 ↓
Repository Configuration
 ↓
Session Overrides (flags)
```

### Key Directories

| Directory | Purpose |
| --------- | --------- |
| `~/.copilot/` | Default config location |
| `~/.copilot/settings.json` | User settings |
| `~/.copilot/config.json` | Machine-managed state and credentials (do not edit) |
| `~/.copilot/mcp-config.json` | MCP servers |
| `~/.copilot/lsp-config.json` | Language servers |
| `~/.copilot/skills/` | Personal skills |
| `~/.agents/skills/` | Personal skill discovery directory (shared with VS Code extension) |
| `.github/` | Repository config |

> [!WARNING]
> `~/.copilot/config.json` is managed automatically and stores your authentication token. Do not print, copy, or share it — especially while screen sharing. Put user settings in `~/.copilot/settings.json`, or use `/settings` to edit them.

### Commands & Features

The following commands and features are available:

#### `/pr` — Pull Request Management

> `/pr view [local|web]` manages pull request viewing. The `/pr` command provides a full PR management suite.

| Subcommand | Description |
| --- | --- |
| `/pr` | Create and view PRs |
| `/pr view local` | View PR status locally |
| `/pr view web` | Open PR in browser |

The `/pr` command can also automatically fix CI failures, address review feedback, and resolve merge conflicts.

#### Background Agents & Multi-Turn Conversations

> Background task notifications display in the timeline with expandable detail.

The `write_agent` tool enables multi-turn conversations with background agents — send follow-up messages to agents spawned via the task tool.

Sub-agents launched by the task tool have human-readable names in the timeline. Protocol/task IDs can still be UUIDs; use the actual `agent_id` returned by the tool for follow-ups rather than guessing an ID from the name.

The `read_agent` output includes inbound messages that triggered each turn in multi-turn agents.

#### `/experimental` Toggle

> Toggling experimental mode with `/experimental on|off` automatically restarts the CLI to apply changes immediately. No manual restart needed.

#### Monorepo Support

Discovery supports monorepos, with resource-specific rules: project agents/MCP walk cwd to git root; instruction discovery also includes relevant nested paths, while modular instructions exclude intermediate directories. Inspect `/env` instead of assuming every resource uses identical discovery.

#### `--effort` Shorthand

Use `--effort` as a shorthand alias for `--reasoning-effort` to control model reasoning level.

#### Resume Controls

`--resume` accepts a session ID, task ID, ID prefix, or session name, and opens the session picker when given no value. Use `--continue` to resume the most recent session directly.

#### `copilot app` — Open the Copilot App

Alongside the `/app` slash command available inside a session, `app` is also a shell subcommand:

```bash
# Open the GitHub Copilot app in the current directory
copilot app
```

This is handy when you want to jump into the app from a terminal without first starting an interactive session.

#### Remote Control Sessions

Use the `--remote` flag or `/remote` command to start a remote control session:
>
> ```text
> # Start Copilot with remote control enabled
> copilot --remote
>
> # Or enable in an existing session
> /remote
> ```
>
> Remote control allows another Copilot CLI instance to connect and observe or control your session — useful for pair programming, teaching, and debugging.

Read-only account history uses `--sync-session=on|off`; it does **not** enable incoming control. Stop live remote access with `/remote off`. Optional `--host-environment NAME` and `--host-compute-id ID` relate to headless hosted execution, not local history export; provisioning/account behavior needs a targeted check.

#### ACP Clients Provide MCP Servers

> ACP (Agent Client Protocol) clients can provide MCP servers when starting or loading sessions. This enables IDE integrations to inject MCP server configurations into CLI sessions dynamically.

#### `copilot help monitoring`

> The `copilot help monitoring` topic documents how to configure OpenTelemetry for observability:
>
> ```text
> copilot help monitoring
> ```
>
> This covers OTLP exporter configuration, span attributes, and integration with monitoring backends.

#### OpenTelemetry Monitoring

> OpenTelemetry monitoring covers:
> - Sub-agent spans are tagged as `INTERNAL` spans for better trace visualization
> - `time_to_first_chunk` metric tracks latency from request to first streaming chunk
> - Span attributes for debugging agent behavior and performance

#### Custom Model Providers (BYOK)

> Copilot CLI supports Bring Your Own Key (BYOK) mode for using custom model providers. Set `COPILOT_PROVIDER_BASE_URL` to activate BYOK mode. GitHub authentication is not required when using a custom provider.
>
> ```text
> # Ollama (local, no API key required)
> COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1 \
>   COPILOT_MODEL=local-code-model \
>   copilot
> ```
>
> Run `copilot help providers` for full BYOK documentation including Azure, Anthropic, and OpenAI-compatible providers.

`COPILOT_PROVIDER_API_KEY_COMMAND` runs a trusted command to obtain a fresh key per request; do not log its output. `COPILOT_PROVIDER_VISION=true` opts into image input only for a capable model. The optional `providers.json` named registry takes precedence when populated and stores credential strings in plain text; validate the provider schema and connection before relying on it.

#### Offline Mode

> Set `COPILOT_OFFLINE=true` to enable offline mode. When active, the CLI skips all network access: GitHub authentication, telemetry, web tools, GitHub MCP server, and auto-update are disabled. Requires a local model provider (`COPILOT_PROVIDER_BASE_URL`).

#### `COPILOT_GH_HOST`

> `COPILOT_GH_HOST` overrides the GitHub hostname used by Copilot CLI only, independent of `GH_HOST`. Use this when `GH_HOST` points to a GitHub Enterprise Server instance but Copilot CLI needs to authenticate against github.com or a GHEC data residency hostname.

#### Help Topics

> Run `copilot help <topic>` without starting a session to access built-in documentation:
>
> | Topic | Content |
> |-------|---------|
> | `billing` | AI credit usage |
> | `commands` | Interactive mode commands |
> | `config` | Configuration settings |
> | `environment` | Environment variables |
> | `limits` | Session limits controls |
> | `logging` | Logging configuration |
> | `monitoring` | OpenTelemetry monitoring |
> | `permissions` | Tool, URL, and path permissions |
> | `providers` | Custom model providers (BYOK) |
> | `sandbox` | Command sandboxing |

#### Session Limits & AI Credits

> Session limits are opt-in and cap AI credit consumption for a session. Usage accumulates across the whole conversation, and subagents share the parent session's limit.
>
> ```bash
> # Cap a session at the minimum allowed AI credit limit
> copilot --max-ai-credits 30
> ```
>
> | Command | Description |
> | --- | --- |
> | `/limits` | Open the interactive limits dialog for the current session |
> | `/limits set max-ai-credits <n>` | Set the AI credit limit (minimum 30) |
> | `/limits unset [max-ai-credits]` | Remove a configured limit |
>
> The AI credit limit is a **soft cap**: usage is only known after a model response returns, so a single call can exceed the limit before the CLI blocks the next one. `/clear` and `/new` reset used credits but keep the configured limit. Run `copilot help limits` and `copilot help billing` for the full reference.

## Hands-On Exercises

Absolute paths such as `/custom/path` and `/new/path` are schematic: substitute existing, writable directories you control. Review added roots before trusting their configuration.

> [!WARNING]
> For local-only workshop validation, append `--sync-session=off` to **every** session launch below, including interactive, resumed, fleet, autopilot, and ACP launches. Session history sync is enabled by default; disabling live remote control is not the same as disabling history sync. Do not run remote/Gist examples or `/chronicle reindex` in a no-upload exercise. Use disposable fixtures, a 60–90 second external timeout, and bounded autopilot continuations; never run the broad refactoring examples against an unspecified repository.

### Exercise 1: Environment Variables

> [!IMPORTANT]
> Authentication normally checks `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, then `GITHUB_TOKEN` ahead of stored accounts. Codespaces' auto-injected `GITHUB_TOKEN` does not override a `/login` account; explicitly exported tokens still do. Never print token values.

**Goal:** Configure Copilot CLI behavior via environment.

**Steps:**

1. **COPILOT_HOME** - Change config location:

 ```bash
 # Set custom config directory
 export COPILOT_HOME=/custom/path

 # Copilot uses /custom/path/
 copilot
 ```

2. **GITHUB_TOKEN** - Authentication for CI/CD:

 ```bash
 export COPILOT_GITHUB_TOKEN="github_pat_your_personal_access_token"

 # Use in scripts
 copilot -p "Run the test suite" --allow-tool 'shell'
 ```

3. **NO_COLOR** - Disable colored output:

 ```bash
 export NO_COLOR=1
 copilot -p "List files"
 ```

4. View effective configuration:

 ```bash
 copilot --help | head -50
 ```

 > **Note:** `copilot --help` shows descriptions and examples; the workshop contains selected flags, not a guaranteed exhaustive/sorted reference.

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
     # Never expose a privileged token to arbitrary fork code/configuration.
     if: github.event.pull_request.head.repo.full_name == github.repository
     runs-on: ubuntu-latest
     permissions:
       contents: read
     steps:
       - name: Checkout repository
         uses: actions/checkout@main
         with:
           ref: ${{ github.event.pull_request.head.sha }}
           fetch-depth: 0

       - name: Install Copilot CLI
         run: npm install -g @github/copilot

       - name: Run Code Review
         env:
           COPILOT_GITHUB_TOKEN: ${{ secrets.COPILOT_PAT }}
           BASE_SHA: ${{ github.event.pull_request.base.sha }}
           COPILOT_ALLOW_ALL: "false"
         run: |
           git diff "$BASE_SHA" HEAD | \
           copilot -p "Review this supplied PR diff against its base; report findings only" \
             --available-tools 'view,grep,glob' \
             --deny-tool 'shell' \
             --deny-tool 'write' \
             --no-custom-instructions \
             --disable-builtin-mcps \
             --usage-output-file ./copilot-usage.json \
             --silent
 ```

 > Review and pin third-party Actions to an approved immutable commit in your own workflow. The checkout retrieves the actual PR head; `BASE_SHA` names that PR's base commit, not a guessed default branch. Restrict this exercise to trusted code, configuration, and token scope. Denying `write` alone would not prevent shell writes; here agent shell tools are excluded. The CLI itself still writes session/usage files.

 > [!NOTE]
 > Shell approval matches on a first-level subcommand, such as `git push` or `gh pr create`, so `shell(git)` on its own does not cover them. Use `shell(git:*)` to match every git command. The wildcard matches on the command stem, so `shell(git:*)` matches `git push` but not `gitea`.

 > [!TIP]
 > `--usage-output-file <file>` writes final usage statistics as JSON to the given path. In a pipeline you can upload it as an artifact or assert against it to keep automated runs within budget.

2. **Pre-commit hook:**

 Save the following as `.git/hooks/pre-commit` and make it executable:

 ```bash
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
 FROM node:lts-slim

 RUN npm install -g @github/copilot

 # Set up config directory
 ENV COPILOT_HOME=/app/config

 WORKDIR /workspace

 # Entry point for CI
 ENTRYPOINT ["copilot"]
 ```

4. **Safe CI flags:**

 ```bash
 copilot -p "Your prompt" \
 --allow-tool 'shell(npm test)' \
 --allow-tool 'shell(npm run:*)' \
 --deny-tool 'shell(rm)' \
 --deny-tool 'shell(git push)' \
 --deny-tool 'write' \
 --silent
 ```

 `shell(npm run:*)` approves **all** `npm run` scripts, not just lint. Review the disposable project's scripts first; this command-stem rule avoids relying on unsupported deeper-subcommand matching.

**Expected Outcome:**
Copilot CLI integrated into automated workflows.

### Exercise 3: Advanced Command-Line Flags

**Goal:** Practice selected advanced flags and discover others through installed help.

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
 # Make only these tools visible to the model
 copilot --available-tools 'bash,view,glob,grep'

 # Hide specific tools from the model
 copilot --excluded-tools 'create,edit,web_fetch'
 ```

 > [!NOTE]
 > `--available-tools` and `--excluded-tools` filter by **tool name** and decide which tools the model can see. They are distinct from `--allow-tool`/`--deny-tool`, which take permission rule kinds such as `shell(...)`, `write(...)`, `url(...)`, and `<mcp-server>(...)` and control approval prompts. See [Module 4: Tools & Permissions](04-tools.md) for the full tool list.

3. **Model selection:**

 ```bash
 # Use automatic model selection
 copilot --model auto

 # Set a model for a simple task
 copilot --model auto -p "What time is it?"
 ```

4. **Session control:**

 ```bash
 # Resume the most recent session
 copilot --continue

 # Pick a previous session from the session picker
 copilot --resume

 # Use additional MCP config temporarily
 printf '{"mcpServers":{}}' > custom-mcp.json
 copilot --additional-mcp-config @./custom-mcp.json
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

6. **Inspect installed flag help:**

 ```bash
 copilot --help
 ```

 > **Note:** `copilot --help` is the installed command reference; this exercise covers selected controls.

**Expected Outcome:**
Full command-line control over Copilot behavior.

### Exercise 4: Autopilot Mode

**Goal:** Use Autopilot mode for autonomous multi-step tasks.

**Steps:**

1. **What is Autopilot mode?**

 Autopilot encourages continuation through multi-step tasks, but **does not itself grant every permission**. Requests still follow effective permissions; pre-authorize only intended operations. The agent:
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

 # Plan and then implement autonomously within a bounded continuation count
 copilot --plan --mode autopilot --max-autopilot-continues 3 \
   -p "Plan and implement a focused test improvement" --allow-tool 'write'

 # Or use Shift+Tab to cycle modes in an active session
 # (chat → plan → autopilot)
 ```

 > **Permission elevation:** When accepting a plan with autopilot, Copilot shows a permission elevation dialog to prevent auto-denied tool errors during autonomous execution.

 > **Plan approval menu:** Plan approval shows model-curated actions with a recommended option highlighted, including an **autopilot+fleet** option for parallelizable work.

 > Fleet can start directly with `copilot --fleet -i "Add tests for independent modules"` (also `-p` or piped stdin). Set scope/permissions and inspect `/tasks`; concurrency and continuation limits do not bound every side effect or guarantee completion. Repository-aware custom subagents need `include-custom-instructions: true`; model preferences/policies and Auto routing affect their dispatched model (Module 8).

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

6. **Switch out of Autopilot mid-session:**

 Use `Shift+Tab` to cycle back to chat or plan mode, or press `Esc` to interrupt the current autonomous operation.

 ```
 # Manual reads remain auto-approved; other requests follow effective rules/grants
 ```

7. **Limit autopilot continuation rounds:**

 ```bash
 # Limit to 10 continuation rounds (default: 5)
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
 ```

 ```
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

 ```
 # Fleet automatically maximizes parallelism
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
 ```

 ```
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
 # Create only if absent; otherwise review and merge in your editor
 test ! -e "$HOME/.copilot_env" &&
 cat > ~/.copilot_env << 'EOF'
 # Custom environment for Copilot sessions
 export PROJECT_ROOT=/workspace/myproject
 export NODE_ENV=development
 export DEBUG=app:*

 # Useful aliases
 alias ll='ls -lah'
 alias gst='git status'

 # Functions
 test-and-commit() {
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
 copilot --bash-env -p "Run the database change script"

 # Copilot's shell commands will have access to DB_HOST, DB_PORT, etc.
 ```

4. **Shell mode access:**

 > **Important**: Shift+Tab cycles chat → plan → autopilot. `!` runs direct commands; `$` hands off to an interactive shell. Keyboard behavior depends on terminal/TTY and policy.

 **Shell mode is not part of the Shift+Tab cycle.** Instead:

 ```
 Shift+Tab: cycle through (chat) → (plan) → (autopilot)
 ```

 **Shell mode access:**

 ```
 Shift+Tab: cycle through (chat) → (plan) → (autopilot)
 ! (exclamation): direct access to shell mode
 $ (dollar): interactive shell handoff (when enabled)
 ```

 **To enter shell mode:**

 ```bash
 copilot
 ```

 Inside the session, type `!` to enter shell mode, then run commands such as:

 ```
 ! ls -la
 ! git status
 ! npm install
 ```

5. **Combining shell mode with --bash-env:**

 ```bash
 # Set up environment
 export BASH_ENV=~/.copilot_env
 copilot --bash-env
 ```

 Inside the session, use shell mode to confirm the environment is available:

 > Validate this separately from model-invoked shell tools: the direct `!` shell path may use `/bin/sh` and may not source `BASH_ENV` even with `--bash-env`. If the marker is missing, explicitly use Bash and source your reviewed environment file (for example, `! bash -c '. ~/.copilot_env; echo "$PROJECT_ROOT"'`). Bash-specific function names in the sample are not portable to `/bin/sh`. Do not invoke the commit helper during validation.

 ```
 ! echo $PROJECT_ROOT
 # Outputs: /workspace/myproject (from BASH_ENV)

 ! test-and-commit "Add new feature"
 # Uses function from BASH_ENV
 ```

**Expected Outcome:**
Shell sessions have consistent environment configuration, and you understand how to enter shell mode.

### Exercise 7: LSP and Language Server Configuration

**Goal:** Configure Language Server Protocol (LSP) servers so Copilot CLI gets real code intelligence for your languages.

**Steps:**

1. **Understand what LSP adds:**

 Copilot CLI can talk to language servers (TypeScript, Python, Ruby, Go, and others) for:
 - Code intelligence and symbol lookup
 - Jump to definition
 - Find references
 - Type information and diagnostics

 Language servers must be configured explicitly — none are enabled by default. Install the language server binary first, then point Copilot CLI at it.

2. **Install a language server:**

 ```bash
 # TypeScript / JavaScript
 npm install -g typescript typescript-language-server

 # Python
 npm install -g pyright

 # Ruby (optional: requires Ruby and RubyGems installed separately)
 gem install ruby-lsp
 ```

3. **Create the LSP configuration:**

 Copilot CLI reads two files, both using the same schema:

 | File | Scope |
 | --- | --- |
 | `~/.copilot/lsp-config.json` | Personal — applies to all your projects |
 | `.github/lsp.json` | Project — checked in, applies to everyone on the repo |

 Write the sample to a new exercise file, then merge its server entries into existing strict-JSON LSP configuration. Review same-name collisions before merging; do not overwrite unrelated servers.

 ```bash
 test ! -e workshop-lsp.json &&
 cat > workshop-lsp.json << 'EOF'
 {
   "lspServers": {
     "typescript": {
       "command": "typescript-language-server",
       "args": ["--stdio"],
       "fileExtensions": {
         ".ts": "typescript",
         ".tsx": "typescriptreact",
         ".js": "javascript",
         ".jsx": "javascriptreact"
       }
     },
     "python": {
       "command": "pyright-langserver",
       "args": ["--stdio"],
       "fileExtensions": {
         ".py": "python",
         ".pyi": "python"
       }
     }
   }
 }
 EOF

 (
   set -e
   umask 077
   CONFIG_HOME="${COPILOT_HOME:-$HOME/.copilot}"
   mkdir -p "$CONFIG_HOME"
   LSP_CONFIG="$CONFIG_HOME/lsp-config.json"
   MERGED=$(mktemp "$CONFIG_HOME/lsp-merge.XXXXXX")
   trap 'rm -f -- "$MERGED"' EXIT
   if [ -f "$LSP_CONFIG" ]; then
     jq -s '.[0] * .[1]' "$LSP_CONFIG" workshop-lsp.json > "$MERGED"
   else
     jq . workshop-lsp.json > "$MERGED"
   fi
   jq -e 'type == "object" and (.lspServers | type == "object")' "$MERGED"
   mv -- "$MERGED" "$LSP_CONFIG"
 )
 ```

 Each server name must be unique and contain only alphanumeric characters, underscores, and hyphens. Review same-name entries before merging: the exercise definition wins. A parse/validation failure aborts the subshell without replacing existing configuration.

4. **Server definition fields:**

 | Field | Required | Description |
 | --- | --- | --- |
 | `command` | Yes | Executable that starts the language server. Use `bash` or `powershell` instead to launch it through a script |
 | `args` | No | Arguments passed to the command |
 | `fileExtensions` | Yes | Map of file extension to language ID, e.g. `{ ".rs": "rust" }` |
 | `env` | No | Environment variables for the server process; supports `${VAR}` and `${VAR:-default}` expansion |
 | `cwd` | No | Working directory for the server process |
 | `rootUri` | No | Project root relative to the git root; defaults to `"."`. Useful in monorepos |
 | `initializationOptions` | No | Custom options sent to the server during startup |
 | `requestTimeoutMs` | No | Timeout for individual server requests (default: 90 seconds) |
 | `initializationTimeoutMs` | No | Timeout for the server's initialize handshake |
 | `spawnTimeoutMs` | No | Timeout for spawning the server process |
 | `warmupTimeoutMs` | No | Timeout for the server's initial project load |
 | `disabled` | No | Set to `true` to keep the definition but stop starting the server |

5. **Tune timeouts for large repositories:**

 ```json
 {
   "lspServers": {
     "typescript": {
       "command": "typescript-language-server",
       "args": ["--stdio"],
       "fileExtensions": { ".ts": "typescript", ".tsx": "typescriptreact" },
       "requestTimeoutMs": 120000,
       "initializationTimeoutMs": 90000,
       "warmupTimeoutMs": 60000
     }
   }
 }
 ```

 Raise these when you see language server startup or request timeouts on:
 - Large monorepos with thousands of files
 - Slow file systems (network drives, container volumes)
 - Resource-constrained environments
 - Complex TypeScript projects with heavy type inference

6. **Disable a server without removing it:**

 ```json
 {
   "lspServers": {
     "python": {
       "command": "pyright-langserver",
       "args": ["--stdio"],
       "fileExtensions": { ".py": "python" },
       "disabled": true
     }
   }
 }
 ```

7. **Manage servers from a session:**

 | Subcommand | Description |
 | --- | --- |
 | `/lsp show` | Display configured language servers and their configuration |
 | `/lsp logs` | Open the live LSP services panel (status + server logs) |
 | `/lsp test <name>` | Test whether a language server starts correctly |
 | `/lsp reload` | Reload LSP configurations from disk |

 ```bash
 # Validate the file is well-formed JSON
 jq empty "${COPILOT_HOME:-$HOME/.copilot}/lsp-config.json"
 copilot lsp list --json

 copilot
 ```

 ```
 /lsp show
 /lsp test typescript
 ```

 `/lsp show` prints the resolved user config path along with each configured server and its file extensions.

 A startup check is not sufficient proof of code intelligence. Verify an actual LSP definition/reference request. If `/lsp test` reports an immediate exit while `/lsp logs` shows ready, retain both results and investigate the diagnostic discrepancy rather than treating the test as passed.

8. **Troubleshoot startup problems:**

 ```bash
 # Capture detailed logs while the servers start
 copilot --log-level all --log-dir ./lsp-logs

 # Then inspect the log directory
 ls ./lsp-logs/
 ```

**Expected Outcome:**
Language servers are configured and verified with `/lsp test`, and you can tune per-server timeouts for large projects.

### Exercise 8: Configuration File Deep Dive

**Goal:** Understand and customize `settings.json` and the related configuration files.

> [!WARNING]
> `~/.copilot/config.json` is managed automatically by the CLI and holds your authentication token and trusted-folder state. Never print, copy, or share it — especially while screen sharing. Your own preferences belong in `~/.copilot/settings.json`.

**Steps:**

1. Inspect selected user settings (settings can contain sensitive hook/proxy values):

 ```bash
 copilot config theme
 copilot config model
 ```

2. Example settings file:

 ```json
 {
 "model": "auto",
 "theme": "github",
 "autoUpdate": true,
 "allowedUrls": [
 "https://api.github.com/*",
 "https://docs.github.com/*"
 ],
 "deniedUrls": [
 "https://evil.com/*"
 ]
 }
 ```

3. Change a setting from inside a session instead of editing the file by hand:

 ```bash
 copilot
 ```

 ```
 /settings theme dim
 /settings show theme
 ```

 `/settings` writes to `settings.json`. Run `/settings` with no arguments to open the settings dialog, and `/settings unset <key>` to remove a key.

4. Admit configuration and understand directory access:

 Saved trust is recorded when you choose to remember startup admission. `--add-dir` adds file access **and trusts that root's skills/agents**, not merely file access. Review it before adding:

 ```bash
 copilot --add-dir /new/path
 ```

**Expected Outcome:**
Custom user settings for your workflow in `settings.json`, plus the LSP configuration from Exercise 7 — with credentials left untouched.

### Exercise 9: Troubleshooting Guide

**Goal:** Diagnose and fix common issues.

**Steps:**

1. **Authentication issues:**

 ```bash
 # Clear credentials and re-authenticate
 copilot
 ```

 ```
 /logout
 /login
 ```

 Credentials are held in your system credential store, or in the machine-managed `~/.copilot/config.json` when no credential store is available. Use `/logout` rather than deleting files.

2. **Tool not working:**

 ```bash
 # Scope the run to a known-good set of tools by name
 copilot -p "test" --available-tools 'bash,view'

 # Inspect the loaded environment and MCP servers
 copilot
 ```

 ```
 /env
 /mcp
 ```

3. **Session issues:**

 ```bash
 # Inspect session data
 ls ~/.copilot/session-state/

 # Prune from inside a session instead of deleting files
 copilot
 ```

 ```
 /session prune
 /session delete-all
 ```

 Or start fresh in the current session:

 ```
 /clear
 ```

4. **Performance issues:**

 ```bash
 # Check context usage
 copilot
 ```

 ```
 /context
 ```

 Compact if needed, or start fresh:

 ```
 /compact
 /clear
 ```

5. **Agent not found:**

 ```bash
 # Verify agent file exists
 ls -la .github/agents/

 # Check YAML frontmatter syntax for available agents
 find .github/agents -maxdepth 1 -name '*.agent.md' -print

 # Ensure frontmatter is valid
 ```

6. **MCP server failing:**

 ```bash
 # Check if server runs independently
 npx @modelcontextprotocol/server-memory

 # Check config syntax
 jq empty "${COPILOT_HOME:-$HOME/.copilot}/mcp-config.json"
 ```

7. **Use `/diagnose` for quick troubleshooting:**

 The `/diagnose` command provides a diagnostic summary of your current session and environment:

 ```bash
 copilot
 ```

 ```
 /diagnose
 ```

 > **Note**: If no session has been started yet, `/diagnose` shows a helpful message guiding you to start one first. Run it inside an active session for full diagnostics.

**Expected Outcome:**
You can diagnose and resolve common problems using `/diagnose`, LSP timeout tuning, and shell mode access.

### Exercise 10: Team Workflow Patterns

**Goal:** Establish team-wide Copilot practices.

**Steps:**

1. **Standardize repository configuration:**

 ```text
 # Create a template repository with:
 .github/
 ├── copilot-instructions.md          # Team coding standards
 ├── agents/
 │   ├── reviewer.agent.md            # Code review agent
 │   └── docs.agent.md                # Documentation agent
 ├── instructions/
 │   ├── typescript.instructions.md
 │   └── tests.instructions.md
 └── hooks/
     └── hooks.json                   # Security guardrails

 AGENTS.md                            # Project-specific agent
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

3. **Share MCP configurations:** Use `mcpServers`, explicit transport `type`, and top-level headers. This endpoint is a placeholder for your administrator's real service; do not assume it connects:

 ```bash
 # Create a shared MCP config
 test ! -e shared-mcp-config.json &&
 cat > shared-mcp-config.json << 'EOF'
 {
 "mcpServers": {
 "team-tools": {
 "type": "http",
 "url": "https://team-mcp.example.com/",
 "headers": {
 "Authorization": "Bearer ${TEAM_MCP_TOKEN}"
 }
 }
 }
 }
 EOF
 ```

 **Removal candidate — original unsupported schema, do not apply:** `"servers": {"team-tools": {"requestInit": {"headers": {"Authorization": "Bearer ${TEAM_MCP_TOKEN}"}}}}`. Retained for identification; use the supported schema above and do not commit real credentials.

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
 # Check that the executable is available; this does not authenticate
 copilot --version

 # Use --silent to suppress progress/statistics, not to change model latency
 copilot -p "quick task" --silent
 ```

 Authenticate with `/login` in an interactive session before scripted model requests, or use your environment's approved authentication method.

2. **Reduce network round-trips:**

 ```bash
 # Batch operations
 copilot -p "Create user.ts, user.test.ts, and user.types.ts with related code" \
 --allow-tool 'write'

 # Instead of three separate prompts
 ```

3. **Choose appropriate models:**

 ```bash
 # Automatic model selection for simple tasks
 copilot --model auto -p "Format this JSON"

 # Choose an appropriate model for complex analysis from /model or copilot help config
 copilot --model auto -p "Refactor this complex module"
 ```

4. **Efficient context management:**

 ```bash
 # Explore reduces parent-context pressure; returned summaries still cost context/usage
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
 ```

 ```
 /fleet "Update all 50 components to the API format"
 ```

 Multiple agents work in parallel.

7. **Parallel sessions for independent tasks:**

 These commands assume your own project has `frontend`, `backend`, and `docs` directories. Substitute existing directories; do not run the examples against an unspecified layout.

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
 ```

 ```
 /research "Compare the trade-offs of REST vs GraphQL for mobile backends"
 ```

 Copilot will:
 - Break the topic into sub-questions
 - Investigate each area using available tools (web fetch, file reads, etc.)
 - Synthesize findings into a structured report
 - Offer to export the report as a markdown file

2. **Export research output:**

 ```
 # After /research completes, export the report
 /share file research ./research-report.md
 ```

3. **Combine with tool restrictions:**

 ```bash
 copilot --available-tools 'web_fetch,web_search,view,grep,glob' \
   --allow-url github.com --deny-tool 'shell' --deny-tool 'write'
 ```

 ```
 /research "What are current best practices for Node.js error handling?"
 ```

 Restricted research: no agent shell or write tools are exposed. `write` denial alone would not prevent shell writes. URL permissions/policy still apply, and the CLI itself can persist transcripts or exports.

 Report generation can require the agent's `create` tool, including for files under session storage. With this read/search-only tool list, findings can appear in chat while saving the research report fails; this is not a successful report/export exercise.

4. **Session insights with `/chronicle`:**

 > `/chronicle` is experimental. Subcommands and behavior may change.

 The `/chronicle` command analyzes your session history to provide actionable insights:

 ```bash
 copilot
 ```

 ```
 # Generate a standup report from your recent work
 /chronicle standup

 # Search all session content by keyword or topic
 /chronicle search

 # Get tips based on your usage patterns
 /chronicle tips

 # Get suggestions for reducing token usage and cost
 /chronicle cost-tips

 # Get suggestions for improving copilot-instructions.md
 /chronicle improve
 ```

 `/chronicle` subcommands:
 - **`standup`** — Report on your work from the last day
 - **`search`** — Search all session content by keyword or topic
 - **`tips`** — Personalized tips based on your usage patterns
 - **`cost-tips`** — Personalized tips to reduce token usage and cost
 - **`improve`** — Suggest improvements to `copilot-instructions.md`
 - **`reindex`** — Rebuild the local session store and sync session data to your account; do not run in a no-upload exercise

 A search that returns no rows does not prove retrieval succeeded, even when a local transcript contains the keyword. Keep sync disabled when required and record retrieval as unverified; do not enable sync or run `reindex` just to make the exercise pass.

**Expected Outcome:**
You can run deep-research workflows and extract insights from your session history.

## Configuration Reference

> 💡 For selected configuration options, environment variables, and CLI flags, see [Module 13: Configuration & Environment](13-configuration.md); consult installed help for the full reference.

### Configuration Files

| File | Purpose |
| ------ | --------- |
| `~/.copilot/settings.json` | User settings |
| `~/.copilot/config.json` | Managed state and credentials (do not edit) |
| `~/.copilot/mcp-config.json` | MCP servers |
| `~/.copilot/lsp-config.json` | Language server definitions |
| `.github/lsp.json` | Project language server definitions |
| `~/.copilot/skills/` | Personal skills |
| `~/.agents/skills/` | Personal skill discovery (shared with VS Code) |
| `.github/copilot-instructions.md` | Repository instructions |

### Key Command-Line Flags

| Flag | Description |
| ------ | ------------- |
| `-p, --prompt` | Programmatic mode prompt |
| `-i, --interactive` | Interactive mode with auto-executed prompt |
| `--model` | Select AI model |
| `--continue` | Resume the most recent session |
| `-r, --resume[=value]` | Resume a previous session; with no value it opens the session picker. Optionally accepts an existing session ID, task ID, ID prefix (7+ hex chars), or session name (exact, case-insensitive). |
| `--yolo` / `--allow-all` | Allow all tools, paths, and URLs |
| `--allow-tool` / `--deny-tool` | Allow/deny specific tools |
| `--allow-url` / `--deny-url` | Allow/deny specific URLs |
| `--silent` | Output only agent response (no stats) |
| `--output-format` | Output as `text` or `json` (JSONL) |
| `--share [path]` | Share the session to a markdown file after completion in non-interactive mode (default: `./copilot-session-<id>.md`) |
| `--share-gist` | Share the session to a secret GitHub gist after completion in non-interactive mode |
| `--usage-output-file` | Write final usage statistics as JSON to the specified file |
| `--additional-mcp-config` | Add MCP config as inline JSON or an `@`-prefixed file path |
| `--max-ai-credits` | Set a session AI credit limit |
| `--session-id` | Resume an existing session/task by ID or set a new session UUID |
| `--remote-export` | **Removal candidate:** rejected; use `--sync-session=on` for read-only history |
| `--no-remote` | **Removal candidate:** rejected; use `/remote off` for live control |
| `--no-remote-export` | Accepted but unlisted; runtime semantics unverified. Prefer documented sync control |
| `--sync-session[=on\|off]` | Read-only account-history sync for this run; no incoming control |
| `--enable-memory` | Enable memory in prompt mode |
| `--allow-all-mcp-server-instructions` | Include initialization instructions from all MCP servers |
| `--no-bash-env` | Disable BASH_ENV support |
| `--autopilot` | Enable autonomous multi-step execution |
| `--max-autopilot-continues` | Limit autopilot continuation rounds (default: 5) |
| `--no-ask-user` | Disable agent questions (fully autonomous) |
| `--acp` | Start as Agent Client Protocol server |
| `--stream` | Enable/disable streaming (on/off) |
| `--bash-env` | Source BASH_ENV in shell sessions |
| `--experimental` | Enable experimental features |
| `--mouse [on\|off]` | Enable or disable mouse support in alt screen mode |
| `--no-mouse` | Disable mouse support in alt screen mode |
| `--effort` | Shorthand for `--reasoning-effort` |
| `--secret-env-vars` | Strip named shell/MCP environment variables and mask some outputs; other tool-result routes can still leak secrets to model/history |
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
| `/security-review` | Analyze staged and unstaged changes for security vulnerabilities |
| `/delegate` | Hand off to cloud agent |
| `/fleet` | Launch parallel sub-agents for complex tasks |
| `/autopilot` | Toggle autopilot mode |
| `/after` | Schedule a one-shot prompt or skill |
| `/every` | Schedule a recurring prompt or skill |
| `/limits` | View or edit session limits |
| `/lsp` | Manage language server configuration |
| `/sandbox` | Enable/configure command sandboxing; no experimental prerequisite, host/policy restrictions apply |
| `/settings` | Open the settings UI, or show, set, and unset individual settings |
| `/statusline` | Configure status line items |
| `/subagents` | Configure default and per-agent subagent models |
| `Shift+Tab` | Cycle through chat / plan / autopilot modes |
| `/research` | Launch deep-research workflow with exportable reports |
| `/chronicle` | Session-history insights (standup, search, tips, cost-tips, improve, reindex) — experimental |
| `/diagnose` | Show diagnostic summary of session and environment |
| `/rewind` (alias `/undo`) | Pick an earlier turn and restore conversation only or also Copilot's files; protects subsequent user edits |
| `/copy` | Copy last response to clipboard |
| `/ide` | Connect to IDE workspace |
| `/mcp` | Manage MCP servers |
| `/share html` | Export session as interactive HTML |
| `/allow-all [on\|off\|show]` | Enable, disable, or check allow-all mode |

### Shell Mode Access

| Method | Description |
| -------- | ------------- |
| `!` | Direct access to shell mode |
| `$` | Interactive shell handoff, subject to terminal/policy support |
| `Shift+Tab` | Cycle (chat) → (plan) → (autopilot) |

### Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc

# Quick Copilot start
alias cop='copilot'

# Read/search analysis: exclude shell as well as direct write tools
alias cop-analyze='copilot --available-tools "view,grep,glob" --deny-tool shell --deny-tool write'

# Restricted automation guidance, not enforced filesystem read-only access
alias cop-safe='copilot --allow-tool "shell(cat)" --allow-tool "shell(grep)" --deny-tool write'

# Full autonomy (careful!)
alias cop-yolo='copilot --yolo'

# Resume the most recent session
alias cop-resume='copilot --continue'
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
- ✅ **`--help` output** is the installed command reference; workshop tables are selected examples
- ✅ **`/research` command** for deep-research workflows with exportable reports
- ✅ **Parallel tool execution** is always enabled
- ✅ **`/chronicle` command** (experimental) for session-history insights: standup, search, tips, cost-tips, improve, reindex
- ✅ **`--mouse [on|off]` and `--no-mouse` flags** control mouse support in alt screen mode
- ✅ **`--effort` flag** shorthand for `--reasoning-effort`
- ✅ **Monorepo discovery** is resource-specific; inspect `/env` and applicable instruction scopes
- ✅ **`/diagnose` command** for troubleshooting session and environment issues
- ✅ **`--max-autopilot-continues`** limits autopilot continuation rounds (default: 5)
- ✅ **`--no-ask-user`** enables fully autonomous operation without questions
- ✅ **`--acp`** starts Agent Client Protocol server
- ✅ **`--output-format json`** enables JSONL output for scripting
- ✅ **`--stream`** controls streaming mode
- ✅ **`-i, --interactive`** starts interactive mode with auto-executed prompt
- ✅ **Remote control sessions** via `--remote` or `/remote`
- ✅ **ACP clients** can provide MCP servers when starting/loading sessions
- ✅ **`copilot help monitoring`** documents OpenTelemetry configuration
- ✅ **`copilot help <topic>`** covers billing, commands, config, environment, limits, logging, monitoring, permissions, providers, and sandbox
- ✅ **OpenTelemetry monitoring** — sub-agent INTERNAL spans, `time_to_first_chunk` metric
- ✅ **Session limits** are opt-in via `--max-ai-credits` and `/limits` (soft cap, minimum 30 AI credits)
- ✅ **LSP configuration** defines language servers explicitly in `~/.copilot/lsp-config.json` or `.github/lsp.json`; none run by default
- ✅ **Shell mode access** via `!` command
- ✅ `settings.json` holds user preferences; `lsp-config.json` defines language servers
- ✅ `config.json` is machine-managed and holds credentials — never print or share it
- ✅ Team standardization ensures consistency
- ✅ Performance optimization maximizes productivity

### Sandbox and Automation Safety

`--sandbox` and `/sandbox enable` need no experimental opt-in. Linux needs `bwrap`, usable user/network namespaces, `slirp4netns`, `unshare`/`nsenter`, iptables/ip6tables restore helpers, and `/dev/net/tun`; Docker alone is not proof of support. OS backends constrain shell processes; direct file tools follow policy best-effort, not OS containment. Credential masking substitutes approved-host HTTPS headers, not arbitrary secrets; bypass skips masking. Inspect `copilot sandbox ca --help` before changing CA trust.

`--trust-folder` admits cwd configuration for one new prompt-mode run without saved trust or tool/path/URL approvals. Exact `COPILOT_ALLOW_ALL=true` additionally trusts cwd and can execute loaded hooks; other truthy values only auto-approve tools. Avoid all-permission automation on untrusted content, even in containers with host mounts/tokens.

## Next Steps

→ Continue to [Module 13: Configuration & Environment](13-configuration.md)

## References

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
- [Copilot CLI Blog Posts](https://github.blog/tag/copilot/)
- [GitHub Community Discussions](https://github.com/orgs/community/discussions)
- [agentskills.io](https://agentskills.io/)
