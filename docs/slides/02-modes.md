---
marp: true
theme: default
paginate: true
backgroundColor: #ffffff
color: #242424
style: |
 section {
 font-family: 'Segoe UI', system-ui, sans-serif;
 }
 h1 {
 color: #0078D4;
 border-bottom: 3px solid #0078D4;
 padding-bottom: 0.3em;
 }
 h2, h3 {
 color: #0078D4;
 }
 code {
 background: #f3f2f1;
 color: #242424;
 }
 pre {
 background: #f3f2f1 !important;
 border-radius: 4px;
 border-left: 4px solid #0078D4;
 }
 table {
 font-size: 0.85em;
 }
 th {
 background: #0078D4;
 color: #ffffff;
 }
 td {
 background: #f3f2f1;
 }
 strong {
 color: #0078D4;
 }
 blockquote {
 border-left: 4px solid #0078D4;
 color: #605e5c;
 background: #f3f2f1;
 padding: 0.5em 1em;
 border-radius: 4px;
 }
 a {
 color: #0078D4;
 }
 footer {
 color: #605e5c;
 }
 .columns {
 display: grid;
 grid-template-columns: 1fr 1fr;
 gap: 1em;
 }
---

# Module 2: Operating Modes & Commands

### GitHub Copilot CLI Workshop

---

## Four Ways to Use Copilot CLI

| Mode | Command | Best for |
|------|---------|----------|
| **Interactive** | `copilot` | Exploration, debugging, multi-step |
| **Interactive+Prompt** | `copilot -i "..."` | Start with task, continue chatting |
| **Programmatic** | `copilot -p "..."` | CI/CD, scripts, one-shot tasks |
| **Delegate** | `/delegate` | Long-running, heavy-lifting tasks |

---

## Interactive Mode

Start a **conversation** — context builds over time

```bash
copilot
```

```
> Explain this codebase
> Now refactor the auth module
> Add tests for the changes
> /exit
```

Perfect for: learning, debugging, iterating

---

## Programmatic Mode

**One prompt, one answer, done.**

```bash
copilot -p "summarize the README.md"
```

```bash
# With tool permissions
copilot -p "run tests and explain failures" --allow-tool 'shell'
copilot -p "run git status" --allow-tool 'shell(git status)'
```

```bash
# Pipe content in
cat error.log | copilot -p "explain these errors"
```

Perfect for: automation, CI/CD, scripting

> Shell approval matches the **first-level subcommand** — `shell(git status)` allows exactly that, and `shell(git)` alone does not cover git subcommands
> Use `shell(git:*)` for the whole family — the wildcard matches the command stem, so it covers `git push` but not `gitea`

---

## Programmatic Mode: Machine-Readable Output

```bash
# JSON output for scripting
copilot -p "list all TODO comments" --output-format json
```

```bash
# Silent mode — agent response only, no stats
copilot -p "What is 2+2?" -s
```

Pair `--output-format json` with a parser like `jq`; use `-s` when you want
the response text alone, with no session statistics around it.

---

## Delegate Mode

**Hand off to a cloud agent** — it creates a branch and PR

```
/delegate implement user authentication based on the spec
```

- Works **asynchronously** — you keep working locally
- Creates a **draft PR** you can review
- Has full repository context

Perfect for: big features, refactoring, parallel work

---

## Status Hints & Repository State

While composing a prompt, the status bar teaches the interface:

- `@files` and `#issues` hints surface context shortcuts
- `/help` appears with the command picker; commands are tab-completable
- Git branch suffixes show changes: `*` unstaged, `+` staged, `%` untracked
- Example: `main*+%`

---

## Slash Commands

Type **`/help`** to see them all

| Category | Key commands |
|----------|-------------|
| **Review** | `/plan`, `/review`, `/rubber-duck`, `/security-review`, `/diff`, `/research`, `/rewind` |
| **Session** | `/clear`, `/new`, `/resume`, `/rename`, `/fork`, `/worktree`, `/move`, `/session`, `/usage` |
| **Navigation** | `/cwd`, `/add-dir`, `/list-dirs` |
| **Context** | `/context`, `/compact` |
| **Quick / env** | `/ask`, `/refine`, `/env`, `/remote` |
| **Config** | `/model`, `/mcp`, `/plugin`, `/theme`, `/settings`, `/statusline`, `/subagents`, `/instructions`, `/terminal-setup`, `/experimental` |
| **Tools** | `/permissions`, `/allow-all`, `/reset-allowed-tools` |
| **Extensibility** | `/skills`, `/plugin`, `/agent`, `/fleet`, `/delegate` |
| **Scheduling** | `/after`, `/every` |
| **Sharing** | `/share`, `/share html`, `/feedback`, `/copy` |
| **Account** | `/login`, `/logout`, `/user` |
| **IDE** | `/ide` |
| **System** | `/help`, `/changelog`, `/exit`, `/init`, `/tasks`, `/lsp`, `/update`, `/restart`, `/version`, `/voice`, `/computer`, `/vim`, `/chronicle`, `/search`, `/keep-alive`, `/limits`, `/diagnose`, `/collect-debug-logs`, `/app` |

