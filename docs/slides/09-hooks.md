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
Prompt → Session Start → Pre-Tool → Execute → Post-Tool → Session End
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
| `preMcpToolCall` | Before an MCP tool request is sent | Adjust MCP metadata |
| `postToolUse` | After successful tool run | Verification, logging |
| `postToolUseFailure` | After tool failure | Error handling |
| `errorOccurred` | A model call fails | Alerts, monitoring |
| `preCompact` | Before compaction | State saving |
| `agentStop` | Agent stops at end of turn | Turn-level automation |
| `subagentStart` / `subagentStop` | Sub-agent spawned / completed | Context injection, results |
| `permissionRequest` | Permission requested | Programmatic approve/deny |
| `notification` | Shell/agent completion, permissions | External notifications |

---

## ⚠️ Trust Is Required

**Repository hooks only run in trusted folders**

- Answer **Yes, and remember** at the trust prompt
- Or add the path to `trustedFolders`

In an untrusted folder, `.github/hooks/*.json` is discovered but **never executed** — and **no error is shown**

Personal hooks in `~/.copilot/hooks/` run regardless of trust

**Do this before Exercise 1.**

---

## Hook Locations

| Scope | Location |
|-------|----------|
| **Repository** | any `*.json` in `<git root>/.github/hooks/` |
| **Personal** | any `*.json` in `~/.copilot/hooks/` |
| **Inline** | the `hooks` key — user-level from managed global config, repo-level in `settings.json` |

> Do not hand-edit global `config.json`; it is machine-managed and holds credentials.
> Put personal hooks in `~/.copilot/hooks/` and repository hooks in repository settings.

Turn hooks off with `disableAllHooks`, or suppress individual ones with `disabledHooks`
(policy hooks ignore both)

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

- PascalCase event names and nested `matcher` / `hooks` are supported
- Optional `type` and `version` fields may be present; `version` may be omitted
- camelCase keys use the native Copilot payload; PascalCase uses the compatible payload

---

## Payload Shape Follows the Key

The event key's casing decides the payload — the two shapes never mix

| Event key | Payload fields |
|-----------|----------------|
| camelCase `preToolUse` | `sessionId`, `timestamp` (ms), `cwd`, `toolName`, `toolArgs` (JSON **string**) |
| PascalCase `PreToolUse` | `hook_event_name`, `session_id`, `timestamp` (ISO 8601), `cwd`, `tool_name`, `tool_input` (JSON **object**) |

Use **camelCase** for Copilot CLI; use **PascalCase** to reuse a VS Code or Claude Code hooks file

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

> `sessionStart` and `sessionEnd` fire **once per session**, not once per prompt.
> Use `userPromptSubmitted` for per-prompt behavior.

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

> `ask` lets hooks request confirmation instead of silently allowing or denying

---

## Blocking a Dangerous Command

```bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
ARGS=$(echo "$INPUT" | jq -r '.toolArgs | fromjson')
COMMAND=$(echo "$ARGS" | jq -r '.command')

if [[ "$COMMAND" == *"sudo"* ]]; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"sudo not allowed"}'
  exit 0
fi
echo '{}'
```

> **Note:** Copilot has built-in safety that blocks some commands (like `rm -rf /`) before hooks run. Use hooks for organization-specific policies.

---

## Reshaping the Tool Call

`preToolUse` hooks can also return these fields — the CLI respects them

| Field | Effect |
|-------|--------|
| `modifiedArgs` | Replace the tool arguments (JSON string) |
| `updatedInput` | Replace the prompt text |
| `additionalContext` | Inject extra context for the turn |

```json
{
  "modifiedArgs": "{\"command\": \"ls -la --color=never\"}",
  "updatedInput": "Modified prompt text",
  "additionalContext": "Extra context injected by hook"
}
```

> Return only `permissionDecision`/`permissionDecisionReason` or the fields
> above — other keys are ignored

---

## Hook Environment & Notifications

Plugin-packaged hooks receive stable paths:

- `PLUGIN_ROOT` / `COPILOT_PLUGIN_ROOT` / `CLAUDE_PLUGIN_ROOT`
- `PLUGIN_DATA` / `COPILOT_PLUGIN_DATA` / `CLAUDE_PLUGIN_DATA`
- `COPILOT_PROJECT_DIR` / `CLAUDE_PROJECT_DIR`

The `notification` family covers **background shell completion**, **permission
prompts**, **elicitation/questions**, and **subagent completion** — useful for
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

> `resultType` is `"success"` or `"error"`

---

## Your Turn! 🚀

Open **Module 9** in `docs/workshop/09-hooks.md`

> **First:** make sure your folder is trusted, or none of the repository hooks will run.

**Exercises 1-7:**
1. **Exercise 1** — Trust the folder + create hooks skeleton
2. **Exercise 2** — Session logging hooks
3. **Exercise 3** — Prompt auditing hook
4. **Exercise 4** — Pre-tool permission control
5. **Exercise 5** — Post-Tool Verification
6. **Exercise 6** — Error handling hooks
7. **Exercise 7** — Directory-Restricted Hooks

⏱️ You have **~16 minutes**
