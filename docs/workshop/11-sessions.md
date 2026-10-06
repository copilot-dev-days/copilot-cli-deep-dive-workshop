# Module 11: Session Management

## Prerequisites

- Completed Modules 1-10
- Copilot CLI installed and authenticated

## Learning Objectives

- Understand session lifecycle and persistence
- Resume and continue previous sessions
- Use session-related slash commands
- Track session usage and metrics
- Clear context when needed

## Concepts

### What is a Session?

A session is a continuous interaction with Copilot CLI that maintains:
- **Conversation history** - All prompts and responses
- **Context** - Files, directories, and information gathered
- **Tool approvals** - Permissions granted during the session
- **Working directory** - The directory scope

Sessions can be:
- **Continued** - Pick up where you left off
- **Resumed** - Restore a previous session
- **Cleared** - Start fresh while staying in Copilot

### Session Storage

Sessions are stored in your Copilot config directory:
- Default: `~/.copilot/`
- Custom: Set via `COPILOT_HOME` environment variable

Within that directory, session data lives in two places:

| Path | Contents |
| --- | --- |
| `~/.copilot/session-state/<session-id>/` | Per-session transcript (`events.jsonl`), checkpoints, rewind snapshots, and workspace metadata |
| `~/.copilot/session-store.db` | Index of all sessions used by `/session`, `/resume`, and `--resume` |

Manage this data with the `/session` subcommands rather than by deleting files by hand.

## Hands-On Exercises

### Exercise 1: Session Persistence

> [!NOTE]
> **How Session Persistence Works:**
> - Each `copilot` invocation starts a **fresh session** by default
> - To restore a previous session, use `/resume`, `--resume`, or `--continue`
> - Key session commands available:
>   - `/resume` - Switch to a different session (optionally specify session ID)
>   - `/rename` - Rename the current session (alias for `/session rename`)
>   - `/context` - Show context window token usage and visualization
>   - `/usage` - Display session usage metrics and statistics
>   - `/session` - Show session info and workspace summary (use subcommands for details)
>   - `/compact` - Summarize conversation history to reduce context window usage
>   - `/share` - Share session to markdown file or GitHub gist

**Goal:** Understand how sessions persist between interactions.

**Steps:**

1. Start a new session and gather some context:
   ```bash
   copilot
   ```

2. Ask Copilot to remember something:
   ```
   Remember that I'm working on a user authentication feature. The main file is auth.py.
   ```

3. Ask about the files:
   ```
   What files are in the current directory?
   ```

4. Exit with `Ctrl+C` (not `/exit`).

5. Immediately continue the most recent session:
   ```bash
   copilot --continue
   ```

6. Ask if it remembers:
   ```
   What feature was I working on?
   ```

7. Copilot should remember from the previous session context.

**Expected Outcome:**
Recent session context is restored when you explicitly continue or resume the session.

### Exercise 2: Resume a Session

**Goal:** Learn to explicitly resume a previous session.

**Steps:**

1. Start a session and do some work:
   ```bash
   copilot
   ```
   ```
   Create a file called notes.txt with "Session 1 notes"
   ```

2. Use `/session` to see session info:
   ```
   /session
   ```

3. Note the session ID displayed.

4. Exit completely:
   ```
   /exit
   ```

5. Resume that session explicitly:
   ```bash
   copilot --resume
   ```

   With no value, `--resume` opens the session picker — choose the session you noted in step 3. To jump straight back into the most recent session without the picker, use `copilot --continue` instead. You can also pass the value directly, for example `copilot --resume=<session-id>`.

6. Verify you're in the same context:
   ```
   What was the last file we created?
   ```

**Expected Outcome:**
The `--resume` flag restores a previous session you select, and `--continue` reattaches to the most recent one.

### Exercise 3: Slash Commands for Session Control

**Goal:** Master session-related slash commands.

**Steps:**

1. Start an interactive session:
   ```bash
   copilot
   ```

2. **View all commands:**
   ```
   /help
   ```

3. **Check current session:**
   ```
   /session
   ```
   This shows:
   - Session ID
   - Start time
   - Duration
   - Files modified
   - Commands executed

4. **Check usage statistics:**
   ```
   /usage
   ```
   This shows:
   - Token consumption
   - API calls made
   - Model used

