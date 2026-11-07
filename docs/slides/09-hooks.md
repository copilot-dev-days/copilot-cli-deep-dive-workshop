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

# Module 9: Hooks

### GitHub Copilot CLI Workshop

---

## What are Hooks?

**Custom scripts** that run at key points in the agent lifecycle

```
Session start → Prompts → Pre-Tool → Execute → Success/failure → Session end
   ↓           ↓            ↓                     ↓           ↓
 Hook        Hook         Hook                  Hook        Hook
```

Use cases: **logging**, **security guardrails**, **auditing**, **alerts**

---

## Hook Types

| Hook | Trigger | Common use |
|------|---------|-----------|
| `sessionStart` / `sessionEnd` | Session starts/resumes, ends | Logging, cleanup |
| `userPromptSubmitted` | User sends prompt | Audit trail |
| `userPromptTransformed` | Prompt turned into model-facing form | Prompt rewriting |
| `preToolUse` | Before tool runs | **Permission control** |
| `preMcpToolCall` | **Unverified** | Not in public reference; runtime evidence required |
| `postToolUse` | After successful tool run | Verification, logging |
| `postToolUseFailure` | After tool failure | Error handling |
| `errorOccurred` | Internal errors with context/recoverability | Alerts, monitoring |
| `preCompact` | Before compaction | State saving |
| `agentStop` | Agent stops at end of turn | Turn-level automation |
| `subagentStart` / `subagentStop` | Sub-agent spawned / completed | Context injection, results |
| `permissionRequest` | Permission requested | Programmatic approve/deny |
| `notification` | Shell/agent completion, permissions | External notifications |

---

## ⚠️ Trust Is Required

**Repository hooks only run in trusted folders**

- Session-only admission is sufficient; review hooks first
- `--trust-folder` admits one new prompt-mode run without saving trust

In an untrusted folder, `.github/hooks/*.json` is discovered but **never executed** — and **no error is shown**

Personal hooks in `~/.copilot/hooks/` run regardless of trust

Exact `COPILOT_ALLOW_ALL=true` also trusts executable cwd configuration.

**Do this before Exercise 1.**

---

## Hook Locations

| Scope | Location |
|-------|----------|
| **Repository** | any `*.json` in `<git root>/.github/hooks/` |
| **Personal** | any `*.json` in `~/.copilot/hooks/` |
| **Inline** | personal `settings.json` or repo `.github/copilot/settings.json` / `settings.local.json` |

> Do not hand-edit global `config.json`; it is machine-managed and holds credentials.
> Put personal hooks in `~/.copilot/hooks/` and repository hooks in repository settings.

Turn hooks off with `disableAllHooks`, or suppress content-hash IDs with `disabledHooks`
(policy hooks ignore both)

Repository settings disable hooks across sources; a hook-file flag disables only that file.

---

## Configuration

Lives in any `*.json` file under `.github/hooks/` — e.g. `hooks.json`

```json
{
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": ".github/hooks/scripts/check-tool.sh",
        "powershell": ".github/hooks/scripts/check-tool.ps1",
        "cwd": ".",
        "timeoutSec": 10
      }
    ]
  }
}
```

The PowerShell path is schematic: author and test that counterpart before using
it on Windows. The module supplies the Bash implementation only.

---

## Compatible Hook Schemas

