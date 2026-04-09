# Module 4: Tools & Permissions

## Prerequisites

- Completed Modules 1-4
- Understanding of command-line security concepts
- A test directory for safe experimentation

## Learning Objectives

- Understand Copilot CLI's built-in tools
- Master the permission approval workflow
- Use `--allow-tool` and `--deny-tool` flags effectively
- Understand `--yolo` mode and when to use it safely
- Configure trusted directories

## Concepts

### Built-in Tools

Copilot CLI includes several built-in tools:

| Tool | Purpose | Risk Level |
|------|---------|------------|
| `shell` | Execute shell commands | ⚠️ High |
| `write` | Create/modify files | ⚠️ High |
| `read` | Read file contents | Low |
| `show_file` | Present code/diffs to user in a prominent view | Low |
| `web_fetch` | Fetch web content | Medium |
| `mcp` | Use MCP server tools | Varies |

### Permission Model

Every potentially destructive action requires approval:

```
┌─────────────┐ ┌──────────────┐ ┌─────────────┐
│ Copilot │────▶│ Permission │────▶│ Execute │
│ wants to │ │ Prompt │ │ Action │
│ use tool │ │ │ │ │
└─────────────┘ └──────────────┘ └─────────────┘
 │
 ▼
 ┌──────────────┐
 │ User │
 │ Decides │
 └──────────────┘
```

### Approval Levels

1. **One-time** - Approve this specific invocation only
2. **Session-wide** - Approve this tool for the entire session
3. **Deny** - Reject and provide alternative guidance

> ⚠️ **FEEDBACK** — Undo operations now always require user confirmation before applying — they no longer auto-apply. This safety improvement prevents accidental reversions.

### Path Permission Approval

> Since v1.0.4, the path permission dialog offers a **one-time approval** option in addition to permanently adding the path to the allowed list. This lets you grant access for the current session without modifying your persistent configuration.

### Tool Search

> Since v1.0.6, Claude models can **discover and use tools dynamically** with tool search. The model can find relevant tools without you explicitly specifying them, reducing the need for manual `--allow-tool` flags in some workflows.

## Hands-On Exercises

### Exercise 1: Understanding Tool Prompts

**Goal:** Learn to read and respond to tool approval prompts.

**Steps:**

1. Create a test directory:
 ```bash
 mkdir -p ~/copilot-tools-lab && cd ~/copilot-tools-lab
 git init
 ```

2. Start Copilot:
 ```bash
 copilot
 ```

3. Request a file operation:
 ```
 Create a file called test.txt with "Hello World"
 ```

4. Observe the tool approval prompt. It shows:
 - Tool name: `write`
 - File path: `test.txt`
 - Content preview
 - Three approval options

5. Select **Yes** (one-time approval).

6. Now request another file:
 ```
 Create another file called test2.txt
 ```

7. Notice you're prompted again (one-time didn't persist).

8. This time select **Yes, and approve write for the rest of the session**.

9. Request a third file:
 ```
 Create test3.txt
 ```

10. No prompt this time - session approval persists.

11. To reset all approved tools for the session, use:
 ```
 /reset-allowed-tools
 ```

12. Now request another file operation:
 ```
 Create test4.txt
 ```

13. Notice you're prompted again - the reset cleared all session approvals.

**Expected Outcome:**
You understand the difference between one-time and session-wide approval, and can reset session approvals when needed.

### Exercise 2: Shell Command Approval

**Goal:** Safely approve shell commands with granular control.

**Steps:**

1. In the same session:
 ```
 List all files in the current directory
 ```

2. If Copilot requests `shell(ls)`, approve for session.
 > Note: In some managed environments, `ls` may already be allowed and run without a prompt.

3. Now try:
 ```
 Show me the disk usage of this directory
 ```

4. If prompted, Copilot requests `shell(du)`. This is a different command.

5. Approve `du` for session as well (if prompted).

6. Request something more dangerous:
 ```
 Delete the test.txt file
 ```

7. Copilot requests `shell(rm)` (or blocks it by policy). **Select No** and explain:
 ```
 I don't want to delete files right now. Just show me what would be deleted.
 ```

