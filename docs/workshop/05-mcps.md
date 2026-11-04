# Module 5: MCP Servers

## Prerequisites

- Completed Modules 1-4
- Understanding of JSON configuration
- Node.js and npm installed

## Learning Objectives

- Understand the Model Context Protocol (MCP)
- Configure remote and local MCP servers
- Use the GitHub MCP server for repository operations
- Add custom MCP servers to extend Copilot's capabilities
- Manage MCP servers with slash commands

## Concepts

### What is MCP?

Model Context Protocol (MCP) is an open standard that extends AI capabilities:

```
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ Copilot CLI │────▶│ MCP Server │────▶│ External │
│ │ │ │ │ Resources │
└─────────────┘ └─────────────┘ └─────────────┘
 │
 ┌──────┴──────┐
 │ Tools │
 │ Prompts │
 │ Resources │
 └─────────────┘
```

### Debugging MCP Servers

MCP server errors surface directly in session output and in MCP server details, making it easier to diagnose connection and configuration issues. Errors are displayed when:
- A server fails to start
- A connection cannot be established
- A tool invocation fails
- Configuration is invalid

Use `/mcp` inside a session or `copilot mcp list` / `copilot mcp get <name>` from your shell to inspect configured servers and their status. `/mcp reload` restarts servers after you change configuration, and `/mcp auth <name>` re-runs authentication for a remote server.

### Server Types

| Type | Protocol Name | Location | Use Case |
|------|---------------|----------|----------|
| Remote (HTTP) | `http` | Hosted externally | Team-wide tools, cloud services |
| Remote (SSE) | `sse` | Hosted externally | HTTP+SSE transport |
| Local (STDIO) | `local` or `stdio` | Runs on your machine | Local resources, custom tools |
| Built-in | N/A | Included with Copilot | GitHub integration |

> **Note:** `local` and `stdio` are equivalent in Copilot CLI configuration. The `copilot mcp add` command uses the transport names `stdio`, `http`, and `sse`.

### Configuration Location

> **Note:** Copilot CLI reads MCP configuration from:
> - `~/.copilot/mcp-config.json` (user-level)
> - `.mcp.json` (project-level, in repository root)
> - `.github/mcp.json` (workspace-level)
> - Installed plugins that bundle MCP servers

MCP servers are configured in:
- Default: `~/.copilot/mcp-config.json` (user) or `.mcp.json` (project)
- Custom: Set via `COPILOT_HOME`

Workspace and plugin MCP servers are merged with your personal `~/.copilot/mcp-config.json` configuration.

### Workspace MCP Configuration

Workspace MCP configuration can live in `.mcp.json` or `.github/mcp.json`:

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

### Enterprise Policy Enforcement

> [!IMPORTANT]
> Organization administrators can block third-party MCP servers via policy enforcement. When a policy is active, users in the organization will be prevented from connecting to MCP servers that are not on the allow-list. This is enforced at the CLI level — blocked servers will not start or connect.

> MCP policy enforcement requires a Copilot Enterprise or Business subscription with organization-level policy management. Behavior may vary depending on how your org admin has configured the policy.

### `copilot mcp` CLI Command

> The `copilot mcp` top-level command lets you manage MCP servers directly from the command line without starting an interactive session:
>
> ```text
> # List configured MCP servers
> copilot mcp list
>
> # Add a local stdio server
> copilot mcp add context7 -- npx -y @upstash/context7-mcp
>
> # Add a remote HTTP server
> copilot mcp add --transport http notion https://mcp.notion.com/mcp
>
> # Add a remote server with auth header
> copilot mcp add --transport http --header "Authorization: Bearer token" stripe https://mcp.stripe.com
>
> # Removal candidate: @modelcontextprotocol/server-github is not supported;
> # do not install it. Use the built-in github-mcp-server instead.
> copilot mcp get github-mcp-server
>
> # Remove an MCP server
> copilot mcp remove memory
>
> # Show details for a specific server
> copilot mcp get memory
> ```
>
> Additional options for `mcp add`: `--transport` (stdio/http/sse), `--env` (repeatable), `--header` (repeatable), `--timeout`, `--tools` (filter), `--json`, and `--show-secrets`.
>
> This is useful for scripting MCP configuration and managing servers in CI/CD environments.

