# Module 5: MCP Servers

## Prerequisites

- Completed Modules 1-5
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

MCP server errors now surface directly in the session output, making it easier to diagnose connection and configuration issues. Errors are displayed inline when:
- A server fails to start
- A connection cannot be established
- A tool invocation fails
- Configuration is invalid

Use `/mcp show` to check which servers are connected and their current status.

> [!WARNING]
> MCP error visibility significantly improves the debugging experience when working with custom MCP servers, as errors are no longer silently ignored.

### Server Types

| Type | Protocol Name | Location | Use Case |
|------|---------------|----------|----------|
| Remote (HTTP) | `http` | Hosted externally | Team-wide tools, cloud services |
| Remote (SSE) | `sse` | Hosted externally | Legacy HTTP+SSE transport (deprecated in MCP spec) |
| Local (STDIO) | `local` or `stdio` | Runs on your machine | Local resources, custom tools |
| Built-in | N/A | Included with Copilot | GitHub integration |

> **Note:** `local` and `stdio` are equivalent — `stdio` is the standard MCP protocol name, so choose it if you want configuration compatible with VS Code and other MCP clients. Similarly, `http` uses Streamable HTTP and `sse` uses the legacy Server-Sent Events transport.

### Configuration Location

MCP servers are configured in:
- Default: `~/.copilot/mcp-config.json`
- Custom: Set via `XDG_CONFIG_HOME`

### DevContainer MCP Configuration

> Since v1.0.3, Copilot CLI reads MCP server configuration from `.devcontainer/devcontainer.json`. This allows Dev Container and Codespaces environments to pre-configure MCP servers for all users.

```json
// .devcontainer/devcontainer.json
{
  "customizations": {
    "copilot": {
      "mcpServers": {
        "memory": {
          "type": "local",
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-memory"]
        }
      }
    }
  }
}
```

MCP servers defined in `devcontainer.json` are merged with your personal `~/.copilot/mcp-config.json` configuration.

### Enterprise Policy Enforcement

> [!IMPORTANT]
> Organization administrators can block third-party MCP servers via policy enforcement. When a policy is active, users in the organization will be prevented from connecting to MCP servers that are not on the allow-list. This is enforced at the CLI level — blocked servers will not start or connect.

> ⚠️ **FEEDBACK**: MCP policy enforcement requires a Copilot Enterprise or Business subscription with organization-level policy management. Behavior may vary depending on how your org admin has configured the policy.

### Built-in GitHub MCP Server Controls

Copilot CLI includes a built-in GitHub MCP server with a default subset of tools. You can customize which tools are available:

```bash
# Add a specific tool to the GitHub MCP server
copilot --add-github-mcp-tool "create_issue"

# Add a toolset (group of related tools)
copilot --add-github-mcp-toolset "repos"

# Enable ALL GitHub MCP tools (overrides --add-github-mcp-tool/toolset)
copilot --enable-all-github-mcp-tools

# Disable the built-in GitHub MCP server entirely
copilot --disable-builtin-mcps

# Disable a specific MCP server by name
copilot --disable-mcp-server "my-custom-server"
```

Use `--add-github-mcp-tool "*"` or `--add-github-mcp-toolset "all"` to enable everything. The `--disable-mcp-server` flag works for any MCP server (built-in or configured), and can be used multiple times.

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
 /mcp show
 ```

 > `/mcp show` groups servers into **User**, **Workspace**, **Plugins**, and **Built-in** sections for easier navigation.

3. The GitHub MCP server is pre-configured. Try using it:
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

[Exa](https://exa.ai) provides AI-powered web search, code search, and company research through a remote MCP server.

**Steps:**

1. View current config file:
 ```bash
 cat ~/.copilot/mcp-config.json
 ```

2. Start Copilot and use the interactive MCP setup:
 ```bash
 copilot
 ```
 ```
 /mcp add
 ```

3. Use Tab to navigate between fields:
 - **Server Name**: `exa`
 - **Server Type**: Select HTTP (for remote servers)
 - **URL**: `https://mcp.exa.ai/mcp`
 - **HTTP Headers**: (leave empty — Exa's public tools don't require auth)
 - **Tools**: `*` (all tools, the default)

4. Press `Ctrl+S` to save. The server is available immediately — no restart needed.

5. Verify the configuration:
 ```
 /mcp show
 ```