5. **View current working directory:**
   ```
   /cwd
   ```

6. **Clear conversation history (abandons session):**
   ```
   /clear
   ```

7. Or start a new conversation (keeps old session backgrounded):
   ```
   /new
   ```

8. Verify context is cleared:
   ```
   What was I just working on?
   ```

   Copilot won't know because context was cleared.

**Expected Outcome:**
You understand each session command's purpose.

### Exercise 4: Managing Working Directory

**Goal:** Control which directories Copilot can access.

**Steps:**

1. Start in your home directory:
   ```bash
   cd ~
   copilot
   ```

2. Check current working directory:
   ```
   /cwd
   ```

3. Change to a specific project:
   ```
   /cwd ~/copilot-workshop
   ```

4. Verify the change:
   ```
   /cwd
   ```

5. Add another directory for access:
   ```
   /add-dir ~/another-project
   ```

6. List all accessible directories:
   ```
   /list-dirs
   ```

7. Try to access a file outside allowed directories:
   ```
   Show me /etc/passwd
   ```

   Copilot should request permission or refuse.

**Expected Outcome:**
You can control Copilot's file access scope.

### Exercise 5: Session Clearing Strategies

**Goal:** Know when and how to clear session context.

**Steps:**

1. Build up context in a session:
   ```bash
   copilot
   ```
   ```
   Let's work on the frontend. The main component is App.tsx.
   ```
   ```
   The backend uses Express.js with routes in /api.
   ```
   ```
   We're using PostgreSQL for the database.
   ```

2. Check token usage:
   ```
   /context
   ```

3. Notice context filling up. If working on something unrelated:
   ```
   /clear
   ```

4. Start fresh:
   ```
   Now let's work on a completely different Python script.
   ```

5. **Alternative: Partial clear** - Exit and start new:
   ```
   /exit
   ```
   ```bash
   copilot
   ```

**When to Clear:**

| Scenario | Action |
| --- | --- |
| Switching to unrelated task | `/new` (keeps old session) or `/clear` (abandons) |
| Confused responses | `/new` |
| Context limit approaching | `/compact` first, then `/new` if needed |
| Sensitive info discussed | `/clear` and `/exit` |
| Session becomes slow | `/new` |

**Expected Outcome:**
You know when clearing context improves your workflow.

### Exercise 6: Multiple Sessions Strategy

**Goal:** Work with multiple Copilot instances.

**Steps:**

1. Open Terminal 1 - Frontend work:
   ```bash
   cd ~/project/frontend
   copilot
   ```
   ```
   Let's focus on React components
   ```

2. Open Terminal 2 - Backend work:
   ```bash
   cd ~/project/backend
   copilot
   ```
   ```
   Let's focus on API endpoints
   ```

3. Each terminal maintains its own:
   - Session context
   - Working directory
   - Tool approvals

4. Switch between terminals as needed for parallel work.

**Expected Outcome:**
You can run multiple focused sessions simultaneously.

### Exercise 7: Session Export and Sharing

**Goal:** Export session transcripts for documentation or sharing, using the right mechanism for interactive and non-interactive runs.

> [!IMPORTANT]
> `--share` and `--share-gist` apply **only to non-interactive runs**, and they share **that run's own session** after it completes — they cannot export a conversation from an earlier session. To export an interactive session that is already in progress, use the `/share` slash command from inside it.

**Steps:**

1. Start an interactive session and do meaningful work:
   ```bash
   copilot
   ```
   ```
   Explain the architecture of a typical Express.js application
   ```

2. Have a productive conversation building up knowledge, then export it from inside the session:
   ```
   /share
   ```

   `/share` exports the session you are currently in to a markdown file, an HTML file, a GitHub gist, or a shareable GitHub link.

3. Export a non-interactive run to a markdown file. The flag shares the session created by this same command once it finishes:
   ```bash
   copilot -p "Explain the architecture of a typical Express.js application" --share ./session-export.md
   ```

   Omit the path to accept the default of `./copilot-session-<id>.md`.

4. Or share a non-interactive run to a secret GitHub gist:
   ```bash
   copilot -p "Explain the architecture of a typical Express.js application" --share-gist
   ```

5. Review the exported markdown file:
   ```bash
   cat session-export.md
   ```

