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

# Module 8: Plugins

### GitHub Copilot CLI Workshop

---

## Copilot Extensibility Stack

```
┌─────────────────────┐
│ Copilot CLI │
├─────────────────────┤
│ Built-in Tools │ shell, read, write
├─────────────────────┤
│ MCP Servers │ Module 6
├─────────────────────┤
│ Skills │ Module 7
├─────────────────────┤
│ Plugins │ ← This module
└─────────────────────┘
```

Plugins = **packaged integrations** from the ecosystem

---

## Plugin Sources

| Source | What you'll find |
|--------|-----------------|
| **github/copilot-plugins** | Official GitHub plugins |
| **microsoft/work-iq-mcp** | Enterprise (M365, Azure) |
| **npm** | Community MCP servers |
| **Custom** | Your own integrations |

```bash
# Search for available plugins
npm search @modelcontextprotocol
npm search mcp-server
```

---

## Installing a Plugin

Plugins are configured as **MCP servers** in `~/.copilot/mcp-config.json`

```json
{
 "mcpServers": {
 "brave-search": {
 "type": "local",
 "command": "npx",
 "args": ["-y", "@anthropic/mcp-server-brave-search"],
 "env": {
 "BRAVE_API_KEY": "${BRAVE_API_KEY}"
 }
 }
 }
}
```

> Always use `${ENV_VAR}` for secrets — never hardcode

---

## Remote Plugin Sources

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

> Remote sources reference GitHub repos and git URLs via `marketplace.json`

---

## Security Checklist

Before installing any plugin:

- ✅ Source code is **open and auditable**
- ✅ Actively maintained
- ✅ Minimal dependencies
- ✅ No known vulnerabilities (`npm audit`)
- ✅ Clear permission requirements

```bash
# Restrict plugin capabilities
copilot --allow-tool 'plugin-name' --deny-tool 'shell(rm)'
```

---

## Extensions & Open Plugins (v1.0.3+)

- **Extensions** (experimental) — Copilot writes custom tools at runtime via `@github/copilot-sdk`
- **`/extensions`** command to view, enable, disable extensions (v1.0.5)
- Extension tools integrate with **permissions system** (`skipPermission` per-tool) (v1.0.6)
- **Open Plugins spec** support (v1.0.6):
  - `.lsp.json` manifests, PascalCase events, `exclusive` path mode
  - Cross-platform compatibility with VS Code and Claude Code

---

## Your Turn! 🚀

Open **Module 7** in `docs/workshop/07-plugins.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Explore official plugins
- **Exercise 2** — Explore work-iq-mcp
- **Exercise 3** — Install a community plugin
- **Exercise 4** — Database plugin integration
- **Exercise 5** — Create a custom plugin
- **Exercise 6** — Plugin security review
- **Exercise 7** — Plugin discovery

⏱️ You have **~12 minutes**

