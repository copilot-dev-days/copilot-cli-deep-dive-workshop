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

# Module 3: Session Management

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
copilot    prompts + tools    /exit or Ctrl+C
  │               │               │
  └───── Session persists ────────┘
                  │
          copilot --resume    ← pick up later
```

---

## Key Session Commands

| Command | What it does |
|---------|-------------|
| `/session` | Show session info (ID, duration, files) |
| `/usage` | Token consumption and API calls |
| `/rename NAME` | Name your session for easy finding |
| `/clear` | Wipe conversation history |
| `/resume` | Switch to a previous session |
| `--resume` | Resume last session from CLI |
| `/share` | Export to markdown or GitHub Gist |

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

Copilot can only access directories you've allowed

---

## When to Clear vs Compact

| Situation | Action |
|-----------|--------|
| Switching to unrelated task | `/clear` |
| Confused or wrong responses | `/clear` |
| Context getting full | `/compact` first |
| Sensitive info discussed | `/clear` + `/exit` |
| Session becoming slow | `/clear` |

---

## Your Turn! 🚀

Open **Module 11** in `docs/workshop/11-sessions.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Session persistence
- **Exercise 2** — Resume a session
- **Exercise 3** — Session slash commands
- **Exercise 4** — Working directory management
- **Exercise 5** — Clearing strategies
- **Exercise 6** — Multiple sessions
- **Exercise 7** — Export & sharing

⏱️ You have **~12 minutes**

