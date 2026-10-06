# Module 2: Operating Modes & Commands

## Prerequisites

- Copilot CLI installed and authenticated (Module 1)
- A project directory to work in

## Learning Objectives

- Understand the difference between interactive and programmatic modes
- Discover and use slash commands (`/command`) for CLI control
- Use `/plan`, `/review`, and `/diff` for structured workflows
- Use the delegate (`/delegate`) command to hand off to cloud agents
- Use built-in agent workflows such as `/research`, `/fleet`, and `/rubber-duck`
- Control tool approval during interactions
- Choose the right mode for different scenarios

## Concepts

### Interactive Mode

Interactive mode starts a conversational session where you chat with Copilot in real-time. It's ideal for:

- Exploratory coding and debugging
- Multi-step tasks requiring iteration
- Learning a new codebase
- Tasks where you want to review each step

```bash
# Start interactive mode
copilot
```

### Interactive-with-Prompt Mode

The `-i` flag starts an interactive session **and** automatically executes a prompt — combining the best of both modes. The session stays open for follow-up after the initial prompt completes.

```bash
# Start interactive mode and auto-execute a prompt
copilot -i "Fix the bug in main.js"
```

This is different from `-p` (which exits after completion). Use `-i` when you want to start with a specific task but continue the conversation.

### Programmatic Mode

Programmatic mode executes a single prompt and exits. Perfect for:
- CI/CD pipelines
- Scripting and automation
- Batch processing
- Single-shot tasks

```bash
# Execute a single prompt (exits after completion)
copilot -p "summarize the README.md file"

# JSON output for scripting
copilot -p "list all TODO comments" --output-format json

# Silent mode — agent response only, no stats
copilot -p "What is 2+2?" -s
```

### Delegate Mode

The `/delegate` command hands off work to GitHub's cloud-based Copilot coding agent. Use it for:
- Long-running tasks
- Compute-intensive operations
- Parallel work (you continue locally while agent works)
- Tasks that benefit from full repository context

```
/delegate implement the user authentication feature based on the spec
```

### Slash Commands

Slash commands are prefixed with `/` and provide quick access to CLI features without leaving the conversation. They are the primary way to control Copilot CLI behavior during an interactive session.

#### Discovering Commands

- Type `/help` to see the full list of available commands
- Press `ctrl+x` then `/` to run a command via keyboard shortcut
- Commands are tab-completable — start typing `/` followed by the first letters

#### Status Bar Hints

> While typing, the status bar shows contextual hints:
> - `@files` and `#issues` hints appear while composing prompts
> - `/help` hint appears when the slash command picker is open
> These hints help new users discover key features without memorizing the full command list.

#### Command Categories

| Category | Commands | Purpose |
| --- | --- | --- |
| **Session** | `/clear`, `/new`, `/session`, `/resume`, `/rename`, `/fork`, `/worktree`, `/move`, `/usage` | Manage session lifecycle |
| **Navigation** | `/cwd`, `/add-dir`, `/list-dirs` | Control directory scope |
| **Context** | `/context`, `/compact` | Monitor and optimize token usage |
| **Quick** | `/ask`, `/refine` | Ask a quick question or clean up a rough prompt |
| **Environment** | `/env` | Show loaded environment details (instructions, MCP servers, skills, agents, hooks, plugins, LSPs, extensions) |
| **Tools** | `/permissions`, `/allow-all`, `/reset-allowed-tools` | Manage tool permissions at runtime |
| **Review** | `/diff`, `/review`, `/rubber-duck`, `/security-review`, `/plan`, `/research`, `/rewind` | Code review, critique, planning, history navigation |
| **Configuration** | `/model`, `/mcp`, `/plugin`, `/theme`, `/statusline`, `/terminal-setup`, `/experimental`, `/instructions`, `/settings`, `/subagents` | Customize CLI behavior |
| **Extensibility** | `/skills`, `/plugin`, `/agent`, `/fleet`, `/delegate` | Manage skills, plugins, agents, parallel execution, and cloud delegation |
| **Scheduling** | `/after`, `/every` | Schedule one-shot or recurring prompts and skills |
| **Sharing** | `/share`, `/share html`, `/feedback`, `/copy` | Export sessions, copy responses, and submit feedback |
| **Account** | `/login`, `/logout`, `/user` | Authentication and user management |
| **IDE** | `/ide` | Connect to IDE workspace |
| **System** | `/help`, `/changelog`, `/exit`, `/init`, `/tasks`, `/lsp`, `/update`, `/restart`, `/version`, `/voice`, `/vim`, `/computer`, `/chronicle`, `/search`, `/keep-alive`, `/limits`, `/diagnose`, `/collect-debug-logs`, `/app` | General utilities and productivity |