Copilot accepts native and Claude-compatible hook files:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "./check.sh" }]
    }]
  }
}
```

`./check.sh` is a placeholder for your own compatible-payload validator, not a
script supplied by the workshop.

- PascalCase event names and nested `matcher` / `hooks` are supported
- Optional `type` and `version` fields may be present; `version` may be omitted
- camelCase keys use the native Copilot payload; PascalCase uses the compatible payload

---

## Payload Shape Follows the Key

Most payload fields follow event-key casing; check event-specific exceptions

| Event key | Payload fields |
|-----------|----------------|
| camelCase `preToolUse` | `sessionId`, ms timestamp, `cwd`, `toolName`, unknown-typed `toolArgs` |
| PascalCase `PreToolUse` | `hook_event_name`, `session_id`, ISO timestamp, `tool_name`, `tool_input` |

Use **camelCase** for Copilot CLI; use **PascalCase** to reuse a VS Code or Claude Code hooks file

Native notifications mix camelCase session fields with `hook_event_name` /
`notification_type`. Permission requests use `toolInput`.
`toolArgs` can be an object, JSON-encoded string, or raw patch text.

---

## Session Logging

Track session start/end with `sessionStart` and `sessionEnd`

```json
{
  "sessionStart": [{
    "type": "command",
    "bash": "echo \"[$(date -Iseconds)] SESSION_START\" >> logs/audit.log",
    "cwd": ".",
    "timeoutSec": 5
  }],
  "sessionEnd": [{
    "type": "command",
    "bash": "echo \"[$(date -Iseconds)] SESSION_END\" >> logs/audit.log",
    "cwd": ".",
    "timeoutSec": 5
  }]
}
```

**Use case:** Audit trail, usage metrics, compliance

> Session lifecycle includes resumed starts (`startup`, `resume`, `new`) and `/clear` endings. Validate ordering; use prompt hooks for per-prompt work.
> Preserve configs in separate exercise files; session-ID-keyed private state avoids shared `/tmp` collisions.
> Two interactive prompts share one start; `/clear` and `/exit` end with `user_exit`.
> `--trust-folder` conflicts with `--resume`; admit trust again interactively when needed.
> Prompt completion uses `complete`; autopilot can repeat completion endings.

---

## Pre-Tool Permission Control

`preToolUse` supports **three** permission decisions

| Decision | Behavior |
|----------|----------|
| `allow` | Allow the tool to execute |
| `deny` | Block the tool with a reason |
| `ask` | Prompt the user for confirmation before executing |

```json
{
  "permissionDecision": "allow|deny|ask",
  "permissionDecisionReason": "Explanation shown to user"
}
```

> Without an interactive approver, `ask` is denied (including prompt mode/autopilot).
> Command errors deny; **timeouts fail open**. HTTP pre-tool failures also fail open.

---

## Blocking a Dangerous Command

```bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
ARGS=$(echo "$INPUT" | jq '.toolArgs | if type == "string" then fromjson else . end')
COMMAND=$(echo "$ARGS" | jq -r '.command')

if [[ "$COMMAND" == *"sudo"* ]]; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"sudo not allowed"}'
  exit 0
fi
echo '{}'
```

> Illustrative substring checks are bypassable. Never test destructive commands or treat hooks as a complete security boundary.

---

## Reshaping the Tool Call

Object mutation changes execution; verify actual output and a disposable side effect.
The displayed tool call can still show the original arguments.

| Field | Effect |
|-------|--------|
| `modifiedArgs` | Replace tool arguments with an **object** |
| `updatedInput` | Not a documented pre-tool field; do not use here |
| `additionalContext` | Supported by other events, not a pre-tool decision field |

```json
{
  "modifiedArgs": {"command": "ls -la --color=never"}
}
```

> `exec`/`args` avoid shell expansion; HTTP/prompt hooks, matchers, progress, agent-scoped hooks, and bounded stop continuation are reference options, not security guarantees.

---

## Hook Environment & Notifications

Plugin-packaged hooks receive stable paths:

- `PLUGIN_ROOT` / `COPILOT_PLUGIN_ROOT` / `CLAUDE_PLUGIN_ROOT`
- `PLUGIN_DATA` / `COPILOT_PLUGIN_DATA` / `CLAUDE_PLUGIN_DATA`
- `COPILOT_PROJECT_DIR` / `CLAUDE_PROJECT_DIR`

Ordinary repository hooks need not have plugin installation/data directories.

The `notification` family covers **background shell completion**, **permission
prompts**, **elicitation/questions**, and **background subagent completion** — useful for
desktop, Slack, or monitoring integrations.

---

## Post-Tool Logging

Log tool results with `postToolUse`

```bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
RESULT=$(echo "$INPUT" | jq -r '.toolResult.resultType')

echo "[$(date -Iseconds)] $TOOL_NAME: $RESULT" >> logs/audit.log
```

> `postToolUse` receives success. Register `postToolUseFailure` for its `error` field.
> Internal errors use `.error.name`, `.error.message`, `errorContext`, and `recoverable`.
> Read a nonexistent disposable file once to test failure logging: expect
> `TOOL_COMPLETE: view result=failure` and an alert. Its error is a string.
> A synthetic nested-error replay does not prove `errorOccurred` fired.
> Path guards require recognized direct write tools; raw `apply_patch` input is not covered.

---

## Your Turn! 🚀

Open **Module 9** in `docs/workshop/09-hooks.md`

> **First:** make sure your folder is trusted, or none of the repository hooks will run.

**Exercises 1-7:**
1. **Exercise 1** — Trust the folder + create hooks skeleton
2. **Exercise 2** — Session logging hooks
3. **Exercise 3** — Prompt auditing hook
4. **Exercise 4** — Pre-tool permission control
5. **Exercise 5** — Success + failure logging
6. **Exercise 6** — Nested error payload fields
7. **Exercise 7** — Normalized-path illustration (not a security boundary)

⏱️ You have **~16 minutes**
