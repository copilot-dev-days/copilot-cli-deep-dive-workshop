# Module 4: Tools & Permissions

## Prerequisites

- Completed Modules 1-3
- Understanding of command-line security concepts
- A test directory for safe experimentation

## Learning Objectives

- Understand Copilot CLI's built-in tools
- Master the permission approval workflow
- Use `--allow-tool` and `--deny-tool` flags effectively
- Understand `--yolo` mode and when to use it safely
- Switch permission modes with `/permissions`
- Understand command sandboxing as an additional restriction layer
- Configure trusted directories

## Concepts

### Built-in Tools

Copilot CLI registers a set of built-in tools in every session:

| Tool | Purpose | Risk Level |
|------|---------|------------|
| `bash` | Execute shell commands (`read_bash`, `list_bash`, `stop_bash` manage background shells) | ⚠️ High |
| `create` / `edit` | Create files and make precise edits to existing files | ⚠️ High |
| `view` | Read files and list directories | Low |
| `glob` / `grep` | Find files by pattern and search file contents | Low |
| `web_fetch` / `web_search` | Fetch a URL and search the web | Medium |
| `fetch_copilot_cli_documentation` | Look up Copilot CLI's own documentation | Low |
| `task` / `read_agent` / `write_agent` / `list_agents` | Delegate work to subagents and exchange messages with them | Varies |
| `skill` | Load a skill's instructions on demand | Low |
| `sql` / `session_store_sql` | Query the agent's session database (to-do list, session history) | Low |
| `run_dynamic_workflow` / `dynamic_workflows_manage` | Register and run dynamic workflows (also available from the shell as `copilot workflow run`) | Varies |
| `ask_user` | Ask you a clarifying question (interactive sessions; disable with `--no-ask-user`) | Low |
| MCP server tools | Tools contributed by configured MCP servers, prefixed with the server name | Varies |

> [!NOTE]
> Permission rules match **kinds**, which are not the same as tool names. `copilot help permissions` defines exactly four kinds: `shell(command)`, `write(path)`, `<mcp-server-name>(tool-name)`, and `url(domain-or-url)`. So `--allow-tool 'shell(git status)'` is a rule kind, while `bash` is the tool that runs the command. Use `--available-tools`/`--excluded-tools` when you need to filter by tool name.

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

> Undo operations always require user confirmation before applying — they do not auto-apply. This safety measure prevents accidental reversions.

### Path Permission Approval

> The path permission dialog offers a **one-time approval** option in addition to permanently adding the path to the allowed list. This lets you grant access for the current session without modifying your persistent configuration.

### Tool Availability vs Tool Permission

Tool availability and tool permission are separate controls:

| Control | Flags | Purpose |
|---|---|---|
| Availability | `--available-tools`, `--excluded-tools` | Which tools the model can see |
| Permission | `--allow-tool`, `--deny-tool`, `--allow-all-tools` | Which visible tools can run without prompting |

Deny rules always take precedence over allow rules.

### Permission Modes

`/permissions` switches the session between permission modes, and `/permissions show` reports the current one:

| Mode | Behavior |
|---|---|
| `manual` | Require approval for each request |
| `assisted` | An LLM safety check auto-approves requests it judges safe and prompts otherwise. Requires the experimental auto-approval feature; ignored when that feature is off or when policy blocks auto-approval. |
| `allow-all` | Auto-approve all tool, path, and URL requests |
| `show` | Display the current mode without changing it |

Running `/permissions` with no argument opens the interactive mode picker.

You can request the same safety judge at launch with `--assisted-approval`, the launch-time counterpart to the `assisted` mode. It reviews tool permission requests instead of approving them outright, and it takes precedence over `--allow-all-tools` when the judge engages. Like the `assisted` mode, it requires the experimental auto-approval feature — enable it with `--experimental` or `enabledFeatureFlags.AUTO_APPROVAL`. The flag also reads the `COPILOT_ASSISTED_APPROVAL` environment variable:

```bash
copilot --experimental --assisted-approval -p "Tidy up the build scripts"
```

### Command Sandboxing

Command sandboxing is a third layer alongside tool permissions and path permissions. When it is enabled, shell commands run inside an OS-level sandbox with restricted filesystem and network access, so a command the agent runs cannot reach outside the policy you configured.

Sandboxing is an experimental feature: the `/sandbox` command (and its `enable`/`disable` subcommands) is only registered when experimental features are on, **or when a managed policy forces sandboxing on**; otherwise it returns "Unknown command". Turn experimental features on with the `--experimental` flag or `/settings experimental on`.

```text
/sandbox            # Show status; in interactive mode, opens the policy dialog
/sandbox enable     # Turn command sandboxing on
/sandbox disable    # Turn command sandboxing off
```

You can also start a session with sandboxing already on by passing `--sandbox` at launch, instead of enabling it from inside the session:

```bash
copilot --experimental --sandbox -p "Run the test suite and summarize failures"
```

Because sandboxing is experimental, `--sandbox` needs `--experimental` alongside it (or experimental features already enabled in settings). Without that, Copilot prints a warning and ignores the flag for the session. `--sandbox` is not listed in `copilot --help`; `copilot help sandbox` is its reference.

Sandboxing can therefore already be active at session start from `--sandbox`, a saved `sandbox.enabled` setting, or an organization policy. If the host cannot run the sandbox backend in that situation, Copilot prints a startup warning and sandboxed commands fail.

Sandboxing is powered by Microsoft Execution Containers (MXC), which maps the policy onto each platform's isolation primitives: Seatbelt (`sandbox-exec`) on macOS, bubblewrap (`bwrap`) on Linux, and ProcessContainer on Windows. If your host cannot run the backend, sandboxed shell commands fail rather than falling back to unsandboxed execution.

Sandbox settings live under the `sandbox` key in `~/.copilot/settings.json` and can also be edited from the `/sandbox` dialog:

| Setting | Purpose |
|---|---|
| `sandbox.enabled` | Whether command sandboxing is on |
| `sandbox.addCurrentWorkingDirectory` | Grant read/write access to the working directory |
| `sandbox.allowDevToolAccess` | Auto-grant the dev-tool caches and config that builds need |
| `sandbox.allowBypass` | Allow a per-command escape hatch out of the sandbox |
| `sandbox.auth.git` / `sandbox.auth.gh` | Inject git and `gh` credentials into sandboxed commands so authenticated git/`gh` operations keep working inside the sandbox. Tokens are never injected while the sandbox is disabled. |
| `sandbox.sandboxMcpServers` / `sandbox.sandboxLspServers` | Also sandbox local (stdio) MCP and LSP servers |
| `sandbox.userPolicy.filesystem.readwritePaths` / `readonlyPaths` / `deniedPaths` | Extra paths to grant or deny |
| `sandbox.userPolicy.network.allowOutbound` / `allowLocalNetwork` | Control outbound and local-network access |
| `sandbox.userPolicy.seatbelt.keychainAccess` | Allow system keychain access from inside the sandbox (macOS) |

> [!NOTE]
> Remote (HTTP/SSE) MCP servers are never sandboxed. The sandbox also inherits your shell environment apart from a fixed blocklist, so credentials already exported in your environment remain visible to sandboxed commands — use `--secret-env-vars` to strip the ones that matter.
>
> An organization policy can enforce sandboxing. When it does, `/sandbox disable` is refused and a local `sandbox.enabled: false` is overridden.

