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

# Module 13: Configuration & Environment

### GitHub Copilot CLI Workshop

---

## Topics

- Configuration file (`config.json`) options
- Environment variables reference
- CLI flags quick reference
- IDE integration (`/ide`, `open_diff_on_edit`)
- Accessibility & streamer mode
- Team configuration standardization
- Logging and debugging

---

## Configuration File

All settings live in `~/.copilot/config.json`:

```json
{
  "model": "claude-sonnet-4.6",
  "theme": "auto",
  "mouse": true,
  "beep": true,
  "compactPaste": true,
  "includeCoauthor": true,
  "updateTerminalTitle": true,
  "streamerMode": false
}
```

Override location: `COPILOT_HOME` env var or `--config-dir` flag

---

## Key Config Options

| Option | Default | Description |
|--------|---------|-------------|
| `model` | (varies) | AI model |
| `compactPaste` | `true` | Collapse large pastes |
| `copyOnSelect` | macOS only | Auto-copy selection |
| `includeCoauthor` | `true` | Co-authored-by in commits |
| `streamerMode` | `false` | Hide model names/quota |
| `companyAnnouncements` | `[]` | Team startup messages |
| `ide.autoConnect` | `true` | Auto-connect to IDE |
| `ide.openDiffOnEdit` | `true` | Diffs in IDE |

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `COPILOT_GITHUB_TOKEN` | Auth token (highest priority) |
| `COPILOT_HOME` | Override config directory |
| `COPILOT_MODEL` | Default model |
| `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | Extra instruction dirs |
| `COPILOT_EDITOR` | Editor for plans/prompts |
| `PLAIN_DIFF` | Disable rich diffs |
| `USE_BUILTIN_RIPGREP` | Use system ripgrep |
| `NO_COLOR` | Disable color output |

---

## Additional CLI Flags

| Flag | Purpose |
|------|---------|
| `-i, --interactive` | Interactive + auto-execute prompt |
| `--output-format json` | JSONL output for scripting |
| `--stream on\|off` | Control streaming |
| `--acp` | Agent Client Protocol server |
| `--no-ask-user` | Fully autonomous |
| `--max-autopilot-continues` | Limit autopilot rounds |
| `--secret-env-vars` | Redact env values |
| `--no-custom-instructions` | Skip AGENTS.md |
| `--screen-reader` | Accessibility mode |
| `--plain-diff` | Disable rich diffs |
| `--config-dir` | Override config dir |
| `--log-dir` / `--log-level` | Logging control |
| `--plugin-dir` | Load local plugin |

---

## IDE Integration

```
/ide          # Connect to IDE workspace
/copy         # Copy last response to clipboard
/streamer-mode  # Toggle streamer mode
```

Config options:
- `ide.auto_connect` -- auto-connect on startup
- `ide.open_diff_on_edit` -- show diffs in IDE

---

## Team Standardization

```json
{
  "companyAnnouncements": [
    "Remember: never commit secrets",
    "Sprint 14 ends Friday"
  ],
  "includeCoauthor": true,
  "model": "gpt-4.1"
}
```

Distribute via shared config templates in your repo.

---

## New Config & Flags (v1.0.3–v1.0.16)

| Feature | Details |
|---------|---------|
| `mergeStrategy` | Replaces `merge_strategy` ⚠️ (v1.0.3) |
| `--reasoning-effort` | Control model reasoning level (v1.0.4) |
| `--effort` | Shorthand for `--reasoning-effort` (v1.0.10) |
| `--binary-version` | Check version without launching (v1.0.3) |
| `GH_HOST` | Override GitHub API hostname |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy support |
| `NO_PROXY` | Bypass proxy for specific hosts |
| camelCase config | All config keys now prefer camelCase (v1.0.10+) |

---

## Your Turn!

### Recommended exercises from Module 13:

1. **Exercise 1** -- Explore config.json options
2. **Exercise 2** -- Environment variable control
3. **Exercise 3** -- IDE integration
4. **Exercise 4** -- Streamer mode & accessibility
5. **Exercise 5** -- Team configuration
6. **Exercise 6** -- Logging and debugging
