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

# Module 7: Agent Skills

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
    └── templates/         ← Optional: code templates
```

```yaml
---
name: api-docs
description: Generates API documentation from source code
---

# Markdown body with detailed instructions...
```

---

## Skill Locations

| Location | Scope | Use case |
|----------|-------|----------|
| `.github/skills/` | This project | Project-specific skills |
| `~/.copilot/skills/` | All projects | Personal workflow skills |

**Project skills** take priority over **personal skills**

> Community skills available at [agentskills.io](https://agentskills.io)

---

## Your Turn! 🚀

Open **Module 6** in `docs/workshop/06-skills.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Create a project skill
- **Exercise 2** — Skill with resource files
- **Exercise 3** — Personal skills
- **Exercise 4** — Discover skills from agentskills.io
- **Exercise 5** — Skill with scripts
- **Exercise 6** — Skill invocation

⏱️ You have **~16 minutes**