8. Copilot adjusts its approach without executing `rm` (or reports that `rm` is blocked).

**Expected Outcome:**
Low-risk shell commands may already be pre-approved in some environments, while dangerous commands are still handled separately (prompted or blocked) by command name.

### Exercise 3: Using --allow-tool Flag

**Goal:** Pre-approve tools for programmatic mode.

**Steps:**

1. Exit the interactive session.

2. Run with specific tool allowance:
 ```bash
 copilot -p "Show me all .txt files" --allow-tool 'shell(ls)'
 ```

3. Allow multiple read-only commands:
 ```bash
 copilot -p "Show git status and recent commits" \
 --allow-tool 'shell(git status)' \
 --allow-tool 'shell(git log)'
 ```

4. Allow all shell commands (be careful!):
 ```bash
 copilot -p "Analyze this directory structure" --allow-tool 'shell'
 ```

5. Allow file writing:
 ```bash
 copilot -p "Create a README.md with project description" --allow-tool 'write'
 ```

**Expected Outcome:**
Commands execute without interactive prompts.

### Exercise 4: Using --deny-tool Flag

**Goal:** Explicitly block dangerous operations.

**Steps:**

1. Allow all tools but block dangerous ones:
 ```bash
 copilot -p "Help me clean up this project" \
 --allow-all-tools \
 --deny-tool 'shell(rm)' \
 --deny-tool 'shell(rm -rf)'
 ```

2. Block git push while allowing other git:
 ```bash
 copilot -p "Commit these changes with a good message" \
 --allow-tool 'shell(git:*)' \
 --deny-tool 'shell(git push)'
 ```

3. Block file modifications:
 ```bash
 copilot -p "Review this codebase" \
 --allow-tool 'shell' \
 --deny-tool 'write'
 ```

4. Create a safe analysis mode:
 ```bash
 copilot -p "Analyze security issues" \
 --allow-tool 'shell(cat)' \
 --allow-tool 'shell(grep)' \
 --allow-tool 'shell(find)' \
 --deny-tool 'shell(rm)' \
 --deny-tool 'shell(mv)' \
 --deny-tool 'write'
 ```

**Expected Outcome:**
Deny rules take precedence over allow rules.

### Exercise 5: YOLO Mode (Careful!)

**Goal:** Understand fully autonomous execution.

**Steps:**

⚠️ **WARNING:** Only use `--yolo` in safe, isolated environments!

1. Create an isolated test directory:
 ```bash
 mkdir -p ~/yolo-test && cd ~/yolo-test
 echo "test content" > safe-file.txt
 ```

2. Run with yolo mode on a safe task:
 ```bash
 copilot --yolo -p "Create a Python hello world script"
 ```

3. Notice: No prompts, file created directly.

4. More complex autonomous task:
 ```bash
 copilot --yolo -p "Create a Node.js project with package.json and a simple server"
 ```

5. Review what was created:
 ```bash
 ls -la
 cat package.json
 ```

**When to Use YOLO:**
- ✅ Inside Docker containers
- ✅ Disposable dev environments
- ✅ CI/CD pipelines with controlled scope
- ✅ Codespaces that can be reset

**When NOT to Use YOLO:**
- ❌ Production systems
- ❌ Directories with important data
- ❌ Shared development environments
- ❌ When untrusted input is involved

**Expected Outcome:**
You understand YOLO mode's power and risks.

> [!TIP]
> Inside an interactive session, use `/allow-all on` to enable, `/allow-all off` to disable, or `/allow-all show` to check the current allow-all mode status.

### Exercise 6: Configuring Trusted and Accessible Directories

**Goal:** Understand the two separate directory permission layers in Copilot CLI.

> **Key concept:** Copilot CLI has two distinct directory controls:
>
> | Layer | Purpose | Scope |
> |---|---|---|
> | **Startup trust** (`trustedFolders`) | Skips the "do you trust this folder?" prompt when launching Copilot | Launch-time only |
> | **Runtime access** (`/add-dir`, `--allow-path`) | Controls which paths the agent can read/write during a session | Session-time only |
>
> These are **independent** — trusting a folder does **not** grant runtime file access to it, and vice versa.

