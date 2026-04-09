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

# Module 11: Context Management

### GitHub Copilot CLI Workshop

---

## What's in the Context Window?

```
┌──────────────────────────────────────┐
│ System Instructions (AGENTS.md) │ fixed overhead
├──────────────────────────────────────┤
│ Conversation History │ grows with chat
├──────────────────────────────────────┤
│ File Contents │ can be large
├──────────────────────────────────────┤
│ Tool Results │ varies
├──────────────────────────────────────┤
│ ← Space left for response → │ shrinks!
└──────────────────────────────────────┘
```

When full → **auto-compaction** at ~95% capacity

---

## Models & Token Limits

| Model (example) | Approximate Limit |
|-------|-------------------|
| GPT-4 | ~128K tokens |
| GPT-4.1 | ~128K tokens |
| Claude Sonnet 4 | ~200K tokens |

Use **`/model`** to switch models. Available models change frequently — check your session for the current list.

> ⚠️ Model names above are illustrative. Availability varies by subscription tier. Previous versions auto-migrated users from claude-sonnet-4.5.

---

## Key Commands

| Command | Action | When to use |
|---------|--------|-------------|
| `/context` | Show token usage | Check regularly |
| `/usage` | Session stats (requests, duration, lines edited) | Track consumption |
| `/compact` | Compress history | Long sessions |
| `/clear` | Reset everything | Switching topics |
| `/cwd` or `/cd` | Change working directory | Switch project scope |
| `@path/to/file` | Include file in prompt | Targeted context |
| `#<number>` | Include issue/PR/discussion | GitHub context |

---

## Context-Efficient Prompting

**❌ Wasteful:**
```
Read all files in src/ and explain each one
```

**✅ Efficient:**
```
List files in src/
```
then selectively:
```
Show me just @src/auth/middleware.ts
```

> Load on-demand, not all at once. Use `@path/to/file` to include specific files.

---

## Optimization Strategies

| Strategy | When |
|----------|------|
| `/clear` | Switching to unrelated topic |
| `/compact` | Long session, need to continue |
| Explore agent | Codebase overview without cost |
| `@path/to/file` | Include specific files |
| Batch questions | Multiple related questions |
| Summarize → clear | Preserve knowledge, free space |

---

## Expanded @ Paths (v1.0.5+)

| Syntax | Example | Description |
|--------|---------|-------------|
| `@relative` | `@src/app.js` | Project-relative (original) |
| `@/absolute` | `@/usr/local/config.yaml` | Absolute path |
| `@~/home` | `@~/notes/ideas.md` | Home directory |
| `@../parent` | `@../shared-lib/utils.js` | Parent directory |

> `/add-dir` directories now **persist** across `/clear` and `/resume` (v1.0.3)

---

## Your Turn! 🚀

Open **Module 10** in `docs/workshop/10-context.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Monitor context usage
- **Exercise 2** — Manual compaction
- **Exercise 3** — Context-efficient prompting
- **Exercise 4** — Large codebases
- **Exercise 5** — Context window optimization
- **Exercise 6** — Auto-compaction
- **Exercise 7** — Context-aware workflow

⏱️ You have **~12 minutes**

