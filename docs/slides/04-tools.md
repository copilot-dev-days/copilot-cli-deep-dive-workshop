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

# Module 5: Tools & Permissions

### GitHub Copilot CLI Workshop

---

## Built-in Tools

| Tool | Purpose | Risk |
|------|---------|------|
| `shell` | Execute shell commands | ⚠️ High |
| `write` | Create/modify files | ⚠️ High |
| `read` | Read file contents | Low |
| `show_file` | Present code/diffs to user | Low |
| `web_fetch` | Fetch web content | Medium |
| `mcp` | Use MCP server tools | Varies |

Every destructive action **requires your approval**

---

## Approval Workflow

Three choices when Copilot wants to use a tool:

| Option | Scope | Use when... |
|--------|-------|-------------|
| **Yes** | This one time | Cautious, first use |
| **Yes, for session** | Rest of session | Trusted, repeated tool |
| **No** | Denied | Dangerous or wrong |

> Use `/reset-allowed-tools` to clear session approvals

> ⚠️ Undo operations now always require confirmation — they no longer auto-apply

---

## --allow-tool & --deny-tool

Pre-approve or block tools for **programmatic mode**

```bash
# Allow specific commands
copilot -p "Show git status" --allow-tool 'shell(git)'

# Allow writes
copilot -p "Create README" --allow-tool 'write'

# Deny takes precedence over allow
copilot -p "Analyze project" \
 --allow-all-tools \
 --deny-tool 'shell(rm)' \
 --deny-tool 'write'
```

---

## YOLO Mode ⚡

```bash
copilot --yolo -p "Set up a Node.js project"
```

**No prompts. Full autonomy.** Use only in:

- ✅ Docker containers
- ✅ Disposable dev environments
- ✅ CI/CD with controlled scope
- ✅ Codespaces that can be reset

**Never** in production or with important data

---

## URL & Path Permissions

```bash
# Allow/deny URL access
copilot --allow-url github.com --deny-url malicious-site.com

# URL pattern in tool permissions
copilot --allow-tool 'url(https://api.github.com)'

# Path controls
copilot --add-dir ~/other-project
copilot --disallow-temp-dir

# Redact sensitive env vars
copilot --secret-env-vars MY_API_KEY

# Fully autonomous (no questions)
copilot --no-ask-user --allow-all-tools
```

---

## New in v1.0.4–v1.0.6

- **One-time path approval** — grant path access for current session only, without modifying config (v1.0.4)
- **Dynamic tool search** — Claude models discover and use tools automatically (v1.0.6)
- **`/reset-allowed-tools`** now fully undoes `/allow-all` (v1.0.3)

---

## Your Turn! 🚀

Open **Module 4** in `docs/workshop/04-tools.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Understanding tool prompts
- **Exercise 2** — Shell command approval
- **Exercise 3** — `--allow-tool` flag
- **Exercise 4** — `--deny-tool` flag
- **Exercise 5** — YOLO mode
- **Exercise 6** — Trusted directories
- **Exercise 7** — Safe automation script

⏱️ You have **~16 minutes**