**Expected Outcome:**
You can export an in-progress interactive session with `/share`, and capture a non-interactive run's transcript with `--share` or `--share-gist`.

## Session Slash Commands Reference

| Command | Description | Example |
| --- | --- | --- |
| `/help` | List all commands | `/help` |
| `/session` | Show session info | `/session` |
| `/usage` | Show usage stats | `/usage` |
| `/cwd` | Show/change directory | `/cwd ~/project` |
| `/add-dir` | Add accessible directory | `/add-dir /tmp` |
| `/list-dirs` | List accessible directories | `/list-dirs` |
| `/clear` | Abandon session and start fresh | `/clear` |
| `/new [prompt]` | Start new conversation (old session stays backgrounded) | `/new` |
| `/exit` | End session; use `/exit print` to print the session after exiting alt screen | `/exit print` |
| `/share` | Export the session you are currently in (markdown, HTML, gist, or shareable link) | `/share` |
| `/share html` | Export session as self-contained interactive HTML file; shows `file://` URL and `Ctrl+X O` to open | `/share html` |
| `/model` | Switch AI model | `/model` |
| `/rewind` (alias `/undo`) | Rewind the last turn and revert file changes; also available via double-Esc | `/rewind` |

### `/session` Subcommands

`/session` on its own opens the session manager. Add a subcommand to go straight to a specific view or action:

| Subcommand | Description |
| --- | --- |
| `/session` | Open the session picker |
| `/session <id>` | Switch to a session by ID |
| `/session info` | Show details about the current session |
| `/session checkpoints [n]` | List checkpoints for the current session |
| `/session files` | List files touched in the current session |
| `/session plan` | Show the current session's plan |
| `/session rename [name]` | Rename the current session, or auto-generate a name |
| `/session cleanup` | Remove stale session records |
| `/session prune` | Prune old session data |
| `/session delete [id]` | Delete a session |
| `/session delete-all` | Delete all sessions |

## Command Line Flags

| Flag | Description |
| --- | --- |
| `--continue` | Resume the most recent session |
| `-r, --resume[=value]` | Resume a previous session; with no value it opens the session picker. Optionally accepts an existing session ID, task ID, ID prefix (7+ hex chars), or session name (exact, case-insensitive). |
| `-n, --name <name>` | Set a name for the new session |
| `--session-id <id>` | Resume an existing session or task by ID, or set the UUID for a new session |
| `--connect[=sessionId]` | Connect directly to a remote session (optionally specify session ID or task ID) |
| `--remote` | Enable remote control of your session from GitHub web and mobile |
| `--remote-export` | Export your session to GitHub web and mobile (read-only; does not enable remote control) |
| `--share [path]` | Share the session to a markdown file after completion in non-interactive mode (default: `./copilot-session-<id>.md`) |
| `--share-gist` | Share the session to a secret GitHub gist after completion in non-interactive mode |
| `--silent` | Output only agent response (no stats) |

## Summary

- ✅ Sessions maintain conversation history and context
- ✅ Use `--continue` to reattach to the most recent session, and `--resume` to pick a previous one
- ✅ `/clear` abandons the session; `/new` starts fresh while keeping the old session backgrounded
- ✅ `/rewind` (alias `/undo`, or double-Esc) rewinds the last turn and reverts file changes
- ✅ `/rename` auto-generates a session name from conversation history when called without arguments
- ✅ `--name` flag sets a session name at launch; `--resume` accepts a session name for lookup
- ✅ `/cwd` and `/add-dir` control file access scope; `/cwd` sets the working directory per session
- ✅ `/session` subcommands inspect and prune session data (`info`, `checkpoints`, `files`, `prune`, `delete-all`)
- ✅ Run multiple sessions in different terminals
- ✅ Export an in-progress interactive session with `/share`, or a non-interactive run with `--share`; use `/share html` for interactive HTML
- ✅ `/share html` shows `file://` URL and `Ctrl+X O` shortcut to open in browser
- ✅ Remote control sessions via `--remote` or `/remote` — observe/control sessions remotely

## Next Steps

→ Continue to [Module 12: Advanced Topics](12-advanced.md)

## References

- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
- [Slash Commands Cheat Sheet](https://github.blog/ai-and-ml/github-copilot/a-cheat-sheet-to-slash-commands-in-github-copilot-cli/)
