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
---

# Module 11: Session Management

### GitHub Copilot CLI Workshop

---

## What is a Session?

A session maintains:

- 💬 **Conversation history** — all prompts and responses
- 📂 **Context** — files, directories, tool results
- 🔑 **Tool approvals** — permissions granted
- 📍 **Working directory** — scope of operations

---

## Session Lifecycle

```
Start           Work            Exit
  │               │               │
copilot    prompts + tools    /exit or Ctrl+C twice
  │               │               │
  └───── Session persists ────────┘
                  │
          copilot --continue   ← pick up later
```

---

## Key Session Commands

| Command | What it does |
|---------|-------------|
| `/session` / `/session info` | Open session manager / show current-session details |
| `/usage` | Tokens, duration, edited lines, account and per-model usage |
| `/model` | Switch the active model |
| `/rename NAME` | Name your session for easy finding |
| `/clear` | Fresh active conversation, not transcript/log/memory erasure |
| `/new` | Start new conversation (old session stays backgrounded) |
| `/fork [name]` / `/branch` | Copy conversation into a new session; same project files |
| `/resume` | Switch to a previous session (picker, or pass ID/name) |
| `--continue` | Resume the most recent session from CLI |
| `--remote` / `/remote` | Enable web/mobile remote control |
| `--remote-export` | **Removal candidate:** rejected; use `--sync-session=on` |
| `--sync-session=on\|off` | Upload history for a view-only account copy, or disable sync; no incoming control |
| `/share` | Export the session you're in (markdown, HTML, gist, or link) |
| `/rewind` (alias `/undo`) | Pick earlier turn; file restore requires file rewind enabled at session start |
| `/exit` | Close current session; quit only when last session closes. `/exit print` exits CLI and offers transcript printing |

`/session info` opens a details view; press Enter to dismiss it.
`/session` opens the picker, not an edit/command audit.

---

## Exporting a Session

| Mechanism | Where it works |
|-----------|----------------|
| `/share` | Inside a conversation already in progress |
| `--share [path]` | Non-interactive run only |
| `--share-gist` | Non-interactive run only |

```bash
copilot -p "Explain this repo" --share ./out.md
copilot -p "Explain this repo" --share-gist
```

> `/share html` prints a `file://` URL; press `Ctrl+X O` to open it.
> `--share` / `--share-gist` share **that run's own** session once it completes —
> they cannot export a conversation from an earlier session

---

## Session Data on Disk

| Path | Contents |
|------|----------|
| `~/.copilot/session-state/<id>/` | Transcript, checkpoints, rewind snapshots |
| `~/.copilot/session-store.db` | Index used by `/session`, `/resume`, `--resume` |

`COPILOT_HOME` relocates the Copilot state directory, including session storage.

Manage it with subcommands, not `rm`:

```
/session info          # details about this session
/session checkpoints   # list checkpoints
/session files         # session workspace files, not all project edits
/session plan          # current plan
/session rename [name] # rename or auto-name
/session cleanup       # remove stale records
/session prune         # prune old session data
/session delete [id]   # delete one session
/session delete-all    # delete every session
```

---

## Resume & Identity Flags

```bash
copilot -n "auth-fix"                 # name a new session
copilot --resume                     # picker; optionally pass =ID, prefix, or name
copilot --continue                    # most recent session
copilot --connect                     # connect to remote session via picker
copilot --sync-session=on             # read-only account history, not control
copilot -p "Summarize" --silent       # response only, no stats
```

`--resume` also accepts task IDs and unique ID prefixes.
Use `copilot --session-id "$SESSION_ID"` for an exact ID after setting that variable;
`--connect=SESSION_ID` selects a particular remote session.

Sync uploads session data and defaults on when account policy permits.
For local-only exercises, append `--sync-session=off` to every invocation.
Gist/link sharing and remote activation are optional external actions.

---

## Directory Scope

```bash
# Check current directory
/cwd

# Change working directory
/cwd ~/my-project

# Add another directory
/add-dir ~/shared-libs

# List all accessible directories
/list-dirs
```

Path controls are heuristic, not OS isolation. Adding a root also trusts its skills/agents.

---

## When to Clear, Compact, or Start New

| Scenario | Action |
|-----------|--------|
| Switching to unrelated task | `/new` (keeps old session) or `/clear` (abandons) |
| Confused responses | `/new` |
| Context limit approaching | `/compact` first, then `/new` if needed |
| Sensitive info discussed | Stop sharing, rotate exposed secrets; handle persistent records separately |
| Session becomes slow | `/new` |

> `/clear` **abandons** the session — `/new` keeps it **backgrounded**

Neither guarantees forgetting: interactive memory defaults on; transcripts, logs,
exports, and synced history remain separate. Streamer mode hides selected UI metadata only.

---

## Optional Recovery and Hosting

- `/remote` shows status; `/remote on` requires configured incoming connections
- `/remote off` stops live remote control; view-only history sync still uploads data
- `--host-environment` / `--host-compute-id` describe headless hosted execution
- `copilot sessions import FILE --dry-run` validates session JSONL
- `copilot memories import FILE --dry-run` validates memory JSONL
- Imports/hosting are optional references; provisioning/runtime checks remain
- File rewind must be enabled at session start; otherwise only conversation rewind is available
- Rewind protects files you edited later; inspect the restore choice

---

## Your Turn! 🚀

Open **Module 11** in `docs/workshop/11-sessions.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Session persistence
- **Exercise 2** — Resume a session
- **Exercise 3** — Session slash commands
- **Exercise 4** — Working directory management
- **Exercise 5** — Active-context clearing, not privacy/erasure
- **Exercise 6** — Multiple sessions
- **Exercise 7** — Export & sharing

⏱️ You have **~12 minutes**
