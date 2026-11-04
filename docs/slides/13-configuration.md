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

- User settings (`settings.json`) and settings scopes
- Environment variables reference
- CLI flags quick reference
- IDE integration (`/ide`, `openDiffOnEdit`)
- Accessibility & streamer mode
- Team configuration standardization
- Logging, debugging, session limits, extensions, and observability

---

## Configuration File

Keep account-history sync off on every workshop launch: `copilot --sync-session=off`.
This is separate from remote control and does not erase earlier uploads.

User settings live in `~/.copilot/settings.json`:

```json
{
  "model": "auto",
  "theme": "github",
  "mouse": true,
  "beep": false,
  "compactPaste": true,
  "includeCoAuthoredBy": true,
  "updateTerminalTitle": true,
  "streamerMode": false
}
```

Override location: `COPILOT_HOME` env var

> ⚠️ `~/.copilot/config.json` is machine-managed and holds your auth token — **never print or share it**

---

## Settings Scopes

| Scope | Location | Set with |
|-------|----------|----------|
| User | `~/.copilot/settings.json` | `/settings <key> <value>` |
| Repo (shared) | `.github/copilot/settings.json` | `/settings --repo ...` |
| Repo (personal) | `.github/copilot/settings.local.json` | `/settings --local ...` |
| Org-managed | Delivered by policy | Read-only, `managed (read-only)` |

Locked managed settings cannot be edited; some managed defaults are overridable.

Repository/local settings support **only a subset** of user keys; theme,
compact paste, and subagent concurrency are user-only.
Shell `config` reads inspect a settings file, not the environment-resolved active model.

**Model scopes** — `/model --repo` / `--local` set the repo default,
`/config model` sets your user default, `/model plan` (or `--plan`) sets the plan-mode model

---

## Key Config Options

| Option | Default | Description |
|--------|---------|-------------|
| `model` | (varies) | AI model |
| `defaultMode` | `"interactive"` | Mode new sessions start in |
| `defaultPermissionMode` | `"manual"` | Permission mode new sessions start in |
| `bannerStyle` | `"mona"` | Banner artwork: `mona` or `classic`; ignored when `banner` is `never` |
| `compactPaste` | `true` | Collapse large pastes |
| `copyOnSelect` | macOS only | Auto-copy selection |
| `includeCoAuthoredBy` | `true` | Co-authored-by in commits |
| `streamerMode` | `false` | Hide model names/quota |
| `companyAnnouncements` | `[]` | Team startup messages |
| `ide.autoConnect` | `true` | Auto-connect to IDE |
| `ide.openDiffOnEdit` | `true` | Diffs in IDE |
| `footer.show*` | (varies) | Individual status bar items |
| `sandbox.*` | (varies) | Command sandboxing policy |

> `copilot help config` is the authoritative reference

---

## Current Interaction Settings

Grouped UI/runtime controls include:

- Alerts: `notifications`, `beepOnSchedule`, `showTipsOnStartup`
- Input/history: `commandHistoryMaxSize`, `compactPaste`, `copyOnSelect`
- Rendering: `scrollbar`, `inlineImages`, `inlineImageLiveWindow`, `renderMarkdown`
- Agent behavior: `stayInAutopilot`, `effortLevel`, `contextTier`, `memory`
- Shell/network: `tabs`, `proxyUrl`, `proxyKerberosServicePrincipal`, `powershellFlags`

---

## Discovery, Extensions & Delegation

| Family | Representative settings |
|--------|--------------------------|
| Discovery | `skillDirectories`, `disabledSkills`, `disabledHooks`, `hooks` |
| MCP/plugins | `disabledMcpServers`, `enabledMcpServers`, `enabledPlugins`, `extraKnownMarketplaces`, `strictKnownMarketplaces` |
| Extensions | `extensions.disabledExtensions`, GitHub MCP tools/toolsets |
| Subagents | `subagents.agents`, `disabledSubagents`, `maxConcurrency`, `maxDepth` |
| Local agents | `customAgents.defaultLocalOnly` |
| Footer | `footer.show*`, custom `statusLine`, `/footer` |

`enabledPlugins` and `extraKnownMarketplaces` are **maps**.
`strictKnownMarketplaces` is a **managed allowlist array**.
`disabledHooks` contains **content-hash IDs**, not names.

---

## Permissions, Sandbox & Voice