#### Part A: Startup Trust

1. Start Copilot in a new directory:
 ```bash
 mkdir -p ~/trusted-test && cd ~/trusted-test
 copilot
 ```

2. When prompted about trusting the folder:
 - **Yes, proceed** — Trust for this session only
 - **Yes, and remember** — Permanently add to `trustedFolders`
 - **No, exit** — Don't trust

3. Select **Yes, proceed** for now.

4. In a side terminal, check the config:
 ```bash
 cat ~/.copilot/config.json
 ```
 Notice that `trustedFolders` was **not** updated (you chose session-only trust).

5. To permanently skip the prompt for specific directories, add them to your config:
 ```bash
 # Edit config.json to add:
 {
 "trustedFolders": [
 "/home/user/projects",
 "/home/user/copilot-workshop"
 ]
 }
 ```
 Next time you launch Copilot from those directories, it won't ask for trust confirmation.

#### Part B: Runtime File Access

6. Back in your Copilot session, check which paths the agent can access:
 ```
 /list-dirs
 ```
 You'll see only the **working directory** and `/tmp` — not the `trustedFolders` entries.

7. Grant runtime access to an additional directory:
 > Note: Create the directory first (e.g., `mkdir -p /tmp/safe-dir`).
 ```
 /add-dir /tmp/safe-dir
 ```

8. Verify with `/list-dirs` — the new path now appears.

9. To grant runtime access at launch instead, use the `--allow-path` flag:
 ```bash
 copilot --allow-path /home/user/projects --allow-path /home/user/copilot-workshop
 ```

**Expected Outcome:**
You understand that `trustedFolders` controls the **startup trust prompt**, while `/add-dir`, `/list-dirs`, and `--allow-path` control **runtime file access** — and that these are two independent permission layers.

### Exercise 7: Creating a Safe Automation Script

**Goal:** Build a secure automated workflow.

**Steps:**

1. Create a script `analyze-project.sh`:
 ```bash
 #!/bin/bash
 set -e

 PROJECT_DIR="${1:-.}"

 echo "🔍 Analyzing project in: $PROJECT_DIR"
 echo "=================================="

 # Safe analysis - read-only operations only
 copilot -p "Analyze the code quality and suggest improvements" \
 --allow-tool 'shell(find)' \
 --allow-tool 'shell(wc)' \
 --allow-tool 'shell(grep)' \
 --allow-tool 'shell(cat)' \
 --allow-tool 'shell(head)' \
 --allow-tool 'shell(tail)' \
 --deny-tool 'write' \
 --deny-tool 'shell(rm)' \
 --deny-tool 'shell(mv)' \
 --deny-tool 'shell(chmod)' \
 --silent
 ```

2. Create a code review script:
 ```bash
 #!/bin/bash

 # Review changes but don't modify anything
 copilot -p "Review the git diff and provide feedback" \
 --allow-tool 'shell(git diff)' \
 --allow-tool 'shell(git log)' \
 --allow-tool 'shell(git status)' \
 --deny-tool 'shell(git push)' \
 --deny-tool 'shell(git commit)' \
 --deny-tool 'write'
 ```

3. Make executable and test:
 ```bash
 chmod +x analyze-project.sh
 ./analyze-project.sh
 ```

**Expected Outcome:**
Safe, repeatable automation with explicit permissions.

## Tool Permission Reference

### Allow/Deny Syntax

```bash
# Allow specific command
--allow-tool 'shell(git status)'

# Allow command family
--allow-tool 'shell(git:*)'

# Allow all shell
--allow-tool 'shell'

# Allow file writes
--allow-tool 'write'

# Allow MCP server
--allow-tool 'mcp-server-name'

# Allow specific MCP tool
--allow-tool 'MyMCP(my_tool)'

# URL access matching
--allow-tool 'url(https://github.com)'
--allow-tool 'url(https://*.github.com)'

# Deny takes precedence
--allow-all-tools --deny-tool 'shell(rm)'
```

### URL Permissions

Copilot CLI provides granular URL access control. All URL permissions are protocol-aware — approving `https://example.com` does NOT allow `http://example.com`.