Run `copilot help sandbox` for the full reference.

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
 - Tool name: `create` (matched by the `write` permission kind)
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
 copilot --yolo -p "Create a Node.js project in the current directory with package.json and a simple server. Do not create a subdirectory."
 ```

5. Review what was created:
 ```bash
 ls -la
 cat package.json
 ```

 > [!TIP]
 > If `cat package.json` reports no such file, the agent placed the project in a subdirectory. Run `ls -la` first and `cat` the path it actually created.

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

**Steps:**

> **Key concept:** Copilot CLI has two distinct directory controls:
>
> | Layer | Purpose | Scope |
> |---|---|---|
> | **Startup trust** (`trustedFolders`) | Skips the "do you trust this folder?" prompt when launching Copilot | Launch-time only |
> | **Runtime access** (`/add-dir`, `--add-dir`) | Controls which paths the agent can read/write during a session | Session-time only |
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

4. In a side terminal, check whether the folder was remembered. Read **only** the `trustedFolders` key:
 ```bash
 grep -v '^[[:space:]]*//' ~/.copilot/config.json | jq -r '.trustedFolders[]?'
 ```
 Notice that `trustedFolders` was **not** updated (you chose session-only trust).

 > [!WARNING]
 > Never print, `cat`, or share the whole of `~/.copilot/config.json`. It is managed automatically by the CLI and stores your live Copilot authentication token alongside `trustedFolders`. Read only the specific key you need, as above — especially while screen-sharing. Your own settings belong in `~/.copilot/settings.json`, which you can edit with `/settings`.

5. To permanently skip the prompt for specific directories, add them to `~/.copilot/config.json`:
 ```json
 {
 "trustedFolders": [
 "/home/user/projects",
 "/home/user/copilot-workshop"
 ]
 }
 ```
 Next time you launch Copilot from those directories, it won't ask for trust confirmation. Choosing **Yes, and remember** at the trust prompt writes the same entry for you, which is the safer way to do it.

 > [!IMPORTANT]
 > Folder trust also gates repository hooks: `.github/hooks/*.json` is discovered but never executed in an untrusted folder, and no error is shown. See [Module 9: Hooks](09-hooks.md).

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

8. Verify with `/list-dirs` — the new path appears.

9. To grant runtime access at launch instead, use the `--add-dir` flag:
 ```bash
 copilot --add-dir /home/user/projects --add-dir /home/user/copilot-workshop
 ```

**Expected Outcome:**
You understand that `trustedFolders` controls the **startup trust prompt**, while `/add-dir`, `/list-dirs`, and `--add-dir` control **runtime file access** — and that these are two independent permission layers.

### Exercise 7: Creating a Safe Automation Script

**Goal:** Build a secure automated workflow.

**Steps:**

1. Create a script `analyze-project.sh`:
 ```bash
 cat > analyze-project.sh << 'EOF'
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
 EOF
 ```

2. Create a code review script:
 ```bash
 cat > review-changes.sh << 'EOF'
 #!/bin/bash

 # Review changes but don't modify anything
 copilot -p "Review the git diff and provide feedback" \
 --allow-tool 'shell(git diff)' \
 --allow-tool 'shell(git log)' \
 --allow-tool 'shell(git status)' \
 --deny-tool 'shell(git push)' \
 --deny-tool 'shell(git commit)' \
 --deny-tool 'write'
 EOF
 ```

3. Make executable and test:
 ```bash
 chmod +x analyze-project.sh
 chmod +x review-changes.sh
 ./analyze-project.sh
 ```

**Expected Outcome:**
Safe, repeatable automation with explicit permissions.

## Tool Permission Reference

### Allow/Deny Syntax

```bash
# Allow specific command or subcommand
--allow-tool 'shell(git status)'

# Allow command family
--allow-tool 'shell(git:*)'

# Allow all shell
--allow-tool 'shell'

# Allow file writes
--allow-tool 'write'

# Allow all tools from an MCP server
--allow-tool 'MyMCP'

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
copilot --secret-env-vars=MY_API_KEY,DATABASE_PASSWORD
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
| `--assisted-approval` | Review requests with the assisted-approval safety judge (requires experimental auto-approval; env: `COPILOT_ASSISTED_APPROVAL`) |
| `--sandbox` | Start the session with command sandboxing already on |

### Runtime Slash Commands

| Command | Description |
|---------|-------------|
| `/permissions [manual\|assisted\|allow-all\|show]` | Switch permission modes, or show the current one (`assisted` requires the experimental auto-approval feature) |
| `/allow-all` | Enable all permissions (tools, paths, and URLs) |
| `/reset-allowed-tools` | Reset the list of tools approved during the session |
| `/add-dir <path>` | Grant runtime file access to a directory for the current session; this does not add it to startup `trustedFolders` (supports relative paths like `./src`, `../sibling`) |
| `/list-dirs` | View accessible directories |
| `/sandbox [enable\|disable]` | Show or change command sandboxing (registered when experimental features are on, or when a policy forces sandboxing on) |

## Summary

- ✅ Copilot requires approval for high-risk actions; some low-risk tools may be pre-approved by environment policy
- ✅ Built-in tools include `bash`, `create`, `edit`, `view`, `glob`, `grep`, `web_fetch`, `web_search`, `task`, and `skill`
- ✅ Permission rules match kinds — `shell`, `write`, `<mcp-server-name>`, and `url` — not tool names
- ✅ One-time vs session-wide approval gives granular control
- ✅ `/permissions` switches between `manual`, `assisted`, and `allow-all` modes; `assisted` needs the experimental auto-approval feature
- ✅ `--assisted-approval` requests the same safety judge at launch (env: `COPILOT_ASSISTED_APPROVAL`)
- ✅ Use `/reset-allowed-tools` to clear session approvals
- ✅ `--allow-tool` and `--deny-tool` enable automation
- ✅ Deny rules take precedence over allow rules
- ✅ `--yolo` / `--allow-all` enables full autonomy - use only in safe environments
- ✅ Trusted directories control launch-time trust; `/add-dir` and `--add-dir` control runtime file access scope
- ✅ URL permissions (`--allow-url`, `--deny-url`) control network access
- ✅ `url` pattern enables tool-level URL matching
- ✅ `--secret-env-vars` protects sensitive values from leaking
- ✅ `--no-ask-user` enables fully autonomous operation
- ✅ Path permission dialog offers one-time approval
- ✅ `/add-dir` accepts relative paths like `./src` and `../sibling`
- ✅ Command sandboxing adds an OS-level restriction layer on top of tool and path permissions; start it with `--sandbox` or `/sandbox enable`
- ✅ `~/.copilot/config.json` is managed automatically and holds credentials — never print or share it

## Next Steps

→ Continue to [Module 5: MCP Servers](05-mcps.md)

## References

- [Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Responsible Use of Copilot CLI](https://docs.github.com/en/copilot/responsible-use/agents)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
