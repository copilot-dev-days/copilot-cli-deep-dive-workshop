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
- Inspect plugins, MCP servers, skills, instructions, and language servers from the shell
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
| Installation | `copilot plugin install` | `copilot mcp add` or config file | `copilot skill add` or directory |
| Scope | Installed plugin | User/workspace/plugin/session | Project/personal/plugin/custom |
| Capabilities | Skills, agents, hooks, MCP servers, LSP servers | Tools/resources | Instructions |
| Distribution | Marketplace, GitHub repo, repo subdirectory, git URL | Config sharing | Files/git/URL |

### Interactive Plugin Management

Use `/plugin` inside a Copilot CLI session to manage plugins and plugin marketplaces interactively:

```
/plugin
/plugin marketplace browse awesome-copilot
/plugin install arch@awesome-copilot
```

Use this path when you are already in a session and want the CLI to guide plugin discovery, installation, marketplace browsing, updates, or removal.

### Shell Plugin Management Commands

Use `copilot plugin` from the shell when you want scriptable plugin management:

```bash
# Browse the included marketplace
copilot plugin marketplace list
copilot plugin marketplace browse awesome-copilot

# Register another marketplace, then browse it
copilot plugin marketplace add github/copilot-plugins
copilot plugin marketplace browse copilot-plugins

# Install from a marketplace
copilot plugin install workiq@copilot-plugins

# Install directly from GitHub
copilot plugin install owner/repo
copilot plugin install owner/repo:plugins/my-plugin

# Install from a git URL
copilot plugin install https://github.com/owner/my-plugin.git

# Inspect and maintain installed plugins
copilot plugin list
copilot plugin update spark@copilot-plugins
copilot plugin update --all
copilot plugin uninstall workiq
```

`copilot plugin update` requires either a plugin name or `--all`; running it with no argument reports a missing plugin name.

### Inspecting Resources Across Kinds

Plugins are one of several kinds of configuration the CLI loads. Each kind has its own
shell inventory command, and `copilot plugins` is simply an
alias for `copilot plugin`:

```bash
# Installed plugins (plus anything mounted with --plugin-dir)
copilot plugin list
copilot plugin list --json

# MCP servers from user config, workspace config, and plugins
copilot mcp list
copilot mcp get github-mcp-server

# Skills from project, personal, plugin, and custom directories
copilot skill list
copilot skill list --json

# Custom instruction sources a session would load
copilot instruction list
copilot instruction list --json

# Language servers configured for this CLI
copilot lsp list
copilot lsp list --json
```

Enable and disable work per kind, and each change persists to configuration:

```bash
copilot plugin enable arch@awesome-copilot
copilot plugin disable arch@awesome-copilot
copilot mcp disable github-mcp-server
copilot skill disable my-skill
```

> [!NOTE]
> Registry-based MCP installation uses a policy-configured registry and can require
> authentication and interactive secret entry. Add those servers from the `/plugin`
> dashboard, `/mcp`, or `copilot mcp add`. Manual local MCP configuration and servers
> bundled inside plugins are separate supported paths; registry authentication is not
> a prerequisite for the local server in Exercise 5.

Inside a session, `/plugin` opens the interactive plugin dashboard and `/env` prints the
loaded environment across every kind at once — instructions, MCP servers, skills, agents,
hooks, plugins, LSP servers, and extensions.

Shell inventories are not a substitute for session validation. A `--plugin-dir` mount can
appear in plugin and skill listings while its MCP and LSP components are absent from
the corresponding shell listings. Inspect the session and dispatch a component before
concluding that it is unavailable. Installed plugins contribute to MCP and LSP shell listings.

### Plugin Sources

1. **github/awesome-copilot** - Community-curated plugins (included marketplace)
2. **github/copilot-plugins** - Official GitHub plugins (add with `copilot plugin marketplace add`)
3. **microsoft/work-iq-mcp** - Enterprise integrations
4. **Community plugins** - Third-party extensions
5. **Custom plugins** - Your own integrations
6. **Direct installation sources** - GitHub repositories, repository subdirectories, and git URLs passed directly to `copilot plugin install`; these are distinct from marketplace references and do not require marketplace registration