> Most commands have aliases — `/yolo` → `/allow-all`, `/cd` → `/cwd`, `/undo` → `/rewind`
> `/theme` with no argument opens the theme picker; `/settings theme dim` sets it directly
> (themes: `default`, `github`, `dim`, `high-contrast`, `colorblind`)

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `@` | Mention files — include as context |
| `#` | Reference GitHub issues, PRs, discussions |
| `!` | Run shell commands directly (only way to access shell) |
| `Shift+Tab` | Cycle between chat → plan → autopilot mode |
| `Esc` | Cancel current operation |
| `Double-Esc` | Clear input, or rewind the last turn |
| `ctrl+t` | Toggle reasoning display |
| `ctrl+x → /` | Quick slash command |
| `ctrl+c` | Cancel / clear input / exit |
| `ctrl+d` | Shutdown on empty prompt |
| `ctrl+y` | Edit plan in terminal editor |
| `ctrl+f` / `ctrl+b` | Page forward / back |
| `ctrl+g` | Open prompt in external editor |

> See workshop for 18 additional shortcuts including text editing and navigation

---

## Session Semantics & Aliases

- `/new [prompt]` starts a conversation and keeps the old session backgrounded
- `/clear [prompt]` abandons the current session and starts fresh
- `/share html` writes a self-contained interactive export
- `/keep-alive on|off|busy` prevents sleep; `/memory on|off` controls recall
- `/pr` manages the current branch pull request

Common aliases: `/yolo` → `/allow-all` · `/btw` → `/ask` · `/reset` → `/clear` · `/continue` → `/resume` · `/undo` → `/rewind` · `/export` → `/share` · `/caffeinate` → `/keep-alive`

---

## Commands During Agent Work

No need to wait for the current agent turn:

| Command | Use |
|---------|-----|
| `/ask` | Quick answer, excluded from conversation history |
| `/env` | Loaded instructions, MCPs, skills, agents, hooks, plugins, LSPs, extensions |
| `/remote` | Start or manage remote control |
| `/diff`, `/agent`, `/feedback`, `/ide` | Inspect or control work in progress |

`/refine` rewrites rough input for review before you send it.

---

## Startup Controls

```bash
copilot --mode plan                 # interactive, plan, or autopilot
copilot --agent rubber-duck
copilot -n "auth-fix" --session-id <id>
copilot -C ./service --context long_context
copilot --effort high --max-ai-credits 30
copilot --remote                    # web/mobile remote control
```

Also: `--plan`, `--autopilot`, `--experimental`, `--connect[=id]`, `--acp`,
`--max-autopilot-continues`, `--enable-reasoning-summaries`

`/init` bootstraps repository instructions; `/terminal-setup` configures multiline input.

---

## Agent Selection

Start with a specialized agent when you need focused behavior:

```
/rubber-duck Review this plan for logic errors and missed edge cases
```

Or start directly with the same agent:

```bash
copilot --agent rubber-duck
```

**Rubber-duck** gives high-signal critique of plans and implementations:

- Bugs and logic errors
- Design flaws
- Missed edge cases

> Built-in agents are designed for interactive sessions — pairing `--agent` with a `-p` run fails outright (custom agents do work with `-p`)

---

## Security Review Mode

Run a security-focused review of staged and unstaged changes:

```
/security-review Check these changes for exploitable security issues
```

Use it for:

- Auth and authorization changes
- Input handling and dependency changes
- Secrets or sensitive-data paths

---

## Scheduling Prompts

Run prompts later or repeatedly:

```
/after 30m Check whether the test run finished
/every 1h Run frontend tests and report failures
```

- `/after` — one-shot schedule
- `/every` — recurring schedule
- Scheduled work appears in `/tasks`

> `copilot help commands` does not list `/after` or `/every` even though they work — treat in-session `/help` as the authoritative list

---

## Tool Approval

When Copilot wants to run a command, you choose:

| Option | Effect |
|--------|--------|
| **Yes** | Allow once |
| **Yes, for session** | Allow all similar for session |
| **No** | Deny and redirect |

> ⚠️ Be careful with session-wide approval for `rm`, `git push`, `sudo`
> ✅ Safe for `ls`, `cat`, `git status`, `git diff`

---

## Permission Modes & Session Limits

Switch how much the agent may do on its own:

```
/permissions manual      # approve every request
/permissions assisted    # auto-approve what a safety check deems safe
/permissions allow-all   # auto-approve tools, paths, and URLs
/permissions show        # show current status
```

> `assisted` needs the experimental auto-approval feature — it is ignored when that feature is off or when policy blocks auto-approval

Cap what a session may spend (opt-in, minimum **30** AI credits):

```bash
copilot --max-ai-credits 30
```

```
/limits                            # interactive limits dialog
/limits set max-ai-credits 50
/limits unset all
```

> The AI credit limit is a **soft cap** — usage is known only after a response returns

---

## Your Turn! 🚀

Open **Module 2** in `docs/workshop/02-modes.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Slash commands
- **Exercise 2** — Plan → Review → Diff
- **Exercise 3** — Repo init & sessions
- **Exercise 4–5** — Interactive basics & tool approval
- **Exercise 6–7** — Programmatic mode & chaining
- **Exercise 8–9** — Delegate & comparing modes

⏱️ You have **~16 minutes**
