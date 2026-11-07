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

# Module 12: Advanced Topics

### GitHub Copilot CLI Workshop

---

## Topics Overview

> Local-only validation: append `--sync-session=off` to every session launch,
> including TTY, resumed, fleet, autopilot, and ACP. History sync defaults on.
> Use disposable fixtures, 60–90 second timeouts, and bounded continuations.
> Do not run remote/Gist examples or `/chronicle reindex` in a no-upload exercise.

| Topic | What you'll learn |
|-------|------------------|
| **Autopilot** | Autonomous multi-step execution |
| **Fleet** | Parallel sub-agents |
| **ACP** | Agent Client Protocol server |
| **CI/CD** | Pipeline integration |
| **Environment** | Config, env vars, `--bash-env` |
| **LSP** | Language server configuration |
| **Research & Chronicle** | Deep research, session insights |
| **Team workflows** | Standardization patterns |

---

## Autopilot Mode

**Autonomous continuation** — permissions still apply; it does not grant every tool.

```bash
copilot --autopilot -p "Create an Express API with auth, tests, and docs"

# Limit continuation rounds
copilot --autopilot --max-autopilot-continues 10

# Fully autonomous — no questions
copilot --autopilot --no-ask-user --allow-all-tools

copilot --plan --mode autopilot --max-autopilot-continues 3 \
  -p "Plan and implement a focused test improvement" --allow-tool write
```

Or cycle modes mid-session with `Shift+Tab`:
```
chat → plan → autopilot
```

- **Permission elevation** — shows dialog to prevent auto-denied tool errors
- **Plan approval menu** — model-curated actions incl. **autopilot+fleet** option

> ✅ Boilerplate, well-defined tasks
> ❌ High-risk ops, exploratory work

---

## Fleet Command

**Parallel sub-agents** for complex tasks

```
/fleet "Refactor all components to TypeScript and add tests"
```

```
Your Prompt → Orchestrator
 ↓
 ┌──────┬──────┬──────┬──────┐
 │ Ag 1 │ Ag 2 │ Ag 3 │ Ag 4 │ parallel!
 └──────┴──────┴──────┴──────┘
 ↓
 Orchestrator validates
 ↓
 Consolidated output
```

> Orchestrator validates sub-agent work and runs a **bounded multiple** of
> subagents concurrently; settings and account limits cap parallelism.

Launch directly: `copilot --fleet -i "Add tests for independent modules"`.
Custom specialists need `include-custom-instructions: true` for repo guidance.
Models/policies/Auto affect dispatch; inspect actual tasks.

---

## PRs, Background Agents & Experiments

- `/pr` creates/views PRs and can fix CI failures, review feedback, and conflicts
- `/pr view local` shows local status; `/pr view web` opens the browser
- Background tasks appear in the timeline with expandable notifications
- `write_agent` continues a multi-turn conversation; `read_agent` includes the
  inbound messages that triggered each turn
- Background agents have readable names; follow-ups use the returned `agent_id`
- `/experimental on|off` restarts the CLI automatically to apply the change

---

## Monorepos & Monitoring

- Discovery is resource-specific; project agents/MCP walk cwd to root;
  instructions also use relevant nested paths, with modular exceptions
- `copilot help monitoring` documents OpenTelemetry exporters and attributes
- Monitoring includes internal subagent spans and `time_to_first_chunk` latency

Use `copilot help monitoring` for exporter setup; Module 13 groups the OpenTelemetry environment families.

---

## ACP Clients & MCP Injection

ACP clients can provide MCP server configuration while starting or loading a
session. IDE integrations use this to inject client-specific tools without
changing personal MCP configuration.

---

## Status Line & Startup UI

- `statusLine` can run a custom shell command; `/statusline` configures it
- Startup shows environment loading progress
- Narrow terminals switch the footer to a responsive two-line layout
- Independent tool calls execute in parallel automatically
- `copilot --help` supplies descriptions and examples; workshop tables are selected controls

---

## CI/CD Integration

