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

# Module 7: Plugins

### GitHub Copilot CLI Workshop

---

## Copilot Extensibility Stack

```
┌─────────────────────┐
│ Copilot CLI         │
├─────────────────────┤
│ Built-in Tools      │ bash, view, create, edit
├─────────────────────┤
│ MCP Servers         │ Module 5
├─────────────────────┤
│ Skills              │ Module 6
├─────────────────────┤
│ Plugins             │ ← This module
└─────────────────────┘
```

Plugins = **packaged integrations** from the ecosystem

---

## Plugin vs MCP vs Skill

| Kind | Best for |
|------|----------|
| Plugin | Package agents, hooks, skills, MCPs, and LSPs together |
| MCP server | Connect tools and external resources |
| Skill | Reusable on-demand instructions and resources |

---

## Plugin Sources

| Source | What you'll find |
|--------|-----------------|
| **github/awesome-copilot** | Community-curated plugins (included marketplace) |
| **github/copilot-plugins** | Official GitHub plugins (register it first) |
| **microsoft/work-iq-mcp** | Enterprise integrations |
| **Community plugins** | Third-party extensions |
| **Custom plugins** | Your own integrations |
| **GitHub repos / subdirectories** | `owner/repo` or `owner/repo:path` installs |
| **Git URLs** | Direct git install sources |

```bash
# Search for available plugins
copilot plugin marketplace list
copilot plugin marketplace browse awesome-copilot

# Register another marketplace, then browse it
copilot plugin marketplace add github/copilot-plugins
copilot plugin marketplace browse copilot-plugins
```

Inside a session, use `/plugin` for interactive marketplace browsing and plugin management.

> `awesome-copilot` is included. Register other marketplaces explicitly, or
> trust additional policy-approved catalogs through `extraKnownMarketplaces`.

---

## Installing a Plugin

Plugins can bundle **skills, agents, hooks, MCP servers, and LSP servers**

```bash
# From a marketplace in a session
/plugin install workiq@copilot-plugins

# From a marketplace in shell
copilot plugin install workiq@copilot-plugins

# From GitHub
copilot plugin install owner/repo
copilot plugin install owner/repo:plugins/my-plugin

# From a git URL
copilot plugin install https://github.com/owner/my-plugin.git
```

> Audit plugin source and permission needs before installing

---

## Registry, Authentication & Setup

- MCP servers come from a **policy-configured registry**, not `copilot plugin install`
- Registry access may require authentication and interactive secret entry
- Add MCP servers with `/plugin`, `/mcp`, or `copilot mcp add`
- A plugin manifest may show a **post-install message** with setup steps,
  required configuration, or usage tips

> Read the post-install message and audit requested credentials before use.

---

## Plugin Maintenance

```bash
copilot plugin list
copilot plugin update spark@copilot-plugins
copilot plugin update --all
copilot plugin uninstall workiq
copilot plugin marketplace update
```

> `copilot plugin update` needs a plugin name **or** `--all`
> Use `--plugin-dir /path/to/plugin` for local plugin development

---

## Auditing Every Kind

One command per kind — `copilot plugins` is an alias of `copilot plugin`

```bash
copilot plugin list --json        # installed plugins
copilot mcp list                  # MCP servers
copilot skill list                # skills, grouped by source
copilot instruction list          # custom instruction sources
copilot lsp list                  # language servers

copilot plugin enable arch@awesome-copilot
copilot plugin disable arch@awesome-copilot
copilot mcp disable github-mcp-server
copilot skill disable my-skill
```

> `/plugin` opens the interactive plugin dashboard;
> `/env` shows every loaded kind at once
> A `[plugin-dir]` warning about a bundled plugin directory with no `plugin.json` or `SKILL.md` may print first — benign, the listing that follows is complete

---

## Common Integration Packages

Common MCP packages include `@modelcontextprotocol/server-filesystem`,
`@modelcontextprotocol/server-postgres`, `@modelcontextprotocol/server-memory`,
and `@anthropic/mcp-server-puppeteer`. Verify source, policy, authentication,
and requested permissions before installation.

---

## Security Checklist

Before installing any plugin:

- Source code is **open and auditable**
- Actively maintained
- Minimal dependencies
- No known vulnerabilities
- Clear permission requirements

```bash
# Restrict plugin capabilities
copilot --allow-tool 'plugin-name' --deny-tool 'shell(rm)'
```

---

## Plugin Capabilities & Discovery

- **Skills** — reusable instructions
- **Agents** — specialized personas
- **Hooks** — lifecycle automation
- **MCP servers** — tools and resources
- **LSP servers** — code intelligence
- **Marketplace catalogs** point to discoverable packages; they are sources, not bundled capabilities

Hook and plugin scripts receive `PLUGIN_ROOT`, `PLUGIN_DATA`, and
`COPILOT_PROJECT_DIR` (plus `COPILOT_`/`CLAUDE_` variants)

---

## Your Turn! 🚀

Open **Module 7** in `docs/workshop/07-plugins.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Explore official plugins
- **Exercise 2** — Explore work-iq-mcp
- **Exercise 3** — Install a community MCP server
- **Exercise 4** — Database plugin integration
- **Exercise 5** — Create a custom plugin
- **Exercise 6** — Plugin security review
- **Exercise 7** — Plugin discovery
- **Exercise 8** — Audit every kind of configuration

⏱️ You have **~12 minutes**
