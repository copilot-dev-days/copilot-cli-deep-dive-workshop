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

**Specialized Copilot personas** with configurable model preferences, with:

- 🎭 Defined role and expertise
- 🔧 Specific tool access
- 🚫 Clear boundaries
- 📚 Domain knowledge

Model self-reports are not proof of the model used for dispatch.

Live in **`.github/agents/name.agent.md`**, **`.claude/agents/`**, or **`~/.copilot/agents/`**

Create with **`/agent`** slash command or manually

---

## Agent Profile Structure

```yaml
---
name: test-agent
description: Writes tests following TDD principles
include-custom-instructions: true
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

`description` is required; `name` is optional. `.agent.md` is the workshop convention; `.md` also works.

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

> The `model` field accepts identifiers and display names. Prefer an available
> model's exact ID; fallback is not proof the requested model was honored.

---

## Agent Discovery Checks

| How the agent got there | Availability |
|-------------------------|--------------|
| Manually created `.agent.md` file | Inspect `/agent`, restart if missing |
| Edited an existing `.agent.md` file | Verify loaded definition; restart if needed |
| Installed via `/plugin install` | Check `/agent` / `/env`; hot-loading needs runtime evidence |

Check location, YAML, and trust as well as restarting. Do not infer runtime activation from parser acceptance.

Previewing the first lines of a profile is not YAML parser validation.

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
| **Explore** | Separate-context codebase Q&A; inspect tool inventory | May be dispatched |
| **Task** | Run tests, builds, linters | Automatic |
| **General-purpose** | Main-agent capabilities in a separate context | Automatic |
| **Code-review** | High-signal diff reviews | Automatic / `/review` |
| **Rubber-duck** | Critique on a complementary model | `/rubber-duck`; do not assume activation |
| **Security-review** | 11 vulnerability categories | `/security-review` |
| **Research** | Deep investigations | `/research` |
| **REM** | Memory consolidation | Background |

**Plan** and **fleet** are session *modes*, not agents

> Built-in `--agent NAME -p` runtime behavior needs focused checks. Inspect `/tasks` for actual delegation.

---

## Agent Hierarchy

```
User agents (~/.copilot/agents/) ← highest priority
 ↓
Project .github/agents/ (deepest first)
 ↓
Project .claude/agents/ (deepest first)
 ↓
Added roots (.github/agents/, trusted by adding root)
 ↓
Plugin agents → remote organization/enterprise agents
```

First same **file-derived ID** wins; display names do not deduplicate.
`team/reviewer.agent.md` → `team--reviewer`; `AGENTS.md` is instructions.
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
- Prefer short lowercase-hyphenated IDs; do not apply skill name limits to agent fields
- Unrecognized frontmatter can be ignored without visible warnings:
  successful loading does not prove a field took effect

---

## Inheritance and Restrictions

- Custom subagents opt into repository instructions with `include-custom-instructions: true`
- Parent-only extra instruction directories do not carry over; `--no-custom-instructions` wins
- Delegated analyzer: `view`/`grep`/`glob` only with `strict-tools-list: true`
- Selected session analyzer also has `skill`/session `sql`; inspect actual tool inventory/events
- Local agent-scoped hooks follow trust/policy; remote agents do not run them
- `copilot --fleet -i "Add tests for independent modules"` starts parallel orchestration

---

## Agent Model Policy

- Use `model`, `model-policy: preferred|required`, and `reasoning-effort`
- Do not assume `models` overrides `model` or camelCase policy/effort fields take effect
- Required subagent policy replaces conflicting overrides; unavailable required models fail dispatch
- Session `--agent` can warn and fall back even with required policy
- `/subagents` overrides, account access, and Auto affect dispatch
- Self-reported model names are not runtime proof

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
- **Exercise 4** — Analyzer with read/search only (shell writes are not covered by write denial)
- **Exercise 5** — User-level agents
- **Exercise 6** — Coordinator and repository-instruction opt-in for specialists
- **Exercise 7** — Debugging agent config

⏱️ You have **~16 minutes**