### Plugin Catalog Refresh

> Use `copilot plugin marketplace update` to refresh plugin catalogs from all configured marketplaces. This downloads the latest plugin listings without reinstalling any plugins.

### Plugin Hooks and Environment

Plugin path variables depend on the component and manifest format:

| Variable | Points to |
|---|---|
| `PLUGIN_ROOT`, `COPILOT_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT` | The loaded plugin directory; a development mount need not be installed |
| `COPILOT_PLUGIN_DATA`, `CLAUDE_PLUGIN_DATA` | The plugin's writable data directory in hook scripts |
| `COPILOT_PROJECT_DIR`, `CLAUDE_PROJECT_DIR` | The project root in hook scripts |

Do not assume that hook variables are all present in MCP subprocesses. For the
component-path manifest used in Exercise 5, verify data variables before use:
the bare `PLUGIN_DATA` alias is not guaranteed. The portable manifest format has
its own variable and fixed-path rules; do not mix the two formats.
This lets hook scripts reference files inside the plugin package, and write state, without hardcoding paths. See [Module 9: Hooks](09-hooks.md) for hook lifecycle details.

### Post-Install Messages

Plugins can declare a post-install message in their manifest. After `copilot plugin install` completes, the message is displayed to the user for setup instructions, configuration requirements, or usage tips.

> [!NOTE]
> One marketplace is included and does not need to be added: `awesome-copilot` (github/awesome-copilot). Register any other marketplace — including `copilot-plugins` (github/copilot-plugins) — with `copilot plugin marketplace add <owner/repo>`. Additional trusted marketplaces can also be configured via the `extraKnownMarketplaces` setting.

## Hands-On Exercises

### Exercise 1: Explore Official Copilot Plugins

**Goal:** Discover available plugins in the official repository.

**Steps:**

1. Visit the copilot-plugins repository:
 ```
 https://github.com/github/copilot-plugins
 ```

2. Register the marketplace, then browse it from the CLI:
 ```bash
 copilot plugin marketplace add github/copilot-plugins
 copilot plugin marketplace browse copilot-plugins
 ```

3. Note the plugin catalog entries, including integrations such as WorkIQ, Spark, Advanced Security, Microsoft 365 Agents Toolkit, Fabric skills, Power BI authoring, and language server plugins.

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
 cat plugins/spark/README.md
 ```

 Catalog entries can reference other repositories. WorkIQ's source is identified in
 `.claude-plugin/marketplace.json`; it is not a checked-in `plugins/workiq/` directory here.

**Expected Outcome:**
You understand the available plugins and their purposes.

### Exercise 2: Explore work-iq-mcp

**Goal:** Understand enterprise integration options.

**Steps:**

1. Visit the work-iq-mcp repository:
 ```
 https://github.com/microsoft/work-iq-mcp
 ```

2. Microsoft Work IQ queries your **Microsoft 365 data** with natural language:
 - **Emails** — "What did John say about the proposal?"
 - **Meetings** — "What's on my calendar tomorrow?"
 - **Documents** — "Find my recent PowerPoint presentations"
 - **Teams messages** — "Summarize today's messages in the Engineering channel"
 - **People** — "Who is working on Project Alpha?"

3. Install via the Copilot CLI plugin marketplace (register `github/copilot-plugins` first if you have not already — see Exercise 1):
 ```bash
 copilot
 ```
 ```
 /plugin marketplace add github/copilot-plugins
 /plugin install workiq@copilot-plugins
 ```

 Or install from the shell:
 ```bash
 copilot plugin install workiq@copilot-plugins
 ```

 > [!NOTE]
 > Plugins installed with `/plugin install` or `copilot plugin install` provide their bundled skills, agents, hooks, MCP servers, and language servers to Copilot CLI.

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
> Review the component's license separately: the npm runtime declares **SEE EULA**.
> The public repository also contains MIT-licensed plugin assets and documentation;
> it is not only an issue tracker. The hosted WorkIQ plugin can expose read **and**
> write operations, so do not treat it as inherently read-only or equate it with the standalone npm MCP server.

**Expected Outcome:**
You understand enterprise integration capabilities.

### Exercise 3: Install a Community MCP Server

**Goal:** Install and configure an MCP server that requires no API key.

> **Removal candidate (redundant exercise):** This is an MCP integration, not a plugin installation, and overlaps Module 5. Retained for comparison; use Exercise 5 for an actual plugin bundle. Merge the shown `mcpServers` entry into existing configuration, never replace the whole file.

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

> **Removal candidate:** The PostgreSQL package below is not supported and no database fixture is supplied. This exercise is retained as an **inactive MCP design example**, not executable instructions. Do not install it or use a production database. Select a maintained administrator-approved server and disposable fixture before runtime integration.

**Steps:**

1. Retained unsupported installation example — **do not run**:
 ```text
 npm install -g @modelcontextprotocol/server-postgres
 ```

2. Retained schema illustration — **do not apply**; connection strings in arguments can expose credentials:

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

3. After a maintained integration and disposable fixture are supplied, the intended queries are:
 ```text
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
You understand the intended database integration; runtime completion is blocked until a maintained server and fixture are supplied.