6. Alternatively, edit the config file directly:
 ```bash
 cat > ~/.copilot/mcp-config.json << 'EOF'
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

 > **Note:** Exa's public tools (web search, code search, company research) don't require authentication. Only the corporate/enterprise Exa tools require an API key or OAuth.
 >
 > When editing the config file directly, restart the CLI or use `/mcp reload` to pick up changes.

7. Test the Exa search tools:
 ```
 Search the web for the latest GitHub Copilot CLI features
 ```

**Expected Outcome:**
Remote Exa MCP server configured. Copilot can now perform web searches, code searches, and company research via Exa tools.

### Exercise 3: Add a Local MCP Server

**Goal:** Configure a locally-running MCP server.

**Steps:**

1. Install the MCP memory server:
 ```bash
 npm install -g @modelcontextprotocol/server-memory
 ```

2. Add it to your MCP config:
 ```bash
 cat > ~/.copilot/mcp-config.json << 'EOF'
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
 "tools": ["*"]
 }
 }
 }
 EOF
 ```

 > **Note:** Environment variables referenced in the `command`, `args`, or `cwd` fields are automatically inherited from your shell. Previously, only `PATH` was auto-inherited. Other variables that are not referenced in those fields must still be configured in the `"env"` field.

3. Restart Copilot to load the new server:
 ```bash
 copilot
 ```

4. Verify the server is loaded:
 ```
 /mcp show
 ```

5. Test the memory server:
 ```
 Remember that my favorite programming language is Rust
 ```

6. Later in the session:
 ```
 What's my favorite programming language?
 ```

**Expected Outcome:**
Local MCP server runs and provides additional capabilities.

### Exercise 4: File System MCP Server

**Goal:** Add an MCP server for enhanced file operations.

**Steps:**

1. Install the filesystem MCP server:
 ```bash
 npm install -g @modelcontextprotocol/server-filesystem
 ```

 > **Note:** The `~/projects` directory must exist before the filesystem server can start. Create it first with `mkdir -p ~/projects` if needed.

2. Update MCP config with directory restrictions (using tilde expansion):
 ```bash
 cat > ~/.copilot/mcp-config.json << 'EOF'
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
 "~/projects"
 ],
 "cwd": "~/projects",
 "tools": ["*"]
 }
 }
 }
 EOF
 ```

 Note: You can use `~` for home directory in both args and `cwd`.


3. Restart Copilot (or use `/mcp reload`+):
 ```bash
 copilot
 ```

4. Check for any MCP server errors:
 ```
 /mcp show
 ```

 If there are configuration issues, server status will indicate errors here.

5. Test file operations through MCP:
 ```
 Using the filesystem server, list all TypeScript files in my projects
 ```

**Expected Outcome:**
MCP server provides structured file access with defined boundaries. Any startup errors are visible via `/mcp show`.

### Exercise 5: MCP Server Management Commands

**Goal:** Master MCP management through slash commands.

**Steps:**

1. Start Copilot:
 ```bash
 copilot
 ```

2. **Show all servers:**
 ```
 /mcp show
 ```

3. **Add a new server interactively:**
 ```
 /mcp add
 ```
 Fill in details and `Ctrl+S` to save.

4. **Edit an existing server:**
 ```
 /mcp edit memory
 ```

5. **Reload configuration without restarting**:
 ```
 /mcp reload
 ```

 This is useful when you've edited `~/.copilot/mcp-config.json` directly or want to pick up changes without exiting your current session.

6. **Disable a server temporarily:**
 ```
 /mcp disable memory
 ```

7. **Re-enable it:**
 ```
 /mcp enable memory
 ```

8. **Delete a server:**
 ```
 /mcp delete memory
 ```

**Expected Outcome:**
You can manage MCP servers without editing config files, and reload configuration changes instantly.

### Exercise 6: Using MCP Tools with Permissions

**Goal:** Control MCP tool access with allow/deny flags.

**Steps:**

1. Allow specific MCP server in programmatic mode:
 ```bash
 copilot -p "Check my GitHub notifications" \
 --allow-tool 'github'
 ```

2. Allow all MCP tools:
 ```bash
 copilot -p "Use memory to store my preferences" \
 --allow-tool 'memory'
 ```

3. Deny specific MCP server while allowing others:
 ```bash
 copilot -p "Analyze the project" \
 --allow-all-tools \
 --deny-tool 'github'
 ```

4. Combine with other tool permissions:
 ```bash
 copilot -p "Review code and check GitHub issues" \
 --allow-tool 'shell(cat)' \
 --allow-tool 'github' \
 --deny-tool 'write'
 ```

**Expected Outcome:**
MCP server tools follow the same permission model as built-in tools.

### Exercise 7: Temporary MCP Configuration

**Goal:** Use additional MCP servers for specific sessions.

**Steps:**

1. Create a temporary MCP config as JSON:
 ```bash
 cat > /tmp/temp-mcp.json << 'EOF'
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