```yaml
# Steps excerpt — trusted PRs only; see full workflow in Module 12
- uses: actions/checkout@main
  with:
    ref: ${{ github.event.pull_request.head.sha }}
    fetch-depth: 0
- name: Review supplied diff
  env:
    COPILOT_GITHUB_TOKEN: ${{ secrets.COPILOT_PAT }}
    BASE_SHA: ${{ github.event.pull_request.base.sha }}
  run: |
    git diff "$BASE_SHA" HEAD | copilot -p "Review this diff only" \
      --available-tools 'view,grep,glob' --deny-tool shell --deny-tool write \
      --no-custom-instructions --disable-builtin-mcps --silent
```

Key flags for automation: `--silent`, `--allow-tool`, `--deny-tool`, `--usage-output-file`

For npm scripts, `--allow-tool 'shell(npm run:*)'` matches the command stem;
it approves all `npm run` scripts, so review them first.

> Pin Actions to an approved immutable commit in your workflow.
> `write` denial does not cover shell writes; exclude shell for read/search analysis.

---

## Tool Visibility vs Permissions

```bash
# Only these tools are visible to the model
copilot --available-tools 'bash,view,glob,grep'

# Hide specific tools from the model
copilot --excluded-tools 'create,edit,web_fetch'
```

> `--available-tools` / `--excluded-tools` filter by **tool name** — which tools the model can see
> `--allow-tool` / `--deny-tool` take permission **rule kinds** like `shell(git:*)` and `write(path)`

---

## Environment & Configuration

Precedence is key-specific; `COPILOT_HOME` selects storage and managed policy can constrain overrides.

| File | Purpose |
|------|---------|
| `~/.copilot/settings.json` | User settings |
| `~/.copilot/config.json` | Machine-managed state + credentials — **do not print** |
| `~/.copilot/mcp-config.json` | MCP servers |
| `~/.copilot/lsp-config.json` | Language server definitions |

```bash
# Open the GitHub Copilot app in the current directory (`/app` in-session)
copilot app

# Source custom env in shell sessions
copilot --bash-env

# Custom config location
export COPILOT_HOME=/custom/path

# Auth tokens (in order of precedence)
export COPILOT_GITHUB_TOKEN="github_pat_..." # highest priority
export GH_TOKEN="github_pat_..."
export GITHUB_TOKEN="github_pat_..." # lowest priority
export COPILOT_GH_HOST="github.example.com" # CLI-specific GitHub host
```

Codespaces' auto-injected `GITHUB_TOKEN` does not override `/login`; explicit exports do.

---

## BYOK & Offline Mode

**Bring Your Own Key** — set `COPILOT_PROVIDER_BASE_URL` to activate BYOK mode with a custom model provider. GitHub authentication is not required when using a custom provider.

```bash
# Ollama (local, no API key required)
COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1 \
  COPILOT_MODEL=local-code-model \
  copilot
```

**Offline mode** — `COPILOT_OFFLINE=true` skips all network access: GitHub authentication, telemetry, web tools, GitHub MCP server, and auto-update are disabled. Requires a local model provider.

> `copilot help providers` documents Azure, Anthropic, and OpenAI-compatible providers

`COPILOT_PROVIDER_API_KEY_COMMAND` obtains fresh keys; `COPILOT_PROVIDER_VISION=true`
requires a capable model. Named `providers.json` is optional and credential-bearing.

---

## Additional Runtime Controls

`--version` checks the binary, not authentication. Authenticate before scripted requests.
For `--bash-env`, use the same `~/.copilot_env` created in Exercise 6.
Test direct `!` shell access separately: it can use `/bin/sh` without sourcing
the file. Explicitly use Bash and source the reviewed `~/.copilot_env` if needed;
Bash-specific function names are not portable. Do not run the commit helper.

```bash
copilot --no-bash-env                  # do not source BASH_ENV
copilot --enable-memory                # memory in prompt mode
copilot --allow-all-mcp-server-instructions
copilot --mouse off                    # or --no-mouse
```

Use `/diagnose` for a guided troubleshooting check; pair it with
`/collect-debug-logs`, `copilot help logging`, and `copilot help monitoring`.

---

## Language Servers

None run by default — define them explicitly