### Exercise 5: Create a Simple Custom Plugin

> [!TIP]
> This exercise uses the `McpServer` high-level API from `@modelcontextprotocol/sdk`. Tool input schemas use [Zod](https://zod.dev/), installed explicitly alongside the SDK. The server communicates over stdio.

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
 npm install @modelcontextprotocol/sdk zod
 ```

4. Create a simple MCP server:
 ```bash
 cat > index.js << 'EOF'
 const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
 const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
 const { z } = require('zod');

 const server = new McpServer({
 name: 'my-tools',
 version: 'workshop'
 });

 // Add a simple tool
 server.tool(
 'get-timestamp',
 'Get the current timestamp in various formats',
 { format: z.enum(['iso', 'unix', 'human']).default('iso') },
 async ({ format }) => {
 const now = new Date();
 let timestamp;
 switch (format) {
 case 'unix': timestamp = String(Math.floor(now.getTime() / 1000)); break;
 case 'human': timestamp = now.toLocaleString(); break;
 default: timestamp = now.toISOString(); break;
 }
 return { content: [{ type: 'text', text: timestamp }] };
 }
 );

 // Start the server over stdio
 async function main() {
 const transport = new StdioServerTransport();
 await server.connect(transport);
 }
 main().catch(console.error);
 EOF
 ```

5. Bundle the MCP server as a real local plugin. Create `plugin.json` in this directory:
 ```json
 {
   "name": "my-tools",
   "description": "Workshop timestamp tools",
   "mcpServers": ".mcp.json"
 }
 ```

 Create `.mcp.json` **inside this plugin**, not in personal configuration:
 ```json
 {
 "mcpServers": {
 "my-tools": {
 "type": "local",
 "command": "node",
 "args": ["${PLUGIN_ROOT}/index.js"]
 }
 }
 }
 ```

 > [!IMPORTANT]
 > `${PLUGIN_ROOT}` resolves bundled paths in plugin configuration. The manifest uses the supported component-path format without a schema URL. The MCP-only files alone are not a plugin.

6. Test your plugin:
 ```bash
 copilot --plugin-dir "$PWD"
 ```
 ```
 What's the current timestamp?
 ```
 Inspect `/env` and `/mcp` to confirm that the plugin contributes the server, then
 request an actual `get-timestamp` tool call. A fresh unattended `-p` invocation
 without approval can deny the call; that is a permission boundary, not a loading failure.
 For a reviewed local test, preapprove the MCP server with `--allow-tool 'my-tools'`.

 Component paths in this manifest are relative to the plugin root, not the working
 directory. Optional `agents`, `skills`, `hooks`, and `lspServers` fields point to
 their component directories or configuration files. Copy complete skill directories,
 including referenced resources and scripts. Dispatch plugin agents using their
 advertised namespaced ID, such as `my-tools:reader`; verify the actual available
 tools and any model-fallback warning rather than inferring them from frontmatter.
 A listed LSP definition still needs a working server executable and its language
 dependencies in the workspace; confirm a symbols or references response, not just a listing.

**Expected Outcome:**
Custom plugin provides new capabilities to Copilot.

### Exercise 6: Plugin Security Review

**Goal:** Understand plugin security considerations.

**Steps:**

1. Review a plugin before installation:

 This is a schematic review checklist: replace `@package/name` and `@package/plugin` with the actual npm components of the plugin you selected. Do not run these placeholders literally. A plugin need not use npm at all.
 ```bash
 # Check the source
 npm view @package/name repository

 # Review dependencies
 npm view @package/name dependencies

 # From this exercise's Node project with its package-lock.json
 npm audit
 ```

2. Security checklist for plugins:
 - [ ] Source code is open and auditable, or proprietary components have an approved vendor/data-handling review
 - [ ] Active maintenance and updates
 - [ ] Minimal dependencies
 - [ ] No known vulnerabilities
 - [ ] Clear permission requirements
 - [ ] Data handling documented

3. Configure a plugin's **MCP component** with least privilege; this is a schematic template, not a plugin manifest or copyable configuration. Replace its package and key placeholders, then merge entries into existing configuration:
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

5. Restrict model tool calls with deny rules. Use the **MCP server name**, not
 necessarily the plugin name, in the allow rule:
 ```bash
 copilot --allow-tool 'my-tools' --deny-tool 'shell(rm)'
 ```

 Tool approval does not grant access to every filesystem path. A reviewed skill
 script outside the project can also need `--add-dir /absolute/path/to/plugin`.
 Deny rules are not a sandbox for plugin startup hooks or server processes:
 review those before loading the plugin. Test destructive requests only as blocked
 permission checks against disposable fixtures.

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

### Exercise 8: Audit Every Kind of Configuration

**Goal:** Use the per-kind shell commands to audit plugins, MCP servers, skills, instructions, and language servers.

**Steps:**

1. List the installed plugins:
 ```bash
 copilot plugin list
 ```
 `copilot plugins` is an alias for the same command, so either spelling works.

 > A `[plugin-dir]` warning about a directory with no `plugin.json` or `SKILL.md`
 > means that directory did not contribute a plugin. Check the named path;
 > a successful listing does not prove that every intended component loaded.

2. List the other kinds, one command each:
 ```bash
 copilot mcp list
 copilot skill list
 copilot instruction list
 copilot lsp list
 ```
 Note how `copilot skill list` groups skills by source (builtin, project, personal, plugin, custom).

3. Take machine-readable output where you need to script against it:
 ```bash
 copilot plugin list --json
 copilot skill list --json
 ```

4. Toggle a resource and confirm the change. Disable the built-in GitHub MCP server, inspect the setting, then re-enable it:
 ```bash
 copilot mcp disable github-mcp-server
 jq '.disabledMcpServers' ~/.copilot/settings.json
 copilot mcp enable github-mcp-server
 ```

 > [!NOTE]
 > The built-in server's name is `github-mcp-server`; `copilot mcp list` includes builtin sources. Inspect selected settings or the listing without printing credential-bearing JSON.

5. Install a skill into the current project rather than your user account:
 ```bash
 copilot skill add --project ~/.copilot/skills/git-workflow/SKILL.md
 ```
 > Reuse the personal `git-workflow` skill you created in Module 6. Project-scoped skills land in `.github/skills/`.

6. See the whole loaded environment at once from inside a session:
 ```bash
 copilot
 ```
 ```
 /env
 /plugin
 ```

**Expected Outcome:**
You can audit and toggle plugins, MCP servers, skills, instructions, and language servers from the shell, and read the equivalent consolidated view with `/env` and `/plugin`.

## Plugin Installation Methods

### From a Marketplace

Install from a registered marketplace in an interactive session:

```
/plugin install spark@copilot-plugins
/plugin install some-plugin@awesome-copilot
```

Or install from the shell:

```bash
copilot plugin install spark@copilot-plugins
copilot plugin install some-plugin@awesome-copilot
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

### MCP Server Plugin Format (Component Configuration)

This describes an MCP component referenced by `plugin.json`, not a standalone plugin manifest.

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

### Remote Plugin Format (MCP Component)

**Removal candidate:** The original `requestInit` nesting is not the supported MCP schema. Retained inactive fragment — **do not apply**:
```text
"requestInit": {"headers": {"Authorization": "Bearer ${TOKEN}"}}
```
Use explicit transport `type` and top-level `headers` alongside `url`:

```json
{
 "mcpServers": {
 "remote-plugin": {
 "type": "http",
 "url": "https://plugin-server.example.com/mcp/",
 "headers": {
 "Authorization": "Bearer ${TOKEN}"
 }
 }
 }
}
```

### Common Plugins (MCP Components and Alternatives)

| Plugin | Package | Purpose |
|--------|---------|---------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | File operations |
| PostgreSQL | **Removal candidate:** `@modelcontextprotocol/server-postgres` | Not supported; exercise requires a reviewed server and fixture |
| GitHub | Built-in | GitHub integration |
| Memory | `@modelcontextprotocol/server-memory` | Persistence |
| Puppeteer | **Removal candidate:** `@anthropic/mcp-server-puppeteer` | Package does not exist; use supported `@playwright/mcp` instead |

Supported browser component: `copilot mcp add playwright -- npx -y @playwright/mcp`. Follow [Playwright MCP setup](https://github.com/microsoft/playwright-mcp) for browser prerequisites; package availability does not prove local browser startup.

Plugin settings use **maps**: `enabledPlugins` maps IDs to booleans and `extraKnownMarketplaces` maps names to source definitions. `strictKnownMarketplaces` is a managed marketplace allowlist array, not a personal boolean. Managed entries cannot be repointed or toggled locally.

## Security Best Practices

1. **Audit before install** - Review source code
2. **Use environment variables** - Never hardcode secrets
3. **Principle of least privilege** - Grant minimal permissions
4. **Keep updated** - Regularly update plugins
5. **Monitor usage** - Track plugin activity
6. **Sandbox when possible** - Use containers for untrusted plugins

## Summary

- ✅ Plugins extend Copilot's capabilities significantly
- ✅ `awesome-copilot` is the included marketplace; add others such as `copilot-plugins` with `copilot plugin marketplace add`
- ✅ github/copilot-plugins provides official integrations
- ✅ work-iq-mcp enables enterprise Microsoft integrations
- ✅ Community MCP servers add diverse capabilities
- ✅ You can create custom plugins for specific needs
- ✅ Always review plugins for security before installation
- ✅ `--plugin-dir` loads local plugins for development
- ✅ `owner/repo:path` installs from repository subdirectories
- ✅ `copilot plugin install` installs from marketplaces, GitHub repos, repo subdirectories, or git URLs
- ✅ `copilot plugin marketplace browse` discovers marketplace plugins
- ✅ `copilot plugin marketplace update` refreshes plugin catalogs
- ✅ `copilot plugin update` needs a plugin name or `--all`
- ✅ `copilot plugin list`, `copilot mcp list`, `copilot skill list`, `copilot instruction list`, and `copilot lsp list` audit each kind of configuration
- ✅ `/plugin` opens the interactive plugin dashboard and `/env` shows every loaded kind at once
- ✅ Plugin-root aliases resolve bundled files; data and project variables depend on component and manifest format
- ✅ Plugins can bundle skills, agents, hooks, MCP servers, and LSP servers

## Next Steps

→ Continue to [Module 8: Custom Agents](08-custom-agents.md)

## References

- [GitHub Copilot Plugins](https://github.com/github/copilot-plugins)
- [Microsoft work-iq-mcp](https://github.com/microsoft/work-iq-mcp)
- [MCP Servers Collection](https://github.com/modelcontextprotocol/servers)
- [Model Context Protocol](https://modelcontextprotocol.io/)
