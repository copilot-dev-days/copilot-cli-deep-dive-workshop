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

# Module 6: Agent Skills

### GitHub Copilot CLI Workshop

---

## What are Skills?

**Reusable capabilities** that work across AI agents

| Feature | Instructions | Skills | Agents |
|---------|-------------|--------|--------|
| Scope | Coding standards | Capabilities | Personas |
| Trigger | Always applied | **On-demand** | Explicitly invoked |
| Location | `.github/` | `.github/skills/` | `.github/agents/` |
| Loading | Full file | **Progressive** | Full profile |

Skills load only what's relevant → efficient context usage

---

## Progressive Disclosure

```
Level 1: Discovery     → name + description (always read)
Level 2: Instructions  → SKILL.md body (when relevant)
Level 3: Resources     → examples/, templates/ (as needed)
```

Copilot **auto-selects** the right skill based on your request

---

## Skill Structure

```
.github/skills/
└── api-docs/
    ├── SKILL.md          ← Required: frontmatter + instructions
    ├── examples/          ← Optional: code examples
    │   ├── example.ts
    │   └── example.py
    ├── scripts/           ← Optional: executable helpers
    └── templates/         ← Optional: code templates
```

```yaml
---
name: api-docs
description: Generates API documentation from source code
---

# Markdown body with detailed instructions...
```

Optional frontmatter: `license`, `user-invocable`, `aliases`,
`allowed-tools`, `disable-model-invocation`

---

## Built-in Skills

Three skills ship with the CLI and need **no configuration**:

| Skill | What it does |
|-------|--------------|
| `customize-cloud-agent` | Configure the Copilot cloud agent environment — `copilot-setup-steps.yml`, preinstalled tools, runners, settings |
| `discover-resources` | Find a public MCP server or skill for an unavailable capability — database access, PDF reports, cloud costs, diagrams |
| `github-pr-media` | Upload images/video to GitHub's user attachments API and embed them in a PR description or comment |

```bash
copilot skill list                  # grouped by source
copilot skill list --json
```

> `discover-resources` backs the runtime discovery search and is not
> user-selectable, so it does not appear in `copilot skill list`

> Built-ins can't be deleted, but they can be disabled
> (`copilot skill disable <name>`, or the `/skills` view)
> or overridden by a project/personal skill of the same name

---

## Community Skills & Validation

- Discover portable skills at **agentskills.io** and review examples in
  `github.com/anthropics/skills`
- The Agent Skills specification makes `SKILL.md` reusable across clients
- `name` is lowercase/hyphenated and at most 64 characters; `description` is
  at most 1024 characters
- Built-ins use `user-invocable: false`; the model loads them when needed

```bash
copilot skill add ./skills-directory
copilot skill enable my-skill
copilot skill remove ./skills-directory
```

---

## Skill Locations

| Location | Scope | Use case |
|----------|-------|----------|
| `.github/skills/` | This project | Project-specific skills |
| `.agents/skills/` | This project | Shared agent-skill layout |
| `.claude/skills/` | This project | Cross-client skill layout |
| `~/.copilot/skills/` | All projects | Personal workflow skills |
| `~/.agents/skills/` | All projects | Personal shared skills |
| Custom directories | Registered with `copilot skill add <directory>` | Shared/custom layouts |
| Plugins | Plugin scope | Bundled skills |

**Project skills** take priority over **personal skills**

```bash
copilot skill add --project ./my-skill/SKILL.md
copilot skill add https://example.com/my-skill/SKILL.md
copilot skill list --json
copilot skill disable my-skill
copilot skill remove my-skill
```

---

## Your Turn! 🚀

Open **Module 6** in `docs/workshop/06-skills.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Create a project skill
- **Exercise 2** — Skill with resource files
- **Exercise 3** — Personal skills
- **Exercise 4** — Discover and install community skills
- **Exercise 5** — Skill with scripts
- **Exercise 6** — Understanding skill auto-selection

⏱️ You have **~16 minutes**