- `permissions.allow`, `.ask`, `.deny` are **managed policy rules**, not personal preferences
- `sandbox.*` controls filesystem/network policy, local MCP/LSP isolation,
  bypass, and `git` / `gh` sentinel masking with approved-host HTTPS headers
- `voice.enabled` and `voice.selectedModel` configure `/voice`
- `allowedUrls` / `deniedUrls` and `defaultPermissionMode` set startup policy

> Remote HTTP/SSE MCP servers are outside the command sandbox.
> No experimental prerequisite. Linux needs namespaces/helpers beyond `bwrap`; bypass can expose real credentials.
> `sandbox.userPolicy.filesystem.clearPolicyOnExit` is unsupported; do not set it.

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `COPILOT_GITHUB_TOKEN` | Auth token (highest priority) |
| `COPILOT_HOME` | Override config directory |
| `COPILOT_MODEL` / `COPILOT_GH_HOST` | Model / CLI-specific GitHub host |
| `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` / `COPILOT_SKILLS_DIRS` | Discovery paths |
| `COPILOT_EDITOR` / `VISUAL` / `EDITOR` | Editor precedence |
| `COPILOT_ALLOW_ALL` / `COPILOT_AUTO_UPDATE` / `COPILOT_OFFLINE` | Runtime policy |
| `COPILOT_PROVIDER_*` | Custom model provider (BYOK) |
| `COPILOT_OTEL_*` / `OTEL_*` | OpenTelemetry monitoring |
| `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` | Network proxy family |
| `COPILOT_HOOK_*` / `COPILOT_PLUGIN_DIR_ONLY` | Hook/plugin policy |
| `COPILOT_ASSISTED_APPROVAL` | Env form of `--assisted-approval` |
| `COPILOT_MULTIPLEXER` | Override detected multiplexer: `tmux`, `herdr`, `none` |
| `COPILOT_INLINE_IMAGES_HERDR` | Override automatic detection; renderer/other restrictions still apply |
| `PLAIN_DIFF` | Disable rich diffs |
| `USE_BUILTIN_RIPGREP` / `USE_TGREP` / `USE_TGREP_WARM_START` | Search backend controls |
| `COPILOT_DISABLE_TERMINAL_TITLE` / `COPILOT_INLINE_IMAGE_LIMIT` | Terminal rendering controls |
| `NO_COLOR` | Disable color output |

Extra instruction directories discover `*.instructions.md`, not an `AGENTS.md` substitute.

> `copilot help environment` is the authoritative reference

Exact `COPILOT_ALLOW_ALL=true` also trusts cwd configuration; other truthy values only approve tools.
Codespaces' auto-injected token does not override `/login`; explicit exports do.

---

## Additional CLI Flags

| Flag | Purpose |
|------|---------|
| `-i, --interactive` | Interactive + auto-execute prompt |
| `--mode <mode>` / `--plan` | Start in interactive, plan, or autopilot mode |
| `--output-format json` | JSONL output for scripting |
| `--stream on\|off` | Control streaming |
| `--acp` | Agent Client Protocol server |
| `--no-ask-user` | Fully autonomous |
| `--max-autopilot-continues` | Limit autopilot rounds |
| `--secret-env-vars` | Strip named shell/MCP env values; other tool-result routes can still leak |
| `--no-custom-instructions` | Skip AGENTS.md |
| `--screen-reader` | Accessibility mode |
| `--plain-diff` | Disable rich diffs |
| `--sandbox` | Enable sandboxing; host and managed bypass policy apply |
| `--assisted-approval` | Route approvals via safety judge |
| `--context <tier>` | Context window tier |
| `--log-dir` / `--log-level` | Logging control |
| `--plugin-dir` | Load local plugin |
| `--max-ai-credits` | Session AI credit limit |
| `-n, --name` / `--session-id` | Name or identify a session |
| `--resume` / `--continue` / `--connect` | Resume or connect |
| `--remote` / `--sync-session=on\|off` | Live control / read-only history (separate) |
| `--remote-export` / `--no-remote` | Rejected; history sync and `/remote off` are separate controls |
| `--allow-tool` / `--deny-tool` / `--allow-url` | Permission rules |
| `--available-tools` / `--excluded-tools` | Tool visibility |
| `--additional-mcp-config` / `--enable-all-github-mcp-tools` | MCP startup controls |
| `--attachment` / `--share` / `--share-gist` | Input and export |
| `--no-auto-update` | Disable automatic updates |
| `--extension-sdk-path <directory>` | Override bundled `@github/copilot-sdk` for extensions (invalid path → bundled) |
| `--no-eager-powershell-resolution` | Disable background PowerShell prompt resolution on Windows |