> **Removal candidate — original unsupported package example, do not run:**
> ```text
> copilot mcp add github --env GITHUB_PERSONAL_ACCESS_TOKEN=github_pat_xxx -- npx -y @modelcontextprotocol/server-github
> ```
> Use the built-in `github-mcp-server` instead. Header/env examples are schematic; prefer interactive secret entry and never put real credentials in shared shell history or process arguments.

### MCP Remote Server Auto-Retry

Remote MCP servers (HTTP/SSE) retry transient network failures such as connection timeouts, temporary DNS failures, and HTTP 5xx errors before surfacing the error.

### MCP OAuth HTTPS Redirect

MCP servers using OAuth authentication support HTTPS redirect URIs via a self-signed certificate fallback. This enables OAuth flows in environments where only HTTPS redirect URIs are permitted by the identity provider.

### Built-in GitHub MCP Server Controls

Copilot CLI includes a built-in GitHub MCP server with a default subset of tools. You can customize which tools are available:

```bash
# Select explicit tools instead of the default subset
copilot --add-github-mcp-tool "issue_write"

# Select a toolset instead of the default subset
copilot --add-github-mcp-toolset "repos"

# Enable ALL GitHub MCP tools (overrides --add-github-mcp-tool/toolset)
copilot --enable-all-github-mcp-tools

# Disable the built-in GitHub MCP server entirely
copilot --disable-builtin-mcps

# Disable a specific MCP server by name
copilot --disable-mcp-server "my-custom-server"

# Re-enable a server that settings disable, for this run only
copilot --enable-mcp-server "my-custom-server"
```

Use `--add-github-mcp-tool "*"` or `--add-github-mcp-toolset "all"` to enable everything. Explicit tool/toolset selections replace the default subset; inspect the resulting inventory rather than assuming defaults remain. The `--disable-mcp-server` flag works for any MCP server (built-in or configured), and can be used multiple times. Its counterpart, `--enable-mcp-server`, turns a server that your settings disable back on for that run only — nothing is persisted — and it is also repeatable.

Inspect `/mcp show github-mcp-server` for the actual tool inventory; notifications/issues may need additional toolsets. `copilot mcp enable NAME` and `disable NAME` persist settings, unlike launch-time flags.

Issue and pull-request **listing** is not guaranteed in the default subset. For Exercise 1's listing prompts, launch with `copilot --add-github-mcp-toolset issues --add-github-mcp-toolset pull_requests` and verify the corresponding tools are connected. Repository-content access alone does not demonstrate issue/PR listing.

For an explicitly configured session server, `--mcp-github-auth <server=origin>` approves sending the signed-in account credential to that destination. Use HTTPS (literal loopback HTTP is the exception); never put a token in this argument. `--allow-all-mcp-server-instructions` trusts instructions from all MCP servers: review those servers before broadening instruction trust.

## Hands-On Exercises

### Exercise 1: Explore the GitHub MCP Server

**Goal:** Use the built-in GitHub MCP server.

**Steps:**

1. Start Copilot:
 ```bash
 copilot
 ```

2. View current MCP configuration:
 ```
 /mcp
 ```

 > The in-session MCP view lists servers by source — user, workspace, plugin, and built-in — so the built-in GitHub MCP server shows up here.

3. The GitHub MCP server is built in and ready to use without any configuration. Try it:
 ```
 What are the open issues in this repository?
 ```

4. If you have a GitHub repository:
 ```
 Show me the recent pull requests
 ```

5. GitHub MCP provides tools for:
 - Viewing issues and PRs
 - Reading repository content
 - Accessing organization info
 - Interacting with GitHub resources

**Expected Outcome:**
Copilot can access GitHub resources through the built-in MCP server.

> [!TIP]
> Manually editing `~/.copilot/mcp-config.json` is straightforward. The command structure for MCP config follows the standard MCP specification. Verify the JSON syntax is valid before restarting Copilot.

### Exercise 2: Configure a Remote MCP Server

**Goal:** Add a remote MCP server (Exa search).

