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

## Three Ways to Use Copilot CLI

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

## Rubber Duck in Interactive Mode

Use Copilot as a thinking partner to clarify problems step by step

```
copilot
```

```
> Rubber duck with me: I expected this script to parse JSON,
> but it fails on some inputs. Ask one diagnostic question at a time.
```

```
# Optional side question without adding to session context
/ask What JSON edge cases should I test first?
```

Outcome: clearer reasoning, better hypotheses, faster debugging

---

## Programmatic Mode

**One prompt, one answer, done.**

```bash
copilot -p "summarize the README.md"
```

```bash
# With tool permissions
copilot -p "run tests and explain failures" --allow-tool 'shell'
```

```bash
# Pipe content in
cat error.log | copilot -p "explain these errors"
```

Perfect for: automation, CI/CD, scripting

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

## Slash Commands

Type **`/help`** to see them all

| Category | Key commands |
|----------|-------------|
| **Review** | `/plan`, `/review`, `/rubber-duck`, `/security-review`, `/diff`, `/research`, `/undo` |
| **Session** | `/clear`, `/resume`, `/rename`, `/session`, `/usage` |
| **Navigation** | `/cwd`, `/add-dir`, `/list-dirs` |
| **Context** | `/context`, `/compact` |
| **Config** | `/model`, `/mcp`, `/plugin`, `/settings`, `/subagents`, `/instructions` |
| **Tools** | `/allow-all`, `/reset-allowed-tools` |
| **Extensibility** | `/skills`, `/plugin`, `/agent`, `/fleet` |
| **Scheduling** | `/after`, `/every` |
| **Sharing** | `/share`, `/feedback`, `/copy` |
| **Account** | `/login`, `/logout`, `/user` |
| **IDE** | `/ide` |
| **System** | `/help`, `/exit`, `/init`, `/tasks`, `/lsp`, `/update`, `/restart`, `/version`, `/chronicle`, `/limits` |

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `@` | Mention files — include as context |
| `#` | Reference GitHub issues, PRs, discussions |
| `!` | Run shell commands directly (only way to access shell) |
| `Shift+Tab` | Cycle between chat → plan → autopilot mode |
| `Esc` | Cancel current operation |
| `Double-Esc` | Clear input or trigger undo |
| `ctrl+t` | Toggle reasoning display |
| `ctrl+x → /` | Quick slash command |
| `ctrl+c` | Cancel / clear input / exit |
| `ctrl+d` | Shutdown on empty prompt |
| `ctrl+y` | Edit plan in terminal editor |
| `ctrl+f` / `ctrl+b` | Page forward / back |
| `ctrl+g` | Open prompt in external editor |

> See workshop for 25+ additional shortcuts including text editing and navigation

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
