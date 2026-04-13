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

# Module 10: Hooks

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
| `sessionStart` | Session begins | Logging, setup |
| `sessionEnd` | Session ends | Cleanup, metrics |
| `userPromptSubmitted` | User sends prompt | Audit trail |
| `preToolUse` | Before tool runs | **Permission control** |
| `postToolUse` | After successful tool run | Verification, logging |
| `postToolUseFailure` | After tool failure | Error handling |
| `errorOccurred` | Error happens | Alerts, monitoring |
| `preCompact` | Before compaction | State saving (v1.0.5) |
| `subagentStart` | Sub-agent spawned | Context injection (v1.0.7) |
| `permissionRequest` | Permission requested | Programmatic approve/deny (v1.0.16) |

---

## Configuration

Lives at `.github/hooks/hooks.json`

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": ".github/hooks/scripts/check-tool.sh",
        "cwd": ".",
        "timeoutSec": 10
      }
    ]
  }
}
```

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

---

## Pre-Tool Permission Control

Block dangerous operations with `preToolUse`

```bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
COMMAND=$(echo "$INPUT" | jq -r '.toolArgs | fromjson.command')

if [[ "$COMMAND" == *"sudo"* ]]; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"sudo not allowed"}'
  exit 0
fi
echo '{}'
```

> **Note:** Copilot has built-in safety that blocks some commands (like `rm -rf /`) before hooks run. Use hooks for organization-specific policies.

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

## New Hook Features (v1.0.4–v1.0.16)

- **`disableAllHooks`** config flag — turn off all hooks (v1.0.4)
- **`ask`** permission decision — prompt user for confirmation (v1.0.4):
  ```json
  {"permissionDecision": "ask", "permissionDecisionReason": "Confirm?"}
  ```
- **Cross-platform compat** — PascalCase event names, Claude Code nested structure (v1.0.6)
- Hook config files that **omit `version`** field now accepted (v1.0.5)
- **`postToolUseFailure`** hook for tool errors; `postToolUse` fires only on success (v1.0.15)
- **`permissionRequest`** hook for programmatic tool approval (v1.0.16)
- Hooks can also be defined in **`settings.json`** and **`config.json`** (v1.0.8)

---

## Your Turn! 🚀

Open **Module 9** in `docs/workshop/09-hooks.md`

**Exercises 1-7:**
1. **Exercise 1** — Create hooks skeleton
2. **Exercise 2** — Session logging hooks
3. **Exercise 3** — Tool usage logging
4. **Exercise 4** — Pre-tool permission control
5. **Exercise 5** — Post-tool result logging
6. **Exercise 6** — Error handling hooks
7. **Exercise 7** — Directory restriction guardrails

⏱️ You have **~16 minutes**