```bash
# Allow access to a specific domain (defaults to HTTPS)
copilot --allow-url github.com

# Allow HTTP access explicitly
copilot --allow-url http://localhost:3000

# Deny access to a specific domain (takes precedence over allow)
copilot --deny-url https://malicious-site.com

# Allow all URLs without confirmation
copilot --allow-all-urls
```

URL permissions can also be set via the `url` pattern in `--allow-tool`/`--deny-tool`:

```bash
# Allow URL access via tool permission pattern
copilot --allow-tool 'url(https://api.github.com)'
copilot --deny-tool 'url(http://example.com)'
```

### Path Permissions

By default, file access is restricted to the current working directory and subdirectories, plus the system temp directory. Additional controls:

```bash
# Allow access to any path on the filesystem
copilot --allow-all-paths

# Add additional directories
copilot --add-dir ~/other-project --add-dir /tmp/data

# Prevent automatic access to the system temp directory
copilot --disallow-temp-dir
```

### Secret Environment Variables

Strip sensitive environment variable values from shell/MCP server environments and redact them from output:

```bash
copilot --secret-env-vars MY_API_KEY DATABASE_PASSWORD
```

### Autonomous Mode (No User Questions)

Disable the `ask_user` tool so the agent works autonomously without asking questions. Useful for CI/CD pipelines where no human is available to respond:

```bash
copilot -p "Fix all linting errors" --allow-all-tools --no-ask-user
```

### Risk Categories

| Category | Commands | Recommendation |
|----------|----------|----------------|
| Read-only | `ls`, `cat`, `grep`, `find` | Safe for session |
| Git read | `git status`, `git log`, `git diff` | Safe for session |
| Git write | `git commit`, `git push` | One-time only |
| File modify | `touch`, `echo >`, `sed -i` | Review each use |
| File delete | `rm`, `rm -rf` | Always one-time |
| System | `chmod`, `chown`, `sudo` | Deny in automation |

### Shorthand Flags

| Flag | Equivalent |
|------|------------|
| `--yolo` | `--allow-all-tools --allow-all-paths --allow-all-urls` |
| `--allow-all` | Same as `--yolo` |
| `--allow-url` | Allow specific URLs/domains |
| `--deny-url` | Deny specific URLs/domains (takes precedence) |
| `--allow-all-urls` | Allow all URLs without confirmation |
| `--allow-all-paths` | Disable file path verification |
| `--disallow-temp-dir` | Revoke auto-access to system temp directory |
| `--available-tools` | Allowlist specific tools |
| `--excluded-tools` | Denylist specific tools |
| `--secret-env-vars` | Redact env var values from output |
| `--no-ask-user` | Disable agent questions (fully autonomous) |

### Runtime Slash Commands

| Command | Description |
|---------|-------------|
| `/reset-allowed-tools` | Reset the list of tools approved during the session |
| `/add-dir <path>` | Add a trusted directory for the session |
| `/list-dirs` | View accessible directories |

## Summary

- ✅ Copilot requires approval for high-risk actions; some low-risk tools may be pre-approved by environment policy
- ✅ One-time vs session-wide approval gives granular control
- ✅ Use `/reset-allowed-tools` to clear session approvals
- ✅ `--allow-tool` and `--deny-tool` enable automation
- ✅ Deny rules take precedence over allow rules
- ✅ `--yolo` / `--allow-all` enables full autonomy - use only in safe environments
- ✅ Trusted directories control Copilot's file access scope
- ✅ URL permissions (`--allow-url`, `--deny-url`) control network access
- ✅ `url` pattern enables tool-level URL matching
- ✅ `--secret-env-vars` protects sensitive values from leaking
- ✅ `--no-ask-user` enables fully autonomous operation
- ✅ Path permission dialog offers one-time approval (v1.0.4+)
- ✅ Claude models support dynamic tool search (v1.0.6+)

## Next Steps

→ Continue to [Module 5: MCP Servers](05-mcps.md)

## References

- [Copilot CLI - GitHub Docs](https://docs.github.com/copilot/how-tos/copilot-cli)
- [Responsible Use of Copilot CLI](https://docs.github.com/en/copilot/responsible-use/copilot-cli)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
