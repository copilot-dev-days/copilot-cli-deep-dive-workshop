# Module 7: Plugins

## Prerequisites

- Completed Modules 1-6
- GitHub account
- Understanding of MCP concepts (Module 5)

## Learning Objectives

- Understand the Copilot plugin ecosystem
- Explore the GitHub copilot-plugins repository
- Learn about work-iq-mcp and enterprise integrations
- Install and configure plugins
- Understand plugin security considerations

## Concepts

### What are Copilot Plugins?

Plugins extend Copilot's capabilities beyond built-in features:

```
┌─────────────────┐
│ Copilot CLI │
├─────────────────┤
│ Built-in Tools │
├─────────────────┤
│   MCP Servers   │  ← Module 5
├─────────────────┤
│     Skills      │  ← Module 6
├─────────────────┤
│ Plugins │ ← This Module
└─────────────────┘
```

### Plugin vs MCP Server vs Skill

| Feature | Plugin | MCP Server | Skill |
|---------|--------|------------|-------|
| Installation | npm/manual | Config file | Directory |
| Scope | Global | Session/project | Project/personal |
| Capabilities | Full integration | Tools/resources | Instructions |
| Distribution | Package registry | Config sharing | Files/git |

### Extensions (Experimental)

> ⚠️ **FEEDBACK**: Extensions are an experimental feature available since **v1.0.3**. API and behavior may change.

Extensions let Copilot write custom tools and hooks for itself at runtime using `@github/copilot-sdk`. Unlike plugins (pre-packaged integrations), extensions are generated on-the-fly during a session.

```bash
# View, enable, and disable loaded extensions
/extensions
```

Key capabilities:
- Extensions can be CommonJS modules (`.cjs`) since v1.0.4
- Extension tools integrate with the permissions system (v1.0.6)
- Use `skipPermission` per-tool to bypass permission prompts for trusted extension tools
- The loaded extensions count is shown in the "Environment loaded" startup message

### Open Plugins Spec

