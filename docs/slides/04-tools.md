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
| `apply_patch` / `create` / `edit` | Write files; patch operations may display as **Edit** | ⚠️ High |
| `view` | Read files, list directories | Low |
| `glob` / `grep` | Find files, search contents | Low |
| `semantic_code_search` | Search code by meaning when available | Low |
| `web_fetch` / `web_search` | Fetch and search the web | Medium |
| `fetch_copilot_cli_documentation` | Look up CLI documentation | Low |
| `task` / `read_agent` / `write_agent` / `list_agents` | Orchestrate subagents and messages | Varies |
| `skill` / `ask_user` | Load guidance / request clarification | Low |
| `sql` / `session_store_sql` | Query session and task state | Low |
| `run_dynamic_workflow` / `dynamic_workflows_manage` | Register and run workflows | Varies |
| MCP server tools | Contributed by configured servers | Varies |

Tool surfaces depend on the model, session, and availability filters.
Prompting depends on effective rules, existing approvals, mode, and policy.

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

> `/reset-allowed-tools` clears session tool/exact-path and saved location approvals and turns off allow-all.

> **Path approval is separate:** allow one access for the session, or add the
> path persistently. Tool permission does not automatically grant path access.

> `/rewind` lets you choose conversation-only or conversation-plus-files restoration.

---

## Permission Modes

`/permissions` switches the whole session at once:

| Mode | Behavior |
|------|----------|
| `manual` | Auto-approve reads; other requests follow effective rules |
| `assisted` | Safety judge auto-approves what it deems safe |
| `allow-all` | Auto-approve tools, paths, and URLs |
| `show` | Report the current mode |

```
/permissions
/permissions allow-all
/permissions show
/allow-all on|off|show
```

> `--assisted-approval` needs no experimental opt-in; explicit disable/policy can block it. Probabilistic judge, **not a security boundary**.

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

`write` does **not** cover shell invocations. Shell can modify/delete files;
for strict read/search analysis remove shell tools or enforce OS restrictions.

Allow rules do not force tool selection (`glob` may replace `ls`).
Verify tool traces and files, not exit codes. A new repo has no `git log` history.

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

# Strip named shell/MCP env vars and mask some outputs (not leak prevention)
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

## Command Sandboxing

A **third layer** on top of tool and path permissions

```
/sandbox            # status / policy dialog
/sandbox enable
/sandbox disable
```

```bash
copilot --sandbox   # start a session with it already on
```

Shell commands run inside an OS-level sandbox — restricted **filesystem**, **network**, and **credentials**

- Available to all users, disabled by default; no experimental prerequisite
- Microsoft Execution Containers (MXC): Seatbelt/`sandbox-exec` (macOS), bubblewrap/`bwrap` (Linux), ProcessContainer (Windows)
- Configured under `sandbox.*` in `~/.copilot/settings.json`
- Credentials use sentinels and approved-host HTTPS-header substitution, not arbitrary secret protection
- Exported environment credentials can still be inherited; strip sensitive values with `--secret-env-vars`
- Only local stdio MCP/LSP processes can be sandboxed; remote HTTP/SSE MCP servers are never sandboxed

> Linux needs network/user namespaces and helpers beyond `bwrap`. Docker alone is not proof. Managed bypass may be allowed or forbidden; bypass exposes host credentials. See `copilot help sandbox` and `copilot sandbox ca --help`.

---

## Trust and Secret Safety

- `/add-dir` / `--add-dir` add file access **and trust skills/agents** in that root
- `/list-dirs` reports effective roots (including plugin roots), not just cwd, `/tmp`, or saved startup trust
- `--trust-folder` admits cwd config for one new non-interactive prompt-mode session (`-p` or piped input), not interactive startup or all permissions
- Exact `COPILOT_ALLOW_ALL=true` also trusts executable cwd configuration
- `--secret-env-vars` cannot prevent secrets arriving by other tool-result routes
- Read selected fields only; raw settings/MCP JSON can contain credentials

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

## Verify Automation Inputs

Include the diff explicitly in the `-p` prompt:

```bash
copilot --sync-session=off -p "Review this diff: $(git diff)" \
  --available-tools view,glob,grep --deny-tool write
```

**Removal candidate (inactive):** `git diff | copilot -p "Review..."`.
Piped stdin is not a substitute for including the diff in an explicit prompt.

An exit code of zero or “no issues” is not proof that the diff was reviewed.
Read/search tool filters hide shell; retained shell allow rules do not expose it.

---

## Your Turn! 🚀

Open **Module 4** in `docs/workshop/04-tools.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Understanding tool prompts
- **Exercise 2** — Shell command approval
- **Exercise 3** — `--allow-tool` flag
- **Exercise 4** — `--deny-tool` flag
- **Exercise 5** — YOLO mode
- **Exercise 6** — Startup trust, added-root configuration trust, selected inspection
- **Exercise 7** — Read/search automation with shell hidden; CLI can still persist logs

⏱️ You have **~16 minutes**
