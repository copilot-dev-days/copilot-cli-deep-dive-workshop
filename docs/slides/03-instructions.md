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

# Module 3: Custom Instructions

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

## Files That Shape Behavior

| File | Scope | Think of it as... |
|------|-------|-------------------|
| `AGENTS.md` | Directory tree | **"Who you are"** |
| `CLAUDE.md` / `GEMINI.md` | Root/cwd/intermediate/relevant nested paths | Cross-tool guidance |
| `.github/copilot-instructions.md` | Whole repo | **"How we code here"** |
| `.github/instructions/*.instructions.md` | File patterns | **"Special rules for these files"** |

---

## Instruction Scope and Discovery

Applicable files combine — **no general precedence order**

```
1. Your prompt (task request, not file priority)
2. AGENTS.md (standard directory discovery)
   + CLAUDE.md / .claude/CLAUDE.md / GEMINI.md
3. .github/copilot-instructions.md
4. .github/instructions/**/*.instructions.md
5. ~/.copilot/copilot-instructions.md (personal)
6. ~/.copilot/instructions/**/*.instructions.md
7. COPILOT_CUSTOM_INSTRUCTIONS_DIRS
8. Built-in guidance
```

> Avoid conflicts. Modular repository files exclude intermediate discovery and apply by `applyTo`.

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
- Never modify database change files without explicit permission
- Never commit directly to main
- Never remove tests

## Commit Conventions
Format: `<type>(<scope>): <description>`
Example: `feat(auth): add password reset endpoint`
```

For Exercise 5: `feat(examples): add feature.js with hello world logging`.
Check suggestions against the required scope; ask for corrections when needed.
Instructions guide behavior — they do not guarantee compliance or enforce permissions.

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

## `applyTo` Accepts Two Forms

```yaml
# Comma-separated string
applyTo: "**/*.ts,**/*.tsx"
```

```yaml
# YAML array
applyTo:
  - "**/*.ts"
  - "**/*.tsx"
```

- Files with `applyTo` are **consolidated into a single table** in `/instructions`
  output — grouping them reduces context usage
- Instruction files discovered from **multiple paths are deduplicated** — each
  unique file is loaded only once

---

## Controlling What Gets Loaded

Start without any custom instructions at all:

```bash
copilot --no-custom-instructions
```

Add extra directories for instruction discovery, beyond the git root and cwd:

```bash
export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="/path/to/shared-instructions,/path/to/team-standards"
copilot
```

Comma-separated list of directories — useful for shared team standards kept
outside the repository. Overlapping discovery is deduplicated; this is not a priority tier.

Shell: `copilot init` generates instructions; `copilot instruction list --json` inventories sources.

Custom subagents opt in with `include-custom-instructions: true`; parent-only extra directories are not inherited.

---

## System Message Customization

The experimental **customize** mode can override selected sections of the
system prompt without replacing the whole message.

> Keep project guidance in instruction files. **Module 13** covers the experimental
> toggle; consult `copilot help config` for customization configuration details.

---

## Practical Tips

- **Be specific** — ❌ "Be helpful" → ✅ "You are a senior React developer"
- **Include boundaries** — explicit DO NOT sections
- **Show examples** — code snippets of preferred patterns
- **Use `/instructions`** — see what's active, toggle on/off
- **Nest `AGENTS.md`** — subdirectories can have their own persona

After editing instructions, restart/resume the session or use `/new` to load changes.

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