> Since v1.0.6, Copilot CLI supports the [Open Plugins specification](https://github.com/nichochar/open-plugins-spec):
> - `.lsp.json` plugin manifest files
> - PascalCase hook event names
> - `exclusive` path mode
> - `:` namespace separator
>
> This improves cross-platform compatibility with VS Code, Claude Code, and other tools.

### Plugin Sources

1. **github/copilot-plugins** - Official GitHub plugins (default marketplace)
2. **github/awesome-copilot** - Community-curated plugins (default marketplace)
3. **microsoft/work-iq-mcp** - Enterprise integrations
4. **Community plugins** - Third-party extensions
5. **Custom plugins** - Your own integrations
6. **Remote sources** - GitHub repos and git URLs referenced in `marketplace.json`

> [!NOTE]
> Two marketplaces are included by default and do not need to be added: `copilot-plugins` (github/copilot-plugins) and `awesome-copilot` (github/awesome-copilot). Additional marketplaces can be configured via the `extraKnownMarketplaces` repository setting.

## Hands-On Exercises

### Exercise 1: Explore Official Copilot Plugins

**Goal:** Discover available plugins in the official repository.

**Steps:**

1. Visit the copilot-plugins repository:
 ```
 https://github.com/github/copilot-plugins
 ```

2. Browse the available plugins. The repo currently contains:
 - **Skills** — Reusable prompts and workflows (e.g., `spark-app-template`, `workiq`)

3. Note the `plugins/` directory structure:
 - `plugins/spark/skills/spark-app-template` — A skill for scaffolding Spark apps
 - `plugins/workiq` — Microsoft Work IQ integration (see Exercise 2)

4. Read the [CONTRIBUTING.md](https://github.com/github/copilot-plugins/blob/main/CONTRIBUTING.md) for how to submit your own plugins.

5. Clone the repository to explore locally:
 ```bash
 git clone https://github.com/github/copilot-plugins.git
 cd copilot-plugins
 ls -la
 ```

6. Examine a plugin's structure:
 ```bash
 ls -R plugins/
 cat plugins/workiq/README.md
 ```

**Expected Outcome:**
You understand the available plugins and their purposes.

### Exercise 2: Explore work-iq-mcp

**Goal:** Understand enterprise integration options.

**Steps:**

1. Visit the work-iq-mcp repository:
 ```
 https://github.com/microsoft/work-iq-mcp
 ```

2. Microsoft Work IQ (Public Preview) queries your **Microsoft 365 data** with natural language:
 - **Emails** — "What did John say about the proposal?"
 - **Meetings** — "What's on my calendar tomorrow?"
 - **Documents** — "Find my recent PowerPoint presentations"
 - **Teams messages** — "Summarize today's messages in the Engineering channel"
 - **People** — "Who is working on Project Alpha?"

3. Install via the Copilot CLI plugin marketplace (`github/copilot-plugins` is a **default marketplace** — no need to add it manually):
 ```bash
 copilot
 ```
 ```
 /plugin install workiq@copilot-plugins
 ```

 > [!NOTE]
 > Plugins installed via `/plugin install` are **hot-loaded** — their agents and skills are available immediately without restarting the CLI.

 Or install standalone via npm:
 ```bash
 npm install -g @microsoft/workiq
 workiq accept-eula
 workiq mcp # starts the MCP server
 ```

4. Review the admin setup guide:
 ```bash
 git clone https://github.com/microsoft/work-iq-mcp.git
 cd work-iq-mcp
 cat ADMIN-INSTRUCTIONS.md
 ```

5. Understand authentication requirements:
 - Requires **Microsoft Entra tenant** admin consent on first access
 - Browser-based sign-in flow
 - If you are not a tenant admin, contact your administrator (see [Admin Guide](https://github.com/microsoft/work-iq-mcp/blob/main/ADMIN-INSTRUCTIONS.md))

> [!NOTE]
> Work IQ is **not open source** — the runtime is proprietary. The GitHub repo is public for documentation, feedback, and issue tracking only.

**Expected Outcome:**
You understand enterprise integration capabilities.

### Exercise 3: Install a Community MCP Server

**Goal:** Install and configure an MCP server that requires no API key.

**Steps:**

1. Search for Copilot-compatible MCP servers:
 ```bash
 npm search @modelcontextprotocol
 ```

2. Install the official **Filesystem** MCP server (provides file read/write/search capabilities):
 ```bash
 npm install -g @modelcontextprotocol/server-filesystem
 ```

3. Configure as MCP server (no API key needed — just specify an allowed directory).

 Add to `~/.copilot/mcp-config.json`:
 ```json
 {
 "mcpServers": {
 "filesystem": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
 }
 }
 }
 ```

 > [!IMPORTANT]
 > Use an **absolute path** — tilde (`~`) is not expanded because Copilot spawns processes without a shell. Replace `/home/user/projects` with the actual directory you want the server to access. The directory must exist before starting the server.

4. Restart Copilot and test:
 ```bash
 copilot
 ```
 ```
 List the files in my workspace and summarize what you find
 ```

5. Try other filesystem operations:
 ```
 Search for any markdown files and show me their contents
 ```

**Expected Outcome:**
Filesystem access capability added via MCP server — no API key required.

### Exercise 4: Database Plugin Integration

**Goal:** Add database query capabilities.

**Steps:**

1. Install PostgreSQL MCP server:
 ```bash
 npm install -g @modelcontextprotocol/server-postgres
 ```

2. Configure with your database.

 Add to `~/.copilot/mcp-config.json`:
 ```json
 {
 "mcpServers": {
 "postgres": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost/dbname"]
 }
 }
 }
 ```

 > [!NOTE]
 > The connection string is passed as an argument, not as an environment variable. Replace the URL with your actual database connection string.

3. Test database queries:
 ```bash
 copilot
 ```
 ```
 Show me the schema of the users table
 ```
 ```
 How many records are in the orders table?
 ```

4. **Security Note:** Be careful with production databases!

**Expected Outcome:**
Database query capabilities via Copilot.

### Exercise 5: Create a Simple Custom Plugin

> [!TIP]
> This exercise uses the `McpServer` high-level API from `@modelcontextprotocol/sdk` (v1.27+). Tool input schemas use [Zod](https://zod.dev/) (bundled with the SDK). The server communicates over stdio.

**Goal:** Build a basic plugin for your workflow.

**Steps:**

1. Create a plugin directory:
 ```bash
 mkdir -p ~/copilot-plugins/my-tools
 cd ~/copilot-plugins/my-tools
 ```

2. Initialize as Node.js project:
 ```bash
 npm init -y
 ```

3. Install dependencies:
 ```bash
 npm install @modelcontextprotocol/sdk
 ```

4. Create a simple MCP server:
 ```bash
 cat > index.js << 'EOF'
 const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
 const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
 const { z } = require('zod');

 const server = new McpServer({
 name: 'my-tools',
 version: '1.0.0'
 });

 // Add a simple tool
 server.tool(
 'get-timestamp',
 'Get the current timestamp in various formats',
 { format: z.enum(['iso', 'unix', 'human']).default('iso') },
 async ({ format }) => {
 const now = new Date;
 let timestamp;
 switch (format) {
 case 'unix': timestamp = String(Math.floor(now.getTime / 1000)); break;
 case 'human': timestamp = now.toLocaleString; break;
 default: timestamp = now.toISOString; break;
 }
 return { content: [{ type: 'text', text: timestamp }] };
 }
 );

 // Start the server over stdio
 async function main {
 const transport = new StdioServerTransport;
 await server.connect(transport);
 }
 main.catch(console.error);
 EOF
 ```

5. Configure in Copilot.

 Add to `~/.copilot/mcp-config.json`:
 ```json
 {
 "mcpServers": {
 "my-tools": {
 "type": "local",
 "command": "node",
 "args": ["/home/user/copilot-plugins/my-tools/index.js"]
 }
 }
 }
 ```

 > [!IMPORTANT]
 > Use an **absolute path** in `args` — tilde (`~`) is not expanded. Replace `/home/user` with your actual home directory (run `echo $HOME` to check).

6. Test your plugin:
 ```bash
 copilot
 ```
 ```
 What's the current timestamp?
 ```

**Expected Outcome:**
Custom plugin provides new capabilities to Copilot.

### Exercise 6: Plugin Security Review

**Goal:** Understand plugin security considerations.

**Steps:**

1. Review a plugin before installation:
 ```bash
 # Check the source
 npm view @package/name repository

 # Review dependencies
 npm view @package/name dependencies

 # Check for known vulnerabilities
 npm audit @package/name
 ```

2. Security checklist for plugins:
 - [ ] Source code is open and auditable
 - [ ] Active maintenance and updates
 - [ ] Minimal dependencies
 - [ ] No known vulnerabilities
 - [ ] Clear permission requirements
 - [ ] Data handling documented

3. Configure with least privilege:
 ```json
 {
 "mcpServers": {
 "plugin-name": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@package/plugin"],
 "env": {
 "API_KEY": "${PLUGIN_API_KEY}"
 }
 }
 }
 }
 ```

4. Use environment variables for secrets:
 ```bash
 export PLUGIN_API_KEY="your-key"
 copilot
 ```

5. Restrict plugin capabilities with deny rules:
 ```bash
 copilot --allow-tool 'plugin-name' --deny-tool 'shell(rm)'
 ```

**Expected Outcome:**
You can evaluate and securely configure plugins.

### Exercise 7: Plugin Discovery and Ecosystem

**Goal:** Navigate the plugin ecosystem.

**Steps:**

1. Official sources:
 - https://github.com/github/copilot-plugins
 - https://github.com/modelcontextprotocol/servers

2. Search npm for MCP servers:
 ```bash
 npm search mcp-server
 npm search modelcontextprotocol
 ```

3. Check community collections:
 - GitHub topics: `copilot-plugin`, `mcp-server`
 - Awesome lists: `awesome-mcp`, `awesome-copilot`

4. Evaluate a plugin:
 ```bash
 # Stars and activity
 gh repo view owner/plugin-repo

 # Recent commits
 gh api repos/owner/plugin-repo/commits --jq '.[0:5] | .[].commit.message'

 # Open issues
 gh issue list -R owner/plugin-repo
 ```

5. Contribute to the ecosystem:
 - Report issues you find
 - Submit feature requests
 - Create and share your own plugins

**Expected Outcome:**
You can find, evaluate, and contribute to the plugin ecosystem.

## Plugin Installation Methods

### From a Marketplace

```bash
# Install from a registered marketplace
/plugin install spark@copilot-plugins
/plugin install some-plugin@awesome-copilot
```

### From a GitHub Repository

```bash
# Install from a GitHub repository
copilot plugin install owner/repo

# Install from a subdirectory within a repo
copilot plugin install owner/repo:plugins/my-plugin

# Install from a git URL
copilot plugin install https://github.com/owner/my-plugin.git
```

### From a Local Directory

Load a plugin from a local directory without installing it — useful for plugin development:

```bash
copilot --plugin-dir /path/to/my-plugin
# Can be used multiple times
copilot --plugin-dir ./plugin-a --plugin-dir ./plugin-b
```

## Plugin Configuration Reference

### MCP Server Plugin Format

```json
{
 "mcpServers": {
 "plugin-name": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@scope/package-name", "--option"],
 "env": {
 "API_KEY": "${ENV_VAR}",
 "CONFIG": "value"
 },
 "cwd": "/optional/working/dir"
 }
 }
}
```

### Remote Plugin Format

```json
{
 "mcpServers": {
 "remote-plugin": {
 "url": "https://plugin-server.example.com/mcp/",
 "requestInit": {
 "headers": {
 "Authorization": "Bearer ${TOKEN}"
 }
 }
 }
 }
}
```

### Common Plugins

| Plugin | Package | Purpose |
|--------|---------|---------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | File operations |
| PostgreSQL | `@modelcontextprotocol/server-postgres` | Database queries |
| GitHub | Built-in | GitHub integration |
| Memory | `@modelcontextprotocol/server-memory` | Persistence |
| Puppeteer | `@anthropic/mcp-server-puppeteer` | Browser automation |

## Security Best Practices

1. **Audit before install** - Review source code
2. **Use environment variables** - Never hardcode secrets
3. **Principle of least privilege** - Grant minimal permissions
4. **Keep updated** - Regularly update plugins
5. **Monitor usage** - Track plugin activity
6. **Sandbox when possible** - Use containers for untrusted plugins

## Summary

- ✅ Plugins extend Copilot's capabilities significantly
- ✅ Two default marketplaces: `copilot-plugins` and `awesome-copilot`
- ✅ github/copilot-plugins provides official integrations
- ✅ work-iq-mcp enables enterprise Microsoft integrations
- ✅ Community MCP servers add diverse capabilities
- ✅ You can create custom plugins for specific needs
- ✅ Always review plugins for security before installation
- ✅ `--plugin-dir` loads local plugins for development
- ✅ `owner/repo:path` installs from repository subdirectories
- ✅ `/plugin install` and `/plugin marketplace add` now support local paths with spaces
- ✅ `/plugin install` hot-loads agents and skills — no CLI restart needed
- ✅ Extensions (experimental) — runtime tools via `@github/copilot-sdk` (v1.0.3+)
- ✅ `/extensions` command to view, enable, and disable extensions (v1.0.5+)
- ✅ Open Plugins spec support for cross-platform compatibility (v1.0.6+)

> [!NOTE]
> Local paths with spaces are supported in marketplace source configurations.

## Next Steps

→ Continue to [Module 8: Custom Agents](08-custom-agents.md)

## References

- [GitHub Copilot Plugins](https://github.com/github/copilot-plugins)
- [Microsoft work-iq-mcp](https://github.com/microsoft/work-iq-mcp)
- [MCP Servers Collection](https://github.com/modelcontextprotocol/servers)
- [Model Context Protocol](https://modelcontextprotocol.io/)
