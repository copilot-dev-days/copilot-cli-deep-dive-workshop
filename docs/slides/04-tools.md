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

# Module 4: Tools & Permissions

### GitHub Copilot CLI Workshop

---

## Built-in Tools

| Tool | Purpose | Risk |
|------|---------|------|
| `bash` | Execute shell commands; manage background work with `read_bash`, `list_bash`, `stop_bash` | ⚠️ High |
| `create` / `edit` | Create and modify files | ⚠️ High |
| `view` | Read files, list directories | Low |
| `glob` / `grep` | Find files, search contents | Low |
| `web_fetch` / `web_search` | Fetch and search the web | Medium |
| `fetch_copilot_cli_documentation` | Look up CLI documentation | Low |
| `task` / `read_agent` / `write_agent` / `list_agents` | Orchestrate subagents and messages | Varies |
| `skill` / `ask_user` | Load guidance / request clarification | Low |
| `sql` / `session_store_sql` | Query session and task state | Low |
| `run_dynamic_workflow` / `dynamic_workflows_manage` | Register and run workflows | Varies |
| MCP server tools | Contributed by configured servers | Varies |

Every destructive action **requires your approval**

---

## Tools ≠ Permission Kinds

Permission rules match **kinds**, not tool names:

| Kind | Matches |
|------|---------|
| `shell(command)` | Shell commands run by the `bash` tool |
| `write(path)` | File creation and modification |
| `<mcp-server-name>(tool-name)` | Tools from an MCP server |
| `url(domain-or-url)` | URL access |

```bash
copilot --allow-tool 'shell(git:*)' --deny-tool 'shell(git push)'
```

> Filter by *tool name* with `--available-tools` / `--excluded-tools`

---

## Approval Workflow

Three choices when Copilot wants to use a tool:

| Option | Scope | Use when... |
|--------|-------|-------------|
| **Yes** | This one time | Cautious, first use |
| **Yes, for session** | Rest of session | Trusted, repeated tool |
| **No** | Denied | Dangerous or wrong |

> Use `/reset-allowed-tools` to clear session approvals

> **Path approval is separate:** allow one access for the session, or add the
> path persistently. Tool permission does not automatically grant path access.

> ⚠️ Undo operations always require confirmation before applying

---

## Permission Modes

`/permissions` switches the whole session at once:

| Mode | Behavior |
|------|----------|
| `manual` | Approve every request |
| `assisted` | Safety judge auto-approves what it deems safe |
| `allow-all` | Auto-approve tools, paths, and URLs |
| `show` | Report the current mode |

```
/permissions
/permissions allow-all
/permissions show
/allow-all on|off|show
```

> `assisted` needs the experimental auto-approval feature; request the same judge at launch with `--assisted-approval` (env: `COPILOT_ASSISTED_APPROVAL`)

---

## --allow-tool & --deny-tool

Pre-approve or block tools for **programmatic mode**

```bash
# Allow specific commands
copilot -p "Show git status" --allow-tool 'shell(git status)'

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
copilot --allow-all-urls
# Protocol matters: https://example.com and http://example.com differ

# URL pattern in tool permissions
copilot --allow-tool 'url(https://api.github.com)'

# Path controls
copilot --add-dir ~/other-project
copilot --allow-all-paths
copilot --disallow-temp-dir

# Redact sensitive env vars
copilot --secret-env-vars=MY_API_KEY

# Fully autonomous (no questions)
copilot --no-ask-user --allow-all
```

---

## Risk Categories

Review approvals by impact: **read-only** → **git read** → **git write** →
**file modify** → **file delete** → **system command**.

Broader permission is not broader visibility: keep dangerous tools hidden or
denied even when low-risk reads are session-approved.

---

## Command Sandboxing 🧪

A **third layer** on top of tool and path permissions

```
/sandbox            # status / policy dialog
/sandbox enable
/sandbox disable
```

```bash
copilot --experimental --sandbox   # start a session with it already on
```

Shell commands run inside an OS-level sandbox — restricted **filesystem**, **network**, and **credentials**

- Experimental: `/sandbox` registers with `--experimental`, `/settings experimental on`, or a policy that forces sandboxing on
- Microsoft Execution Containers (MXC): Seatbelt/`sandbox-exec` (macOS), bubblewrap/`bwrap` (Linux), ProcessContainer (Windows)
- Configured under `sandbox.*` in `~/.copilot/settings.json`
- `sandbox.auth.git` / `sandbox.auth.gh` deliberately inject credentials only while sandboxing is enabled
- Exported environment credentials can still be inherited; strip sensitive values with `--secret-env-vars`
- Only local stdio MCP/LSP processes can be sandboxed; remote HTTP/SSE MCP servers are never sandboxed

> `--sandbox` is not listed in `copilot --help` — `copilot help sandbox` has the full reference

---

## ⚠️ Never Print `config.json`

```bash
# DON'T: this prints your live auth token
cat ~/.copilot/config.json

# DO: read only the key you need
grep -v '^[[:space:]]*//' ~/.copilot/config.json \
  | jq -r '.trustedFolders[]?'
```

- `~/.copilot/config.json` — **managed automatically**, holds credentials and `trustedFolders`
- `~/.copilot/settings.json` — **your settings**; edit with `/settings`

Especially important while screen-sharing

---

## Your Turn! 🚀

Open **Module 4** in `docs/workshop/04-tools.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Understanding tool prompts
- **Exercise 2** — Shell command approval
- **Exercise 3** — `--allow-tool` flag
- **Exercise 4** — `--deny-tool` flag
- **Exercise 5** — YOLO mode
- **Exercise 6** — Trusted directories (+ safe config inspection)
- **Exercise 7** — Safe automation script

⏱️ You have **~16 minutes**