---

## Inspect, Open & Monitor

```text
/env                     # loaded instructions, MCPs, skills, agents,
                         # hooks, plugins, and extensions
/lsp show                # inspect configured language servers separately
/app                     # open Copilot app from a session
```

```bash
copilot app              # open app for the current directory
copilot help monitoring  # OTel exporters, spans, metrics, attributes
copilot help config      # authoritative settings reference
copilot help environment # authoritative environment reference
```

---

## IDE Integration

```
/ide          # Connect to IDE workspace
/copy         # Copy last response to clipboard
```

Streamer mode: merge `{"streamerMode":true}` into personal settings in your editor.
`/settings show streamerMode` reads it; `/settings streamerMode on` cannot edit it.
Restart and verify `Hidden Model` labels in `/model`. Hides selected UI metadata,
not arbitrary secrets, prompts, logs, or exports.

Config options:
- `ide.autoConnect` — auto-connect on startup
- `ide.openDiffOnEdit` — show diffs in IDE

---

## Team Standardization

```json
{
  "companyAnnouncements": [
    "Remember: never commit secrets",
    "Sprint ends this week"
  ],
  "includeCoAuthoredBy": true,
  "model": "auto"
}
```

Share via repository settings:

```
/settings --repo model auto     # .github/copilot/settings.json
/settings --local includeCoAuthoredBy off # supported local key
```

Do not copy the whole user template into repo scope. Keep UI preferences personal;
use a disposable repository without committing for this exercise.

---

## Session Limits

Opt-in soft cap on AI credits for a session

```bash
copilot --sync-session=off --max-ai-credits 30     # minimum is 30
copilot --sync-session=off -p "Read README.md with a file tool; summarize only." --usage-output-file ./usage.json
```

```
/limits                          # interactive dialog
/limits set max-ai-credits 50
/limits unset max-ai-credits
```

> Usage is only known after a response returns, so one call can
> exceed the limit before the next one is blocked

---

## Scriptable Setup and Optional Controls

```bash
copilot config theme
copilot config --repo model auto
copilot config --local includeCoAuthoredBy off
copilot instruction list --json
copilot lsp list --json
```

`--trust-folder`: one-run configuration admission, not tool/path/URL approval.
`--auto-tier` selects advertised Auto routing; dynamic skill retrieval persists.
Stored routing enum values and account-enabled picker choices can differ; verify `/model`.
`--fleet` accepts `-i`/`-p`/stdin; `--plan --mode autopilot` supports implementation.

---

## Trust, Routing, and Persistent Data

- Custom subagents opt into repo instructions; model policy and Auto affect dispatch
- MCP `--enable-mcp-server` is one-run; `--mcp-github-auth server=origin` approves a destination, never a token
- Optional hosted environments and JSONL imports need targeted runtime checks
- BYOK fresh-key commands and vision opt-in depend on the provider
- OpenTelemetry supports environment **and user/managed settings**, including header providers
- Content capture can export private data; keep it off here
- `/clear` is not transcript/log/memory/sync erasure

---

# 🎉 Workshop Complete!

### What you've learned across all modules:

Installation → Modes → Instructions → Tools → MCP → Skills → Plugins
→ Agents → Hooks → Context → Sessions → Advanced → Configuration

**Next steps:** Practice daily, create custom agents, share skills with your team

> Resources: [docs.github.com/copilot](https://docs.github.com/en/copilot) · [agentskills.io](https://agentskills.io)

---

## Your Turn! 🚀

Open **Module 13** in `docs/workshop/13-configuration.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Selected-field inspection and scoped shell/settings commands
- **Exercise 2** — Isolated temporary home, approved credentials only, external `*.instructions.md`, restore prior variables
- **Exercise 3** — IDE integration
- **Exercise 4** — File-based streamer mode, selected metadata only; accessibility
- **Exercise 5** — Team configuration
- **Exercise 6** — Logging and debugging
- **Exercise 7** — Session limits, AI credits, and usage export

⏱️ You have **~14 minutes**