[Exa](https://exa.ai) provides AI-powered web search and page fetching through a remote MCP server. Code search and company research depend on the tools actually exposed by the endpoint; do not assume dedicated tools are available.

**Steps:**

1. Inspect server names/types without displaying credentials:
 ```bash
 copilot mcp list
 ```

2. Add the server with `copilot mcp add`:
 ```bash
 copilot mcp add --transport http exa https://mcp.exa.ai/mcp
 ```

3. Verify the configuration:
 ```bash
 copilot mcp get exa
 ```

4. To compare file-based setup, create a dedicated session file (do not overwrite personal configuration; the same-name session definition takes effect for this launch):
 ```bash
 test ! -e workshop-exa-mcp.json &&
 cat > workshop-exa-mcp.json << 'EOF'
 {
 "mcpServers": {
 "exa": {
 "type": "http",
 "url": "https://mcp.exa.ai/mcp",
 "tools": ["*"]
 }
 }
 }
 EOF
 ```

 > **Note:** Exa's default public web-search and page-fetch tools don't require authentication. Inspect the discovered inventory before trying code search, company research, or other optional capabilities; authentication and availability depend on the tool and service.
 >
 > Load this file with `copilot --additional-mcp-config @workshop-exa-mcp.json` and inspect `/mcp` in that session. For persistent setup prefer `copilot mcp add`, which preserves unrelated entries.

5. Test the Exa search tools:
 ```bash
 copilot --additional-mcp-config @workshop-exa-mcp.json
 ```
 ```
 Search the web for current GitHub Copilot CLI features
 ```

**Expected Outcome:**
Remote Exa MCP server configured. Copilot can perform web searches and fetch pages via the discovered Exa tools. Code search and company research require suitable exposed tools or search queries; configuration success alone does not prove those capabilities.

### Exercise 3: Add a Local MCP Server

**Goal:** Configure a locally-running MCP server.

**Steps:**

1. Install the MCP memory server:
 ```bash
 npm install --ignore-scripts --no-save --package-lock=false @modelcontextprotocol/server-memory
 ```

2. Create a dedicated session config; existing user entries remain untouched:
 ```bash
 test ! -e workshop-memory-mcp.json &&
 cat > workshop-memory-mcp.json << 'EOF'
 {
 "mcpServers": {
 "exa": {
 "type": "http",
 "url": "https://mcp.exa.ai/mcp",
 "tools": ["*"]
 },
 "memory": {
 "type": "local",
 "command": "npx",
 "args": [
 "-y",
 "@modelcontextprotocol/server-memory"
 ],
 "env": {
 "MEMORY_FILE_PATH": "/workspace/workshop-memory.jsonl"
 },
 "tools": ["*"]
 }
 }
 }
 EOF
 ```

 Replace `/workspace` with your absolute disposable exercise directory if needed. The memory server persists its graph at `MEMORY_FILE_PATH`; keep that path stable to share memory across server restarts. Session-only **configuration** does not mean session-only **data**. Without an explicit path, the package chooses its own default storage location.

 > **Note:** Shell variables can be expanded in `command`, `args`, and `cwd`. Configure required server variables explicitly in `"env"` for reproducibility. Do not treat unreferenced variables as isolated: local server processes can inherit other shell variables. Start Copilot with a sanitized environment when isolation is required.

3. Start Copilot with that file:
 ```bash
 copilot --additional-mcp-config @workshop-memory-mcp.json
 ```

4. Verify in the same session:
 ```text
 /mcp
 ```

5. Test the memory server:
 ```
 Using the memory server's create_entities tool, remember that my favorite programming language is Rust
 ```

6. Later in the session:
 ```
 Using the memory server's search_nodes tool, what's my favorite programming language?
 ```

**Expected Outcome:**
Local MCP server runs and provides additional capabilities. Verify actual create/search tool calls, then restart with the same config and confirm Rust is retrieved from the graph file rather than conversation history.

### Exercise 4: File System MCP Server

**Goal:** Add an MCP server for enhanced file operations.

**Steps:**

1. Install the filesystem MCP server:
 ```bash
 npm install --ignore-scripts --no-save --package-lock=false @modelcontextprotocol/server-filesystem
 ```

 > **Note:** The `~/projects` directory must exist before the filesystem server can start. Create it first with `mkdir -p ~/projects` if needed.

2. Create a separate config with directory restrictions (preserve your existing entries):
 ```bash
 test ! -e workshop-filesystem-mcp.json &&
 cat > workshop-filesystem-mcp.json << 'EOF'
 {
 "mcpServers": {
 "exa": {
 "type": "http",
 "url": "https://mcp.exa.ai/mcp",
 "tools": ["*"]
 },
 "filesystem": {
 "type": "local",
 "command": "npx",
 "args": [
 "-y",
 "@modelcontextprotocol/server-filesystem",
 "/home/user/projects"
 ],
 "cwd": "/home/user/projects",
 "tools": ["*"]
 }
 }
 }
 EOF
 ```

 Replace `/home/user/projects` with an absolute path on your machine.


3. Restart Copilot:
 ```bash
 copilot --additional-mcp-config @workshop-filesystem-mcp.json
 ```

4. Check for any MCP server errors:
 ```
 /mcp
 ```

 If there are configuration issues, server status will indicate errors here.

5. Test file operations through MCP:
 ```
 Using the filesystem server, list all TypeScript files in my projects
 ```

**Expected Outcome:**
MCP server provides structured file access with defined boundaries. Any startup errors are visible in the MCP view.

### Exercise 5: MCP Server Management Commands

**Goal:** Master MCP management through the CLI command and interactive MCP view.

**Steps:**

1. **List all servers:**
   Register a persistent exercise server first; Exercise 3's additional configuration applies only to its own session. If `workshop-memory` already exists, inspect it rather than replacing it.
 ```bash
 copilot mcp add workshop-memory -- npx -y @modelcontextprotocol/server-memory
 copilot mcp list
 ```

 > This reports user, workspace, plugin, and **builtin** sources, including `github-mcp-server`. Disabled servers/policy can affect status; “no servers” is not a universal clean-machine outcome.

2. **Show details for a server:**
 ```bash
 copilot mcp get workshop-memory
 ```

3. **Add a new local server:**
 ```bash
 copilot mcp add context7 -- npx -y @upstash/context7-mcp
 ```

4. **Add a remote server with a header (optional; requires your own authorized Stripe token):**
 ```bash
 : "${TOKEN:?Set TOKEN privately to an authorized Stripe token before running this optional example}"
 copilot mcp add --transport http \
   --header "Authorization: Bearer $TOKEN" \
   stripe https://mcp.stripe.com
 ```

5. **Use selected JSON fields for scripts:**
 ```bash
 copilot mcp list --json | jq '.mcpServers | to_entries | map({name: .key, source: .value.source, type: .value.type})'
 copilot mcp get workshop-memory --json | jq 'to_entries | map({name: .key, source: .value.source, type: .value.type}) | .[]'
 ```

 > Raw MCP JSON may contain unmasked environment/header secrets. Do not print or share it, and avoid `--show-secrets` in a workshop.

6. **Remove a server:** remove the disposable Context7 entry, leaving `workshop-memory` available for the interactive steps.
 ```bash
 copilot mcp remove context7
 ```

7. **Open the interactive MCP view inside a session:**
 ```bash
 copilot
 ```
 ```
 /mcp
 ```

8. **Drive the same view with subcommands:**
 ```
 /mcp list
 /mcp show workshop-memory
 /mcp disable workshop-memory
 /mcp enable workshop-memory
 /mcp reload
 ```

**Expected Outcome:**
You can manage MCP servers without editing config files and inspect them interactively.

### Exercise 6: Using MCP Tools with Permissions

**Goal:** Control MCP tool access with allow/deny flags.

**Steps:**

1. Allow specific MCP server in programmatic mode:
 ```bash
 copilot -p "Use only built-in GitHub MCP tools to check my notifications if an available tool supports them; otherwise report the missing tool. Do not use shell, web search, or other tools." \
 --allow-tool 'github-mcp-server'
 ```

2. Allow all MCP tools:
 ```bash
 copilot -p "Using memory create_entities, store my favorite programming language as Rust" \
 --additional-mcp-config @workshop-memory-mcp.json \
 --allow-tool 'memory'
 ```

3. Deny specific MCP server while allowing others:
 ```bash
 copilot -p "Analyze the project read-only; do not edit files, run programs, or contact services" \
 --allow-all-tools \
 --deny-tool 'github-mcp-server'
 ```

4. Combine with other tool permissions:
 ```bash
 copilot -p "Review code read-only and check GitHub issues if an available GitHub MCP tool supports it; otherwise report the missing tool. Do not write files or mutate external resources." \
 --allow-tool 'shell(cat)' \
 --allow-tool 'github-mcp-server' \
 --deny-tool 'write'
 ```

**Expected Outcome:**
MCP server tools follow the same permission model as built-in tools.

Without preapproval, programmatic mode cannot answer a permission prompt: a tool may be denied even when the process exits successfully. Low-risk calls can be prompted or preapproved; destructive calls require approval or are blocked. Check the tool timeline and actual effects, not just the exit code. Keep destructive permission tests confined to disposable fixtures.

### Exercise 7: Temporary MCP Configuration

**Goal:** Use additional MCP servers for specific sessions.

**Steps:**

1. Create a temporary MCP config as JSON:
 ```bash
 TEMP_MCP_CONFIG=$(mktemp)
 cat > "$TEMP_MCP_CONFIG" << 'EOF'
 {
 "mcpServers": {
 "microsoft-learn": {
 "type": "http",
 "url": "https://learn.microsoft.com/api/mcp"
 }
 }
 }
 EOF
 ```

 > **Note:** The [Microsoft Learn MCP Server](https://github.com/microsoftdocs/mcp) is free and requires no API key. It provides tools for searching Microsoft docs, fetching documentation pages, and finding code samples.

2. Start Copilot with the additional config:
 ```bash
 copilot --additional-mcp-config "@$TEMP_MCP_CONFIG"
 ```

3. The temporary servers are available for this session only.

4. Verify in the process launched with the temporary config:
 ```text
 /mcp
 /env
 ```

5. The base config + temporary config are merged.

6. Test it:
 ```
 Search Microsoft Learn for how to create an Azure Container App with managed identity
 ```

 After exiting, remove only this exercise's temporary file: `rm -- "$TEMP_MCP_CONFIG"`.

**Expected Outcome:**
Additional MCP servers can be loaded per-session without modifying base config.

## MCP Configuration Reference

### Server Naming

MCP server names (the keys in `"mcpServers"`) support dots (`.`), slashes (`/`), and `@` characters. This enables npm-style names directly as server identifiers:

```json
{
 "mcpServers": {
 "@modelcontextprotocol/server-memory": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-memory"]
 }
 }
}
```

> npm-style server names may have specific character requirements. Verify server name format with `copilot --help`.

### Remote Server Schema

```json
{
 "mcpServers": {
 "server-name": {
 "type": "http",
 "url": "https://example.com/mcp/",
 "headers": {
 "Authorization": "Bearer ${GITHUB_TOKEN}"
 },
 "tools": ["*"]
 }
 }
}
```

### Local Server Schema

```json
{
 "mcpServers": {
 "server-name": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@package/server-name"],
 "env": {
 "API_KEY": "${ENV_VAR}"
 },
 "cwd": "~/projects/my-server",
 "tools": ["*"]
 }
 }
}
```

> **Note:** Shell variables can be expanded in `command`, `args`, and `cwd`. Configure required variables explicitly in `"env"` for reproducibility, but do not assume that excludes other shell variables from local child processes. Sanitize the launching environment when isolation is required. The `"tools"` field defaults to `["*"]` (all tools) if omitted. You can restrict to specific tools with a list of tool names.

### Common MCP Servers

| Server | Package | Purpose |
|--------|---------|---------|
| Memory | `@modelcontextprotocol/server-memory` | Persistent memory |
| Filesystem | `@modelcontextprotocol/server-filesystem` | File operations |
| GitHub | Built-in | GitHub integration |
| Exa | `https://mcp.exa.ai/mcp` (remote) | Web search and page fetching; inspect available tools for code search/company research |
| PostgreSQL | **Removal candidate:** `@modelcontextprotocol/server-postgres` | Package is not supported; no workshop database fixture. Review a maintained integration before use |
| Slack | **Removal candidate:** `@modelcontextprotocol/server-slack` | Package is not supported; choose an administrator-approved maintained integration |
| Brave Search | **Removal candidate:** `@anthropic/mcp-server-brave-search` | Package does not exist; use the Exa remote search exercise instead |

### Slash Commands

`/mcp` accepts subcommands as well as opening the interactive view:

| Command | Description |
|---------|-------------|
| `/mcp` (or `/mcp show`) | Open the MCP server configuration and status interface |
| `/mcp list` (or `/mcp ls`) | List attached MCP servers and their status |
| `/mcp show <server-name>` | Show server details and available tools |
| `/mcp add [server-name]` | Add a new MCP server (interactive wizard) |
| `/mcp edit <server-name>` | Edit an existing MCP server (interactive wizard) |
| `/mcp delete <server-name>` | Delete an MCP server |
| `/mcp enable <server-name>` | Enable a previously disabled server (persists across sessions) |
| `/mcp disable <server-name>` | Disable a server (persists across sessions) |
| `/mcp reload` | Reload MCP configuration and restart servers |
| `/mcp auth <server-name>` | Authenticate with a remote MCP server |
| `/mcp search [query]` | Search MCP servers from the registry |

Registry search requires experimental features (`--experimental` or `/experimental on`). MCP standard features such as tools, prompts, resources, and resource templates are server-dependent: an empty list or an unsupported-method response is not evidence that every server exposes them.

Server support also does not guarantee a resource/template API is exposed to the model in a Copilot session. If the session has no such API, report that limitation; use an MCP client to verify the server's actual resource list/read results instead of presenting tool calls as resource reads.

### Shell Commands

| Command | Description |
|---------|-------------|
| `copilot mcp list` | List configured MCP servers |
| `copilot mcp list --json` | List servers as JSON |
| `copilot mcp get NAME` | Show details for a specific server |
| `copilot mcp add NAME -- COMMAND [ARGS...]` | Add a local stdio server |
| `copilot mcp add --transport http NAME URL` | Add a remote HTTP server |
| `copilot mcp remove NAME` | Remove a server |
| `copilot mcp enable NAME` / `disable NAME` | Persist server activation settings |

## Summary

- ✅ MCP extends Copilot with custom tools and resources
- ✅ Built-in GitHub MCP server provides repository access
- ✅ GitHub MCP server tools/toolsets can be customized with `--add-github-mcp-tool`/`--add-github-mcp-toolset`
- ✅ `--disable-builtin-mcps` and `--disable-mcp-server` for disabling servers, `--enable-mcp-server` to re-enable one for a single run
- ✅ Local servers run on your machine for local resources
- ✅ Remote servers connect to external services
- ✅ `copilot mcp` commands manage servers without editing files
- ✅ MCP tool calls display tool name and parameter summary in the timeline
- ✅ MCP servers can request LLM inference (sampling) with user approval
- ✅ MCP server errors surface in session output for easier debugging
- ✅ Org admins can block third-party MCP servers via policy enforcement
- ✅ Server names support npm-style identifiers with `.`, `/`, `@`
- ✅ `--additional-mcp-config` loads temporary servers
- ✅ MCP config loads from user, workspace, plugin, and built-in sources
- ✅ `copilot mcp list` includes builtin sources; verify session-only configuration in that session
- ✅ `copilot mcp` CLI command for managing servers from the command line
- ✅ `/mcp` takes subcommands: `list`, `show`, `add`, `edit`, `enable`, `disable`, `delete`, `reload`, `auth`, `search`
- ✅ Remote server auto-retry on transient network failures
- ✅ MCP OAuth HTTPS redirect URI via self-signed cert fallback

## Next Steps

→ Continue to [Module 6: Agent Skills](06-skills.md)

## References

- [Adding MCP Servers for Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers)
- [About Model Context Protocol - GitHub Docs](https://docs.github.com/en/copilot/concepts/customizations/mcp)
- [Configuring MCP Servers - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/configure-mcp-servers)
- [GitHub MCP Registry](https://github.com/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