> [!NOTE]
> `copilot help commands` does not list every command. The scheduling commands `/after` and `/every` are absent from that listing even though they work in a session, so treat `/help` inside the CLI as the authoritative list.

#### Keyboard Shortcuts

In addition to slash commands, Copilot CLI supports keyboard shortcuts:

| Shortcut | Action |
| --- | --- |
| `@` | Mention files — include file contents in context |
| `#` | Reference GitHub issues, PRs, and discussions |
| `!` | Execute a shell command directly (bypass Copilot; also the only way to access shell mode) |
| `Esc` | Cancel the current operation |
| `Double-Esc` | Clear input when text is present; trigger undo when prompt is empty |
| `ctrl+x → /` | Run a slash command |
| `ctrl+c` | Cancel operation / clear input / exit |
| `ctrl+d` | Exit the CLI on an empty prompt; use `ctrl+q` or `ctrl+enter` to queue a message instead |
| `ctrl+l` | Clear the screen |
| `ctrl+n` | Navigate down (alternative to down arrow) |
| `ctrl+p` | Navigate up (alternative to up arrow) |
| `ctrl+o` | Expand recent timeline (when no input) |
| `ctrl+e` (no input) | Expand all timeline (same as `ctrl+o` — both expand all entries) |
| `ctrl+e` (editing) | Cycle to end of visual/logical line |
| `ctrl+t` | Toggle model reasoning display |
| `ctrl+a` | Cycle to beginning of visual line; repeated press goes to beginning of logical line |
| `ctrl+u` | Delete to beginning of logical line |
| `Alt+D` | Delete word forward in text input |
| `ctrl+y` | Edit plan in terminal editor |
| `ctrl+x → ctrl+e` | Edit prompt in terminal editor |
| `ctrl+z` | Suspend/resume CLI (Unix platforms only) |
| `ctrl+insert` | Copy selected text |
| `ctrl+f` | Page forward |
| `ctrl+b` | Page back |
| `ctrl+g` | Open current prompt in external editor; or dismiss dialog |
| `Home` / `End` | Navigate within visual line; jump to top/bottom of scroll buffer |
| `ctrl+Home` / `ctrl+End` | Jump to text boundaries |
| `Shift+Tab` | Cycle through modes — (chat) → (plan) → (autopilot) |
| `Shift+Enter` | Insert newline in prompt (requires kitty keyboard protocol) |
| `Page Up` / `Page Down` | Scroll |
| `Double-click` | Select word |
| `Triple-click` | Select line |

> [!WARNING]
> Some keyboard shortcuts require specific terminal capabilities:
> - **Shift+Enter** for newlines requires terminals with kitty keyboard protocol support
> - **Ctrl+Z** suspend/resume works on Unix platforms only
> - **Ctrl+Y**, **Ctrl+X Ctrl+E**, and **Ctrl+G** require a terminal editor (set via `$COPILOT_EDITOR`, `$VISUAL`, or `$EDITOR`)
> - Use `--screen-reader` to enable screen reader optimizations for accessible output

#### Branch Indicator

The CLI header displays a branch indicator with change status symbols:

| Symbol | Meaning |
| --- | --- |
| `*` | Unstaged changes |
| `+` | Staged changes |
| `%` | Untracked files |

Example: `main*+%` means you're on `main` with unstaged, staged, and untracked changes.

#### Key Commands Not Covered in Other Modules

Some commands are covered in depth in later modules (`/mcp` in Module 5, `/skills` in Module 6, `/plugin` in Module 7, `/context` and `/compact` in Module 10). The following important commands are unique to this section:

| Command | Description |
| --- | --- |
| `/plan [prompt]` | Ask Copilot to create an implementation plan before writing code |
| `/review [prompt]` | Run a code review agent to analyze changes |
| `/rubber-duck [prompt]` | Get high-signal critique of a plan, design, or implementation |
| `/diff` | Review all changes with syntax highlighting (17 languages); supports Home/End and Page Up/PageDown navigation |
| `/init` | Initialize Copilot instructions and agentic features for a repository |
| `/tasks` | View and manage background tasks (subagents, shell sessions) |
| `/rename <name>` | Rename the current session for easy identification; omit name to auto-generate from conversation history |
| `/settings theme <value>` | Set the color theme (`default`, `github`, `dim`, `high-contrast`, `colorblind`); `/theme` with no argument opens the theme picker |
| `/statusline` | Configure which items appear in the status line (for example `quota` and `ai-used`) |
| `/terminal-setup` | Configure terminal for multiline input support (shift+enter) |
| `/lsp` | Manage language server configuration — view and configure Language Server Protocol servers |
| `/user [show\|list\|switch]` | Manage GitHub user list (multi-account support) |
| `/update` | Update the CLI |
| `/research [prompt]` | Perform deep research with exportable reports |
| `/chronicle [standup\|search\|tips\|cost-tips\|improve\|reindex]` | ⚠️ **Experimental** — Productivity insights powered by session history |
| `/copy` | Copy the last response to the system clipboard |
| `/ide` | Connect to an IDE workspace (VS Code, etc.) for diagnostics and diff review |
| `/restart` | Hot restart the CLI while preserving your session |
| `/version` | Display CLI version and check for updates |
| `/voice` | Manage voice mode — dictation transcription via Foundry Local |
| `/rewind` (alias `/undo`) | Rewind the last turn and revert file changes; also available via double-Esc |
| `/fork [name]` | Fork the current session into a new session, optionally with a name; `/fork worktree` forks into a new worktree based on the current branch |
| `/worktree` | Create a new git worktree from your configured base ref and switch into it, leaving uncommitted changes behind (`/new worktree` for an empty session) |
| `/move [branch-or-task]` | Move your uncommitted changes into a new git worktree and switch into it; omit the argument to auto-name it |
| `/vim` | Toggle Vim mode for the prompt input (motions, operators, counts, `esc` for normal mode) |
| `/computer` | Show or toggle Computer Use |
| `/collect-debug-logs` | Collect debug logs to a local `.tgz` file or a secret GitHub gist |
| `/refine` | Rewrite a rough, stream-of-consciousness prompt into a clear one for review (`ctrl+x → /` then `/refine` cleans up your current input) |
| `/permissions [manual\|assisted\|allow-all\|show]` | Switch between permission modes, or show the current permission status |
| `/changelog [summarize]` | Display the changelog for CLI releases; add `summarize` for an AI summary |
| `/new [prompt]` | Start a fresh conversation (keeps old session backgrounded); optionally provide a first message |
| `/clear [prompt]` | Abandon the current session entirely; optionally provide a first message for the new session |
| `/allow-all [on\|off\|show]` | Enable, disable, or check allow-all (YOLO) mode |
| `/share html` | Export session as a self-contained interactive HTML file |
| `/keep-alive [on\|off\|busy]` | Manage keep-alive mode — prevents system sleep while session is active |
| `/search` | Search the conversation timeline |
| `/limits` | View or edit session limits, including AI credit limits (see [Session Limits](#session-limits) below) |
| `/memory [on\|off]` | Show or change cross-session memory status |
| `/pr` | Operate on pull requests for the current branch |
| `/subagents` | Configure default and per-agent subagent models |
| `/after <delay> <prompt>` | Schedule a one-shot prompt or skill to run later |
| `/every <interval> <prompt>` | Schedule a recurring prompt or skill |

#### Command Aliases

Many commands accept a shorter or more familiar alias. Both forms behave identically:

| Command | Alias | Command | Alias |
| --- | --- | --- | --- |
| `/allow-all` | `/yolo` | `/resume` | `/continue` |
| `/ask` | `/btw` | `/rewind` | `/undo` |
| `/changelog` | `/release-notes` | `/search` | `/find` |
| `/clear` | `/reset` | `/session` | `/sessions` |
| `/cwd` | `/cd` | `/settings` | `/config` |
| `/every` | `/loop` | `/share` | `/export` |
| `/exit` | `/quit` | `/skills` | `/skill` |
| `/feedback` | `/bug` | `/statusline` | `/footer` |
| `/fork` | `/branch` | `/subagents` | `/agents` |
| `/keep-alive` | `/caffeinate` | `/update` | `/upgrade` |
| `/model` | `/models` | | |

#### Session Limits

Session limits are opt-in and cap how many AI credits a session may consume. Usage accumulates across the whole session in both interactive and non-interactive runs, and subagents share the parent session's limit.

Set an initial limit at launch:

```bash
copilot --max-ai-credits 30
```

Manage limits from inside a session:

| Command | Description |
| --- | --- |
| `/limits` | Open the interactive limits dialog for the current session |
| `/limits set max-ai-credits <credits>` | Set the AI credit limit (minimum 30) |
| `/limits unset [max-ai-credits\|all]` | Remove a specific limit, or all limits |

> [!NOTE]
> The AI credit limit is a **soft cap**. Usage is known only after a model response returns, so a single response can exceed the limit before the CLI observes it — the *next* model call is then blocked. Hidden model work such as compaction also counts toward the limit. In interactive sessions, `/clear` starts a fresh accounting window: used credits reset while the configured limit stays in effect.
>
> Run `copilot help limits` and `copilot help billing` from your shell for the full reference on limits and AI credit usage.

#### Commands Available During Agent Work

| Command | Description |
| --- | --- |
| `/ask [prompt]` | Ask a quick question without affecting conversation history — response is not added to context |
| `/env` | Show loaded environment details — lists active instructions, MCP servers, skills, agents, hooks, plugins, LSPs, and extensions |
| `/remote` | Start or manage a remote control session |
| `/diff`, `/agent`, `/feedback`, `/ide` | These commands work while the agent is running — no need to wait for completion |

#### Startup Flags

| Flag | Description |
| --- | --- |
| `--mode <mode>` | Start CLI directly in a specific mode (`interactive`, `plan`, `autopilot`) |
| `--autopilot` | Start CLI directly in autopilot mode |
| `--plan` | Start CLI directly in plan mode |
| `--agent <agent>` | Start with a specific agent, such as `rubber-duck` for high-signal critique |
| `-n, --name <name>` | Set a name for the new session |
| `--session-id <id>` | Resume an existing session or task by ID, or set the UUID for a new session |
| `-C <directory>` | Change working directory before doing anything else |
| `--context <tier>` | Set the context window tier, overriding the persisted setting (`default`, `long_context`) |
| `--effort, --reasoning-effort <level>` | Set the reasoning effort level (`none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`) |
| `--max-ai-credits <credits>` | Set the max AI credits for this session (minimum 30) |
| `--max-autopilot-continues <count>` | Maximum number of continuation messages in autopilot mode (default: 5) |
| `--experimental` / `--no-experimental` | Enable or disable experimental features |
| `--connect[=sessionId]` | Connect directly to a remote session (optionally specify session ID or task ID) |
| `--remote` | Enable remote control of your session from GitHub web and mobile |
| `--enable-reasoning-summaries` | Request reasoning summaries for OpenAI models |
| `--acp` | Start as an Agent Client Protocol server |

> Run `copilot --help` for the complete list of flags, or see [Module 13](13-configuration.md#cli-flags-quick-reference) for the full flag reference.

#### Rubber-Duck Feedback Mode

Use the `rubber-duck` agent when you want focused critique of a plan, design, or implementation:

```
/rubber-duck Review this implementation plan for logic errors and missed edge cases
```

You can also start a session directly with the same agent:

```bash
copilot --agent rubber-duck
```

> [!NOTE]
> Built-in agents such as `rubber-duck` are designed for interactive sessions. Pairing `--agent` with a non-interactive `-p` run fails outright rather than degrading, so start an interactive session when you want this behavior. Custom agents you define in the repository do work with `-p`.

The rubber-duck agent looks for bugs, logic errors, and design flaws without turning the session into a broad style review.

#### Security Review Mode

Use `/security-review` when you want Copilot to analyze staged and unstaged changes for security vulnerabilities:

```
/security-review Check these changes for exploitable security issues
```

Use it before opening a pull request or after making authentication, authorization, dependency, input-handling, or secrets-related changes.

The security review focuses on high-confidence security findings rather than general code style.

> `/research` and `/chronicle` are experimental. `/chronicle` subcommands (`standup`, `search`, `tips`, `cost-tips`, `improve`, `reindex`) and behavior are subject to change.

> **Remote control** lets you observe and control sessions remotely. Use the `--remote` flag or `/remote` command to start a remote control session, allowing another Copilot CLI instance to connect.

> **Tip:** Run `copilot help commands` from your shell to see the full interactive command list without starting a session. A few commands are not included in that listing — the scheduling commands `/after` and `/every` are the notable ones, so use `/help` inside a session to confirm what is available.

## Hands-On Exercises

> [!NOTE]
> **Authentication Required:** You must authenticate before running these exercises. Complete Module 1 (authentication setup) or set one of these environment variables: `GITHUB_TOKEN`, `GH_TOKEN`, or `COPILOT_GITHUB_TOKEN`.

### Exercise 1: Discovering Slash Commands

**Goal:** Learn to discover and use slash commands inside an interactive session.

**Steps:**

1. Start Copilot CLI:
 ```bash
 copilot
 ```

2. View all available commands:
 ```
 /help
 ```

3. Review the output — you'll see commands grouped with descriptions.

4. Open the theme picker to see available themes:
 ```
 /theme
 ```

5. Apply a theme by name:
 ```
 /settings theme dim
 ```

6. Check your current working directory:
 ```
 /cwd
 ```

7. View session usage metrics:
 ```
 /usage
 ```

8. Exit with `/exit`.

**Expected Outcome:**
You can discover and navigate the full set of slash commands using `/help`.

### Exercise 2: Planning and Reviewing with Commands

**Goal:** Use `/plan`, `/review`, and `/diff` for structured development workflows.

**Steps:**

1. Navigate to a project directory and start Copilot:
 ```bash
 mkdir -p ~/copilot-commands-lab && cd ~/copilot-commands-lab
 git init
 copilot
 ```

2. Use `/plan` to create an implementation plan before coding:
 ```
 /plan Build a simple REST API with Express.js that has CRUD endpoints for a todo list
 ```

3. Copilot creates a structured plan. Review it before proceeding.

4. Ask Copilot to implement the plan:
 ```
 Go ahead and implement the plan
 ```

5. After files are created, review all changes made:
 ```
 /diff
 ```

6. Run a code review on the changes:
 ```
 /review Check for security issues and missing error handling
 ```

7. Exit with `/exit`.

**Expected Outcome:**
You can use `/plan` for structured implementation, `/diff` to review changes, and `/review` for code analysis.

### Exercise 3: Repository Initialization and Session Management Commands

**Goal:** Use `/init` to bootstrap Copilot configuration and `/rename` to organize sessions.

**Steps:**

1. Create a new project directory:
 ```bash
 mkdir -p ~/copilot-init-lab && cd ~/copilot-init-lab
 git init
 copilot
 ```

2. Initialize Copilot configuration for this repository:
 ```
 /init
 ```

3. This generates `.github/copilot-instructions.md` with repository guidance.

4. Rename this session for easy identification:
 ```
 /rename init-lab-session
 ```

5. Check session details:
 ```
 /session
 ```

6. View background tasks (if any):
 ```
 /tasks
 ```

7. Configure terminal for multiline input:
 ```
 /terminal-setup
 ```

8. Exit with `/exit`.

**Expected Outcome:**
You can bootstrap Copilot configuration with `/init`, rename sessions, and configure terminal features.

### Exercise 4: Interactive Mode Basics

**Goal:** Start an interactive session and perform basic operations.

**Steps:**

1. Navigate to a project directory:
 ```bash
 mkdir -p ~/copilot-workshop && cd ~/copilot-workshop
 git init
 ```

2. Start Copilot CLI:
 ```bash
 copilot
 ```

3. Ask Copilot to create a file:
 ```
 Create a Python script named `hello.py` that prints "Hello, Copilot!"
 ```

 > [!TIP]
 > Specifying the exact filename in prompts ensures consistent results across workshop participants. Without it, Copilot may generate different filenames each time (e.g., `hello_copilot.py`, `hello_python.py`).

4. When prompted to approve the file write, select **Yes**.

5. Ask a follow-up question:
 ```
 Now modify it to accept a name as a command-line argument
 ```

6. Continue the conversation:
 ```
 Add error handling if no argument is provided
 ```

7. Exit with `/exit` or `Ctrl+C`.

**Expected Outcome:**
A Python script evolves through multiple iterations with your guidance.

### Exercise 5: Tool Approval Workflow

**Goal:** Understand how to approve, deny, and manage tool permissions.

**Steps:**

1. Start a new session:
 ```bash
 copilot
 ```

2. Ask Copilot to run a command:
 ```
 List all files in the current directory with details
 ```

3. Copilot will request to use the `shell` tool. You'll see three options:
 - **Yes** - Allow this time only
 - **Yes, and approve TOOL for the rest of the session** - Session-wide approval
 - **No, and tell Copilot what to do differently** - Deny and redirect

4. Select **Yes** (first option) to allow once.

5. Now ask:
 ```
 Display the contents of hello.py using the cat command
 ```

 > [!TIP]
 > Avoid prompts that reference a specific number of lines (e.g., "first 10 lines") for short files — Copilot may reason about the file length instead of running the expected command.

6. Copilot asks for shell permission again (since you only approved once).

7. This time select **Yes, and approve shell for the rest of the session**.

8. Ask another command:
 ```
 Count the lines in hello.py
 ```

9. Notice Copilot doesn't ask for permission this time.

**Expected Outcome:**
You understand the difference between one-time and session-wide tool approval.

### Exercise 6: Programmatic Mode

**Goal:** Execute single commands without entering interactive mode.

**Steps:**

1. Create a test file:
 ```bash
 echo "# My Project" > README.md
 echo "This is a test project for learning Copilot CLI." >> README.md
 ```

2. Run Copilot in programmatic mode:
 ```bash
 copilot -p "What does the README.md contain?"
 ```

3. Try with tool permissions:
 ```bash
 copilot -p "Add a 'Getting Started' section to README.md" --allow-tool 'write'
 ```

4. Combine multiple tool permissions:
 ```bash
 copilot -p "Run git status and explain what it means" --allow-tool 'shell(git status)'
 ```

 > [!NOTE]
 > Shell approval matches on the first-level subcommand, so `shell(git status)` allows exactly `git status`. Use `shell(git:*)` when you want to allow every `git` subcommand.

5. Pipe file content as context:
 ```bash
 cat README.md | copilot -p "Explain what this file contains"
 ```

 > [!TIP]
 > When piping content to Copilot, use prompts that reference "this content" or "this file" rather than "this output" to avoid Copilot responding with "I don't see any output to explain."

**Expected Outcome:**
Commands execute and exit without entering interactive mode.

### Exercise 7: Chaining Prompts

**Goal:** Use programmatic mode in shell scripts.

**Steps:**

1. Create a script `analyze.sh`:
 ```bash
 cat > analyze.sh << 'EOF'
 #!/bin/bash

 echo "=== Project Analysis ==="

 # Get file count
 copilot -p "Count all .py files recursively and report" --allow-tool 'shell'

 echo ""
 echo "=== Code Quality Check ==="

 # Check for issues
 copilot -p "Look for any TODO comments in Python files" --allow-tool 'shell'
 EOF
 ```

2. Make it executable:
 ```bash
 chmod +x analyze.sh
 ```

3. Run the script:
 ```bash
 ./analyze.sh
 ```

**Expected Outcome:**
Multiple Copilot operations run sequentially in a script.

### Exercise 8: Delegate to Cloud Agent

**Goal:** Hand off a task to the cloud-based Copilot coding agent.

**Steps:**

1. Ensure you have a GitHub repository (local work pushed to GitHub).

2. Start interactive mode:
 ```bash
 copilot
 ```

3. Build some context by exploring:
 ```
 What files are in this project?
 ```

4. Use delegate to hand off a task:
 ```
 /delegate create comprehensive unit tests for all Python files in this project
 ```

5. Copilot will:
 - Ask you to commit any unstaged changes
 - Create a new branch
 - Open a draft pull request
 - Start working asynchronously

6. You'll receive a link to track progress.

7. Continue working locally while the agent works in the cloud.

**Expected Outcome:**
A draft PR is created and the cloud agent begins working asynchronously.

### Exercise 9: Comparing Modes

**Goal:** Understand when to use each mode.

**Steps:**

1. **Interactive exploration** - Start a session:
 ```bash
 copilot
 ```

 Then explore from inside the session:
 ```
 Explain the structure of this codebase
 What does the main function do?
 How would I add a new feature?
 /exit
 ```

2. **Programmatic for automation** - Single focused tasks:
 ```bash
 # Good for CI/CD
 copilot -p "Run all tests and report failures" --allow-tool 'shell'

 # Good for git workflows
 copilot -p "Summarize changes since last tag" --allow-tool 'shell(git:*)'
 ```

3. **Delegate for heavy lifting** - Long-running tasks:
 ```
 /delegate refactor the authentication module to use JWT tokens
 ```

**Decision Guide:**

| Scenario | Recommended Mode |
| --- | --- |
| Learning a new codebase | Interactive |
| Debugging an issue | Interactive |
| CI/CD pipeline task | Programmatic |
| Summarize changes | Programmatic |
| Major refactoring | Delegate |
| Implement new feature | Delegate |
| Quick code review | Interactive |

**Expected Outcome:**
You can choose the appropriate mode for any task.

## Tool Approval Reference

### Approval Options Explained

| Option | Behavior | Risk Level |
| --- | --- | --- |
| Yes | Allow this one time | Low - Full control |
| Yes, for session | Allow all similar for session | Medium - Review first use |
| No | Deny and redirect | None - Maximum safety |

### Dangerous Commands to Watch

⚠️ **Be careful approving session-wide permissions for:**

- `rm` - File deletion
- `chmod` - Permission changes
- `git push` - Pushing to remote
- `sudo` - Elevated privileges
- Network commands - Data exfiltration risk

### Safe Commands for Session Approval

✅ **Generally safe for session-wide approval:**

- `ls`, `cat`, `head`, `tail` - Read-only
- `git status`, `git log`, `git diff` - Read-only git
- `pwd`, `echo` - Environment queries
- Linters and formatters - Analysis only

## Summary

- ✅ **Interactive mode** - Conversational, multi-step, exploratory
- ✅ **Programmatic mode** - Single prompt, scriptable, CI/CD friendly
- ✅ **Delegate mode** - Hands off to cloud agent for heavy tasks
- ✅ **Slash commands** - `/plan`, `/review`, `/diff`, `/research`, `/init`, and 30+ others for CLI control
- ✅ **Keyboard shortcuts** - `@` for files, `#` for issues/PRs, `!` for shell, `ctrl+x → /` for commands
- ✅ Tool approval has one-time and session-wide options
- ✅ Be cautious with session-wide approval for destructive commands
- ✅ `/restart` hot restarts the CLI while preserving your session
- ✅ `/ask` asks a quick question without affecting conversation history
- ✅ `/env` shows loaded environment details
- ✅ `--mode`, `--autopilot`, `--plan` flags start CLI in a specific mode
- ✅ `/rubber-duck` starts a critique-focused feedback turn inside an interactive session
- ✅ `--agent rubber-duck` starts a critique-focused interactive session
- ✅ `/after` and `/every` schedule one-shot and recurring prompts, and are not listed by `copilot help commands`
- ✅ `/rewind` (alias `/undo`, or double-Esc) rewinds the last turn and reverts file changes
- ✅ `/permissions` switches between `manual`, `assisted`, and `allow-all` permission modes
- ✅ `/fork` branches the current session into a new one
- ✅ `/refine` rewrites a rough prompt into a clear one for review
- ✅ `/settings theme <value>` sets the color theme; `/theme` opens the theme picker
- ✅ `/limits` manages opt-in AI credit limits — a soft cap, minimum 30 credits
- ✅ Most commands have aliases, such as `/yolo` for `/allow-all` and `/cd` for `/cwd`
- ✅ `--remote` and `/remote` for remote control sessions
- ✅ `/diff`, `/agent`, `/feedback`, and `/ide` work while agent is running
- ✅ `Alt+D` deletes word forward in text input
- ✅ `ctrl+o` expands all timeline entries (same as `ctrl+e`)
- ✅ `Ctrl+L` clears terminal screen without clearing session
- ✅ Status bar shows `@files`, `#issues`, and `/help` hints while typing
- ✅ Branch indicator shows unstaged (*), staged (+), and untracked (%) status

## Next Steps

→ Continue to [Module 3: Custom Instructions](03-instructions.md)

## References

- [Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
- [Copilot Coding Agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent)