2. Start Copilot with the additional config (pass the JSON string, not the file path as `--additional-mcp-config` expects inline JSON):
 ```bash
 copilot --additional-mcp-config "$(cat /tmp/temp-mcp.json)"
 ```

3. The temporary servers are available for this session only.

4. Verify:
 ```
 /mcp show
 ```

5. The base config + temporary config are merged.

6. Test it:
 ```
 Search Microsoft Learn for how to create an Azure Container App with managed identity
 ```

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

> ⚠️ **FEEDBACK**: npm-style server names — verify with your installed version. Earlier versions only support alphanumeric names and hyphens.

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

> **Note:** Environment variables referenced in `command`, `args`, or `cwd` are automatically inherited from your shell. Previously, only `PATH` was auto-inherited; other variables had to be set in `"env"`. Variables not referenced in those fields must still be configured explicitly. The `"tools"` field defaults to `["*"]` (all tools) if omitted. You can restrict to specific tools with a list of tool names.

### Common MCP Servers

| Server | Package | Purpose |
|--------|---------|---------|
| Memory | `@modelcontextprotocol/server-memory` | Persistent memory |
| Filesystem | `@modelcontextprotocol/server-filesystem` | File operations |
| GitHub | Built-in | GitHub integration |
| Exa | `https://mcp.exa.ai/mcp` (remote) | Web search, code search, company research |
| PostgreSQL | `@modelcontextprotocol/server-postgres` | Database queries |
| Slack | `@modelcontextprotocol/server-slack` | Slack integration |
| Brave Search | `@anthropic/mcp-server-brave-search` | Web search |

### Slash Commands

| Command | Description |
|---------|-------------|
| `/mcp show` | Display all MCP servers (grouped by source) |
| `/mcp show NAME` | View details and tools for a specific server |
| `/mcp add` | Add a new server interactively (available immediately) |
| `/mcp edit NAME` | Edit an existing server |
| `/mcp delete NAME` | Remove a server |
| `/mcp disable NAME` | Temporarily disable |
| `/mcp enable NAME` | Re-enable a disabled server |
| `/mcp reload` | Reload MCP configuration without restarting |

## Summary

- ✅ MCP extends Copilot with custom tools and resources
- ✅ Built-in GitHub MCP server provides repository access
- ✅ GitHub MCP server tools/toolsets can be customized with `--add-github-mcp-tool`/`--add-github-mcp-toolset`
- ✅ `--disable-builtin-mcps` and `--disable-mcp-server` for disabling servers
- ✅ Local servers run on your machine for local resources
- ✅ Remote servers connect to external services
- ✅ `/mcp` commands manage servers without editing files
- ✅ `/mcp reload` reloads configuration without restarting
- ✅ `/mcp auth` re-authenticates MCP OAuth servers with account switching support
- ✅ MCP OAuth supports device code flow (RFC 8628) for headless/CI environments
- ✅ MCP tool calls display tool name and parameter summary in the timeline
- ✅ MCP servers can request LLM inference (sampling) with user approval
- ✅ Tilde (`~`) expansion works in `cwd` paths
- ✅ MCP server errors surface in session output for easier debugging
- ✅ Giant single-line MCP tool results are now truncated correctly
- ✅ Org admins can block third-party MCP servers via policy enforcement
- ✅ Server names support npm-style identifiers with `.`, `/`, `@`
- ✅ Env vars referenced in `command`/`args`/`cwd` are auto-inherited
- ✅ `--additional-mcp-config` loads temporary servers
- ✅ MCP config from `.devcontainer/devcontainer.json` (v1.0.3+)

## Next Steps

→ Continue to [Module 6: Agent Skills](06-skills.md)

## References

- [Adding MCP Servers for Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers)
- [About Model Context Protocol - GitHub Docs](https://docs.github.com/en/copilot/concepts/about-mcp)
- [Extending Copilot Coding Agent with MCP - GitHub Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp)
- [GitHub MCP Registry](https://github.com/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
