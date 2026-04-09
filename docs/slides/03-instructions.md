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

# Module 4: Custom Instructions

### GitHub Copilot CLI Workshop

---

## Why Custom Instructions?

Without instructions, Copilot **guesses** your preferences

With instructions, Copilot **knows**:
- Your coding standards
- Your project architecture
- Your preferred patterns
- What it should **never** do

---

## Three Files That Shape Behavior

| File | Scope | Think of it as... |
|------|-------|-------------------|
| `AGENTS.md` | Directory tree | **"Who you are"** |
| `.github/copilot-instructions.md` | Whole repo | **"How we code here"** |
| `.github/instructions/*.instructions.md` | File patterns | **"Special rules for these files"** |

---

## Instruction Priority

Highest wins ↓

```
1. Your prompt                              ← always wins
2. AGENTS.md (nearest in directory tree)
3. .github/copilot-instructions.md
4. .github/instructions/*.instructions.md
5. ~/.copilot/instructions.md (personal)
6. Default behavior                         ← fallback
```

> They **stack** — all active instructions are combined

---

## copilot-instructions.md

**Repo-wide coding standards** in `.github/copilot-instructions.md`

```markdown
# Code Style
- Use 2 spaces for indentation
- Prefer `const` over `let`
- Add JSDoc comments for all public functions

# Security
- Never hardcode secrets
- Validate all user input
```

---

## AGENTS.md

**Agent persona & boundaries** at project root

```markdown
# Agent Instructions

You are a senior TypeScript engineer.

## DO NOT
- Never modify migration files without permission
- Never commit directly to main
- Never remove tests

## Commit Conventions
Format: `<type>(<scope>): <description>`
Example: `feat(auth): add password reset endpoint`
```

---

## Path-Specific Instructions

**Different rules for different files** via `applyTo` glob

```markdown
---
applyTo: "**/*.test.ts,**/*.spec.ts"
---

# Test File Instructions

- Use AAA pattern: Arrange, Act, Assert
- One assertion concept per test
- Mock external dependencies, not internal modules
```

Saved as `.github/instructions/tests.instructions.md`

---

## Practical Tips

- **Be specific** — ❌ "Be helpful" → ✅ "You are a senior React developer"
- **Include boundaries** — explicit DO NOT sections
- **Show examples** — code snippets of preferred patterns
- **Use `/instructions`** — see what's active, toggle on/off
- **Nest `AGENTS.md`** — subdirectories can have their own persona

---

## New in v1.0.6–v1.0.16

- **`applyTo`** now accepts **YAML arrays** (v1.0.6+):
  ```yaml
  applyTo:
    - "**/*.ts"
    - "**/*.tsx"
  ```
- **"Customize" mode** for system message overrides (v1.0.7+)
- **`COPILOT_CUSTOM_INSTRUCTIONS_DIRS`** for extra instruction paths
- **Monorepo discovery** — instructions found from cwd up to git root (v1.0.11+)

---

## Your Turn! 🚀

Open **Module 3** in `docs/workshop/03-instructions.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Create `copilot-instructions.md`
- **Exercise 2** — Create `AGENTS.md`
- **Exercise 3** — Path-specific instructions
- **Exercise 4** — Nested `AGENTS.md`
- **Exercise 5** — Commit convention enforcement

⏱️ You have **~12 minutes**

