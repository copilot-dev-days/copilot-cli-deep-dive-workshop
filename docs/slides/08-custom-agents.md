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

# Module 9: Custom Agents

### GitHub Copilot CLI Workshop

---

## What are Custom Agents?

**Specialized Copilot personas** with:

- 🎭 Defined role and expertise
- 🔧 Specific tool access
- 🚫 Clear boundaries
- 📚 Domain knowledge

Live in **`.github/agents/name.agent.md`** or **`~/.config/copilot/agents/`**

Create with **`/agent`** slash command or manually

---

## Agent Profile Structure

```yaml
---
name: test-agent
description: Writes tests following TDD principles
model: claude-sonnet-4.6 # optional
tools: # optional (default = all)
 - shell
 - read
 - write
---

# Test Writing Agent

You are a senior QA engineer...

## DO NOT
- Never modify source code (only test files)
- Never skip failing tests
```

File: `.github/agents/test-agent.agent.md`

---

## Invoking Custom Agents

| Method | Example |
|--------|---------|
| **`/agent`** slash command | `/agent` → select → prompt |
| **Explicit instruction** | `Use the test-agent agent on /src` |
| **By inference** | Prompt matching agent's expertise |
| **Programmatic** | `copilot --agent test-agent --prompt "..."` |

---

## Built-in Agents

Invoked automatically — not listed in `/agent` menu

| Agent | What it does | Trigger |
|-------|-------------|---------|
| **Explore** | Fast codebase Q&A; uses GitHub MCP tools | Codebase analysis prompts |
| **Task** | Run commands smartly | Command execution prompts |
| **Plan** | Implementation planning | Planning prompts |
| **Code-review** | High-signal reviews | Review prompts |

---

## Agent Hierarchy

```
User agents (~/.config/copilot/agents/) ← highest priority
 ↓
Enterprise agents (.github-private repo)
 ↓
Organization agents (.github-private repo)
 ↓
Repository agents (.github/agents/)
 ↓
AGENTS.md (root or subdirectory)
```

User-level agents **override** repo-level agents with the same name
Agents can **delegate to other agents** for complex workflows

---

## configure-copilot Sub-Agent (v1.0.4+)

Built-in agent that manages configuration for you:

```
Help me set up an MCP server for PostgreSQL
```

- Manages **MCP servers**, **custom agents**, and **skills**
- Modifies config files on your behalf
- Human-readable sub-agent IDs (e.g., `math-helper-0`) (v1.0.6)

---

## Your Turn! 🚀

Open **Module 8** in `docs/workshop/08-custom-agents.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Create a repository agent
- **Exercise 2** — Documentation agent
- **Exercise 3** — Built-in agents
- **Exercise 4** — Agent with tool restrictions
- **Exercise 5** — User-level agents
- **Exercise 6** — Subagents & delegation
- **Exercise 7** — Debugging agent config

⏱️ You have **~8 minutes**