```json
{
  "lspServers": {
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"],
      "fileExtensions": { ".ts": "typescript", ".tsx": "typescriptreact" }
    }
  }
}
```

`~/.copilot/lsp-config.json` (personal) · `.github/lsp.json` (project)

Use the module's explicit merge procedure; preserve unrelated entries.

```
/lsp show        # configured servers
/lsp test NAME   # does it start?
/lsp reload      # reload from disk
/lsp logs        # live status + server logs
```

Verify a real definition/reference request, not just startup. An immediate-exit
test failure remains a diagnostic failure even if the services panel says ready.

---

## Help Topics & Session Limits

```bash
copilot help billing
copilot help config
copilot help monitoring
copilot help sandbox
```

Other topics: `commands`, `environment`, `limits`, `logging`, `permissions`, `providers`.

**Session limits are opt-in** — a soft cap on AI credits

```bash
copilot --max-ai-credits 30        # minimum is 30
```

```
/limits                            # interactive dialog
/limits set max-ai-credits 50
/limits unset max-ai-credits
```

> `/clear` and `/new` reset used credits but keep the limit

---

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc

alias cop='copilot'
alias cop-analyze='copilot --available-tools "view,grep,glob" --deny-tool shell --deny-tool write'
alias cop-safe='copilot --allow-tool "shell(cat)" --allow-tool "shell(grep)" --deny-tool write'
alias cop-yolo='copilot --yolo'
alias cop-resume='copilot --continue'
```

`cop-safe` is restricted guidance, not a filesystem read-only boundary.

---

## Trust, Sandbox, and Sync

- `--trust-folder` admits cwd config for one new prompt-mode run, not all permissions
- Exact `COPILOT_ALLOW_ALL=true` also trusts executable cwd configuration
- `/sandbox enable` / `--sandbox`: available without experimental mode
- Linux needs namespaces/network helpers beyond `bwrap`; Docker alone is not proof
- Credential masking: approved-host HTTPS headers; bypass exposes host credentials
- `--sync-session=on|off`: read-only history; `/remote off`: stop live control
- **Removal candidates:** `--remote-export`, `--no-remote` are rejected; do not run
- `--host-environment` / `--host-compute-id`: optional hosted-execution reference

---

## Team Workflow Patterns

- Commit shared guidance in `.github/copilot-instructions.md`
- Layer directory-specific rules with `AGENTS.md` and `.github/instructions/`
- Share instructions, skills, agents, hooks, MCP, and LSP config with the repo
- Shared MCP: `mcpServers`, explicit `type`, top-level `headers`; `servers`/`requestInit` is an inactive removal candidate
- Use least-privilege rules and policy-approved marketplaces
- Standardize CI prompts and save usage output for auditability

---

## /research & /chronicle

**`/research`** — deep-research workflow with exportable reports:
```
/research "Compare REST vs GraphQL for mobile backends"
```

**`/chronicle`** (experimental) — session-history insights:
```
/chronicle standup    # your work from the last day
/chronicle search     # search all session content
/chronicle tips       # personalized usage tips
/chronicle cost-tips  # reduce token usage and cost
/chronicle improve    # improve copilot-instructions.md
/chronicle reindex    # rebuild local store AND sync to account; not for no-upload runs
```

> ⚠️ `/chronicle` is experimental — subcommands may change

Research report export: `/share file research ./research-report.md`.
Read/search-only tools can produce findings but fail to create the report.
A zero-row history search is not proof of retrieval; do not enable sync to fix it.

---

## Your Turn! 🚀

Open **Module 12** in `docs/workshop/12-advanced.md`

**Start from Exercise 1** and work through as many as you can

- **Exercise 1** — Environment variables
- **Exercise 2** — CI checkout, explicit PR base, trusted code, read/search review
- **Exercise 3** — Advanced CLI flags
- **Exercise 4–5** — Autopilot mode & fleet command
- **Exercise 6** — Shell config & `--bash-env`
- **Exercise 7** — Merge language server config and verify startup
- **Exercise 8–10** — Settings, troubleshooting & team workflows
- **Exercise 11** — Performance optimization
- **Exercise 12** — `/research` deep research & `/chronicle` insights

⏱️ You have **~24 minutes**
