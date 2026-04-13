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
- Custom: Set via `XDG_CONFIG_HOME` environment variable

## Hands-On Exercises

### Exercise 1: Session Persistence

> [!NOTE]
> **How Session Persistence Works:**
> - Each `copilot` invocation starts a **fresh session** by default
> - To restore a previous session, use `/resume` slash command or `--resume` flag
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

5. Immediately start Copilot again:
   ```bash
   copilot
   ```

6. Ask if it remembers:
   ```
   What feature was I working on?
   ```

7. Copilot should remember from the previous session context.

**Expected Outcome:**
Recent session context is preserved when quickly re-entering.

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

5. Start a new session with resume flag:
   ```bash
   copilot --resume
   ```

6. Verify you're in the same context:
   ```
   What was the last file we created?
   ```

**Expected Outcome:**
The `--resume` flag restores your previous session state.

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

**Goal:** Export session transcripts for documentation or sharing.

**Steps:**

1. Start a session and do meaningful work:
   ```bash
   copilot
   ```
   ```
   Explain the architecture of a typical Express.js application
   ```

2. Have a productive conversation building up knowledge.

3. Export to a file:
   ```bash
   copilot --share ./session-export.md
   ```

4. Or export to a GitHub Gist:
   ```bash
   copilot --share-gist
   ```

5. Review the exported markdown file:
   ```bash
   cat session-export.md
   ```

> [!TIP]
> If you're already inside an interactive session, you can use the `/share` slash command instead of the CLI flags above. It provides the same export functionality without leaving the session.

**Expected Outcome:**
Session transcript saved for future reference or sharing.

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
| `/exit` | End session | `/exit` |
| `/share` | Export session transcript (interactive alternative to `--share` flag) | `/share` |
| `/share html` | Export session as self-contained interactive HTML file | `/share html` |
| `/model` | Switch AI model | `/model gpt-4` |
| `/undo` | Undo last turn and revert file changes | `/undo` |
| `/rewind` | Roll back to any point in conversation history (also via double-Esc) | `/rewind` |

## Command Line Flags

| Flag | Description |
| --- | --- |
| `--resume` | Resume last session |
| `--share PATH` | Export to markdown file |
| `--share-gist` | Export to GitHub Gist |
| `--silent` | Suppress stats/logs |

## Summary

- ✅ Sessions maintain conversation history and context
- ✅ Use `--resume` to continue previous sessions
- ✅ `/clear` abandons the session; `/new` starts fresh while keeping the old session backgrounded
- ✅ `/undo` reverts the last turn and its file changes
- ✅ `/rewind` (or double-Esc) opens a timeline picker for rolling back to any conversation point
- ✅ `/rename` auto-generates a session name from conversation history when called without arguments
- ✅ `/cwd` and `/add-dir` control file access scope; `/cd` keeps a separate working directory per session
- ✅ Run multiple sessions in different terminals
- ✅ Export sessions with `--share` for documentation or `/share html` for interactive HTML

## Next Steps

→ Continue to [Module 12: Advanced Topics](12-advanced.md)

## References

- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [Slash Commands Cheat Sheet](https://github.blog/ai-and-ml/github-copilot/a-cheat-sheet-to-slash-commands-in-github-copilot-cli/)
