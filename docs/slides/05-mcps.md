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

# Module 5: MCP Servers

### GitHub Copilot CLI Workshop

---

## What is MCP?

**Model Context Protocol** — an open standard that gives Copilot **tools, prompts, and resources**

```
┌─────────────┐ ┌─────────────┐ ┌─────────────────┐
│ Copilot CLI │────>│ MCP Server │────>│ External Tools │
│ │<────│ │<────│ & Resources │
└─────────────┘ └─────────────┘ └─────────────────┘
```

Connect Copilot to: databases, APIs, file systems, search, Slack, and more

---

## Debugging MCP Servers

Errors appear in session output and server details for startup, connection,
configuration, and tool-call failures.

```text
/mcp show <name>     # status, errors, tools
/mcp reload          # restart after config changes
/mcp auth <name>     # repeat remote authentication
```

Remote HTTP/SSE servers retry transient timeouts, DNS failures, and server
errors. OAuth can fall back to a self-signed HTTPS redirect when the identity
provider requires HTTPS.

---

## Three Types of MCP Servers

| Type | Protocol | Where it runs | Example |
|------|----------|--------------|---------|
| **Built-in** | N/A | Included with Copilot | GitHub (issues, PRs, repos) |
| **Remote** | `http` / `sse` | Hosted externally | Cloud APIs, team services |
| **Local** | `local` / `stdio` | Your machine | Memory, filesystem, Postgres |

> `copilot mcp add` uses `stdio`, `http`, and `sse` transport names

---

## Configuration

Lives at **`~/.copilot/mcp-config.json`**

```json
{
 "mcpServers": {
 "memory": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-memory"]
 },
 "exa": { "type": "http", "url": "https://mcp.exa.ai/mcp" }
 }
}
```

**Local** → `"type": "local"` + `command`/`args` | **Remote** → `"type": "http"` + `url`
Optional: `"tools": ["*"]` (default), `"env": {}`, `"headers": {}`

> Server names support npm-style identifiers like `@modelcontextprotocol/server`.
> Workspace config can live in `.mcp.json` or `.github/mcp.json`; `COPILOT_HOME` moves user config.

Only environment variables referenced by `command`, `args`, or `cwd` inherit
from the shell; declare every other server variable explicitly in `env`.

---

## Enterprise Security

> **Policy Enforcement:**
> Org admins can **block third-party MCP servers** via policy.
> Blocked servers won't start or connect. Requires Copilot Business/Enterprise.

---

## Built-in GitHub MCP

**Already built in** — no setup needed

```
> What are the open issues in this repository?
> Show me recent pull requests
> What changed in the last commit?
```

Copilot uses GitHub MCP tools automatically

- Timeline entries summarize each MCP tool name and parameters
- MCP sampling requests (server-requested LLM inference) require user approval

> It appears in the in-session `/mcp` view, not in `copilot mcp list`

---

## Popular MCP Servers

| Server | Package / URL | What it does |
|--------|---------------|-------------|
| Exa | `https://mcp.exa.ai/mcp` (remote) | Web search, code search |
| Memory | `server-memory` | Remember things across sessions |
| Filesystem | `server-filesystem` | Structured file access |
| PostgreSQL | `server-postgres` | Query databases |
| Slack | `@modelcontextprotocol/server-slack` | Team messages and search |
| Brave Search | `@anthropic/mcp-server-brave-search` | Web search |

Full list: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)

---

## Managing MCP Servers

Use shell commands or the interactive `/mcp` view:

| Command | Action |
|---------|--------|
| `copilot mcp list` | List configured servers (built-ins not shown) |
| `copilot mcp get NAME` | View server details |
| `copilot mcp add NAME -- COMMAND` | Add local stdio server |
| `copilot mcp add --transport http NAME URL` | Add remote HTTP server |
| `copilot mcp remove NAME` | Remove a server |
| `/mcp` | Open interactive MCP view |

> Use `--additional-mcp-config @file.json` for session-only servers.
> `mcp add` also supports `--env`, `--header`, `--timeout`, `--tools`, `--json`, and `--show-secrets`.

---

## `/mcp` Subcommands

The interactive view also takes subcommands:

| Command | Action |
|---------|--------|
| `/mcp list` | List attached servers and status |
| `/mcp show <name>` | Server details and available tools |
| `/mcp add` / `/mcp edit <name>` | Interactive add/edit wizard |
| `/mcp enable` / `/mcp disable <name>` | Toggle a server (persists) |
| `/mcp delete <name>` | Delete a server |
| `/mcp reload` | Reload config and restart servers |
| `/mcp auth <name>` | Authenticate with a remote server |
| `/mcp search [query]` | Search the MCP registry |

---

## GitHub MCP Server Controls

```bash
# Add specific tools/toolsets
copilot --add-github-mcp-tool "create_issue"
copilot --add-github-mcp-toolset "repos"

# Enable ALL GitHub MCP tools
copilot --enable-all-github-mcp-tools

# Disable built-in servers
copilot --disable-builtin-mcps
copilot --disable-mcp-server "my-server"

# Re-enable a disabled server for this run only
copilot --enable-mcp-server "my-server"
```

---

## Workspace MCP Config

MCP servers can be pre-configured in `.mcp.json` or `.github/mcp.json`:

```json
{
  "mcpServers": {
    "memory": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

Merged with personal and plugin MCP configuration automatically

---

## Your Turn! 🚀

Open **Module 5** in `docs/workshop/05-mcps.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Explore GitHub MCP
- **Exercise 2** — Remote MCP server
- **Exercise 3** — Local MCP server
- **Exercise 4** — File system MCP
- **Exercise 5** — MCP management commands
- **Exercise 6** — MCP tools with permissions
- **Exercise 7** — Temporary MCP config

⏱️ You have **~12 minutes**
