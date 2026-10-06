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

# Module 8: Custom Agents

### GitHub Copilot CLI Workshop

---

## What are Custom Agents?

**Specialized, model-aware Copilot personas** that can report their active model, with:

- 🎭 Defined role and expertise
- 🔧 Specific tool access
- 🚫 Clear boundaries
- 📚 Domain knowledge

Live in **`.github/agents/name.agent.md`**, **`.claude/agents/`**, or **`~/.copilot/agents/`**

Create with **`/agent`** slash command or manually

---

## Agent Profile Structure

```yaml
---
name: test-agent
description: Writes tests following TDD principles
model: auto # optional
tools: # optional (default = all)
 - shell
 - read
 - write
skills: # optional: eagerly load named skills
 - test-writer
---

# Test Writing Agent

You are a senior QA engineer...

## DO NOT
- Never modify source code (only test files)
- Never skip failing tests
```

File: `.github/agents/test-agent.agent.md`

---

## The `skills:` Field

Without `skills:`, skills load **on-demand** based on prompt matching.

```yaml
skills:
 - api-docs
 - test-writer
```

`skills:` declares which skills are **eagerly loaded** when the agent is
invoked — the agent always has that skill content available.

> The `model` field accepts display names and vendor suffixes in addition to
> full model identifiers. Copilot resolves the closest matching model.

---

## ⚠️ Restart to Load New Agents

| How the agent got there | Availability |
|-------------------------|--------------|
| Manually created `.agent.md` file | **Requires a CLI restart** |
| Edited an existing `.agent.md` file | **Requires a CLI restart** |
| Installed via `/plugin install` | **Hot-loaded** — available immediately |

If a new agent doesn't show up in `/agent`, it almost certainly means
the CLI hasn't been restarted yet — not that the file is wrong.

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

Not listed in the `/agent` menu

| Agent | What it does | How it runs |
|-------|-------------|---------|
| **Explore** | Fast codebase Q&A; read-only GitHub MCP tools | Automatic |
| **Task** | Run tests, builds, linters | Automatic |
| **General-purpose** | Main-agent capabilities in a separate context | Automatic |
| **Code-review** | High-signal diff reviews | Automatic / `/review` |
| **Rubber-duck** | Critique on a complementary model | Automatic / `/rubber-duck` |
| **Security-review** | 11 vulnerability categories | `/security-review` |
| **Research** | Deep investigations | `/research` |
| **REM** | Memory consolidation | Background |

**Plan** and **fleet** are session *modes*, not agents

> Built-ins are meant for interactive use — not every name works with `--agent`

---

## Agent Hierarchy

```
User agents (~/.copilot/agents/) ← highest priority
 ↓
Enterprise agents (.github-private repo)
 ↓
Organization agents (.github-private repo)
 ↓
Repository agents (.github/agents/ or .claude/agents/)
 ↓
AGENTS.md (root or subdirectory)
```

User-level agents **override** repo-level agents with the same name
Agents can **delegate to other agents** for complex workflows

---

## Subagent Controls

Bound delegation by depth and concurrency on usage-based billing accounts:

| Setting | Purpose |
|---------|---------|
| `subagents.maxDepth` | Limit nested delegation |
| `subagents.maxConcurrency` | Limit parallel subagents |
| `subagents.disabledSubagents` | Disable selected subagents |
| `customAgents.defaultLocalOnly` | Skip remote org/enterprise agents |

- `/subagents` sets per-agent model, effort, and context-tier overrides
- Agent names are lowercase-hyphenated and at most 64 characters
- Unknown frontmatter fields produce warnings: fix spelling/schema rather than
  assuming the field took effect

---

## Configure from Inside a Session

Manage everything without leaving the CLI:

| Command | Manages |
|---------|---------|
| `/agent` | Custom agents |
| `/mcp` | MCP servers |
| `/skills` | Skills |
| `/plugin` | Plugins and marketplaces |
| `/subagents` | Per-agent model, effort, context tier |
| `/settings` | User settings (`--repo` / `--local` for repo scope) |

> User settings live in `~/.copilot/settings.json`.
> `~/.copilot/config.json` is managed automatically and holds credentials — never print it.

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

⏱️ You have **~16 minutes**
