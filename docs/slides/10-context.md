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

# Module 10: Context Management

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

Use **`/model`** to switch models and inspect available context tiers.

```bash
copilot --context long_context
copilot help config
```

Persist it with `"contextTier": "long_context"` in `~/.copilot/settings.json`

> `~/.copilot/config.json` is managed automatically and holds credentials — never print it.

Available models and context windows depend on your subscription and selected model.

---

## Key Commands

| Command | Action | When to use |
|---------|--------|-------------|
| `/context` | Show token usage | Check regularly |
| `/usage` | Session stats (AI credits, token breakdown, duration, lines edited) | Track consumption |
| `/compact` | Compress history | Long sessions |
| `/clear` | Abandon session and start fresh (session is discarded) | Abandoning session entirely |
| `/new` | Start new conversation (old session stays backgrounded) | New topic, keep old session |
| `/cwd` | Change working directory | Switch project scope |
| `@path/to/file` | Include file in prompt | Targeted context |
| `#<number>` | Include issue/PR/discussion | GitHub context |

---

## Context References & Autocomplete

- Type `@` to autocomplete project files; select one to include its contents
- `@relative`, `@/absolute`, `@~/home`, and `@../parent` paths are supported
- Type `#` to autocomplete GitHub **issues, pull requests, and discussions**
- Use `#123` when the number is unambiguous; the picker resolves repository context

> References are targeted context: prefer them over asking the agent to scan an entire tree.

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
| `/clear` | Abandoning session entirely |
| `/new` | Starting new topic but keeping old session accessible |
| `/compact` | Long session, need to continue |
| Explore agent | Codebase overview without cost |
| `@path/to/file` | Include specific files |
| Batch questions | Multiple related questions |
| Summarize → clear | Preserve knowledge, free space |

---

## Expanded @ Paths

| Syntax | Example | Description |
|--------|---------|-------------|
| `@relative` | `@src/app.js` | Project-relative (original) |
| `@/absolute` | `@/usr/local/config.yaml` | Absolute path |
| `@~/home` | `@~/notes/ideas.md` | Home directory |
| `@../parent` | `@../shared-lib/utils.js` | Parent directory |

> `/add-dir` directories persist across `/clear` and `/resume`
> `/add-dir` accepts **relative paths** like `./src`, `../sibling`
> **Reasoning token usage** shown in per-model breakdown via `/usage`

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
