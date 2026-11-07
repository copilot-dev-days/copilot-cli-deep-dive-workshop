# Module 9: Hooks

## Prerequisites

- Completed Modules 1-8
- Understanding of shell scripting (bash/PowerShell)
- JSON basics
- A **trusted** working folder — repository hooks only run in trusted folders

> [!IMPORTANT]
> Admit the folder's configuration using the trust prompt (session-only trust is sufficient). For one new prompt-mode session use `--trust-folder`. Review hooks before admission: they execute code. Exact `COPILOT_ALLOW_ALL=true` also trusts cwd configuration; other accepted truthy spellings only auto-approve tools.

## Learning Objectives

- Understand the hooks lifecycle
- Configure hooks for different events
- Use preToolUse hooks for permission control
- Create session logging and auditing
- Implement security guardrails with hooks

## Concepts

### What are Hooks?

Hooks are custom scripts that execute at specific points during Copilot agent execution:

```
Session admission/start → User prompts → Pre-Tool → Tool execution → Success/failure hooks → Session end
     ↓              ↓            ↓             ↓              ↓            ↓
   Hook           Hook         Hook                        Hook         Hook
```

### Hook Types

| Hook | Trigger | Use Cases |
|------|---------|-----------|
| `sessionStart` | Session starts or resumes | Logging, environment setup |
| `sessionEnd` | Session ends | Cleanup, metrics |
| `userPromptSubmitted` | User sends prompt | Audit, filtering |
| `userPromptTransformed` | After a prompt is transformed into its model-facing form, before it enters history | Prompt rewriting, auditing |
| `preToolUse` | Before tool execution | Permission control, validation |
| `preMcpToolCall` | **Unverified:** not listed by the public hooks reference | Investigation only; do not configure as a working event without runtime evidence |
| `postToolUse` | After successful tool execution | Logging, verification |
| `postToolUseFailure` | After tool execution fails | Error handling, retry logic |
| `errorOccurred` | Internal errors with model/tool/system/user-input context | Error handling, alerts; tool failures also have `postToolUseFailure` |
| `preCompact` | Before context compaction | Pre-compaction tasks, state saving |
| `agentStop` | The agent stops at the end of a turn | Turn-level automation, notifications |
| `subagentStart` | Sub-agent is spawned | Context injection, logging |
| `subagentStop` | Sub-agent completes | Collect sub-agent results |
| `permissionRequest` | Tool permission requested | Programmatic approve/deny of tool permissions |
| `notification` | Shell completion, permission prompts, elicitation, agent completion | External notification integration |

### Hook Locations

- **Repository hooks**: any `*.json` file in `<git root>/.github/hooks/` (for example `hooks.json`)
- **Personal hooks**: any `*.json` file in `~/.copilot/hooks/`
- **Inline hooks**: the `hooks` key in personal `~/.copilot/settings.json` or repository `.github/copilot/settings.json` / `settings.local.json`, not `config.json`. `COPILOT_HOME` relocates personal settings/hooks.

> [!NOTE]
> `~/.copilot/config.json` is managed automatically by the CLI and holds your authentication token, so do not hand-edit it to add inline hooks. Define your personal hooks as `*.json` files in `~/.copilot/hooks/`, and keep repository inline hooks in the repository's `settings.json` (edit it with `/settings --repo`).

> [!IMPORTANT]
> Repository hooks require **trusted configuration**; session-only admission is enough. Prefer the trust prompt or `--trust-folder` over editing managed state. Personal hooks and administrator policy hooks have distinct admission rules; policy hooks cannot be disabled locally.
>
> Complete this before Exercise 1, or every repository hook in this module will silently do nothing.

### Disabling All Hooks

> In repository `.github/copilot/settings.json`, use `disableAllHooks` to skip non-policy hooks from all sources for that repository:

```json
{
  "disableAllHooks": true
}
```

This is useful for debugging or CI environments where hooks may interfere with automation.

Inside one `.github/hooks/*.json` file, the same flag disables only that file's hooks, not hooks in other files.

To suppress specific hooks rather than all of them, list their content-hash keys under `disabledHooks`. Policy-delivered hooks cannot be suppressed and ignore both settings.

### Hook Permission Decisions

Hooks support three permission decisions in `preToolUse`:

| Decision | Behavior |
| --- | --- |
| `allow` | Allow the tool to execute |
| `deny` | Block the tool with a reason |
| `ask` | Prompt the user for confirmation before executing |

> The `ask` decision lets hooks request user confirmation instead of silently allowing or denying. Without an interactive approver, including prompt mode and autopilot, it is denied.

### Cross-Platform Hook Compatibility

> The CLI accepts cross-tool event aliases and structures, but payloads/output semantics are event-specific; compatibility does not guarantee identical execution:
> - PascalCase event names are accepted alongside camelCase (e.g., `PreToolUse` and `preToolUse` both work)
> - Claude Code's nested `matcher/hooks` structure is supported
> - The optional `type` field is accepted but not required
> - Hooks config files that omit the `version` field are accepted

### Hook Behavior

#### `preToolUse` argument mutation and event-specific outputs

> The reference defines object-shaped `modifiedArgs` for pre-tool mutation:
>
> ```json
> {
>   "modifiedArgs": {"command": "ls -la --color=never"}
> }
> ```
>
> Use `permissionDecision`/`permissionDecisionReason` for decisions. Pre-tool `updatedInput` and `additionalContext` are not documented decision fields; retained here only as unsupported examples, not instructions. `additionalContext` belongs to supported events such as `sessionStart`/`postToolUse`. An object-shaped `modifiedArgs` from a repository command hook replaces the executed arguments. Check the actual tool output and a harmless disposable side effect: the displayed tool call can still show the original arguments. Preserve other required argument fields in the replacement object.
>
> Original inactive fields, **do not use for pre-tool control**:
> ```text
> "updatedInput": "Modified prompt text",
> "additionalContext": "Extra context injected by hook"
> ```

#### `sessionStart`/`sessionEnd` are lifecycle hooks, not per-prompt hooks

> In interactive mode, two prompts in the same session share one `sessionStart`; each turn has its own `agentStop`. A trusted resumed session produces another start with `source: resume`. `/clear` ends the old session with `reason: user_exit` while the process remains running; the next prompt starts a new session. `/exit` also produces `user_exit`. Prompt-mode completion produces `reason: complete`; bounded autopilot continuations can produce repeated completion endings. Do not infer turn count from session endings.
>
> `--trust-folder` cannot be combined with `--resume`. If trust was session-only, admit the folder again through the interactive resume trust prompt; a successful untrusted prompt-mode resume does not prove repository hooks ran.

### Hook Payload Shapes

> Most event payload fields follow the event key's casing. Inspect the event-specific schema rather than assuming every field follows one convention:
>
> | Event key casing | Payload fields |
> | --- | --- |
> | camelCase (`sessionStart`, `preToolUse`) | Event-specific `sessionId`, millisecond `timestamp`, `cwd`; tool events carry `toolName` and `toolArgs` of unknown type |
> | PascalCase (`SessionStart`, `PreToolUse`) | Event-specific `hook_event_name`, `session_id`, ISO timestamp; tool events carry `tool_name` and `tool_input` |
>
> Native `notification` is an exception: it includes camelCase session fields together with `hook_event_name` and `notification_type`. `permissionRequest` uses `toolInput`, not `toolArgs`. Native tool arguments can be objects, JSON-encoded strings, or raw strings such as an `apply_patch` patch; only JSON-encoded strings can be decoded with `fromjson`.
>
> Use camelCase keys for hooks written for Copilot CLI; use PascalCase keys when reusing a hooks file authored for VS Code or Claude Code.

### Advanced Hook Formats and Failure Behavior

| Capability | Bounded guidance |
|---|---|
| `exec` / `args` command hooks | Direct executable invocation, no shell expansion; do not combine with `bash`/`command` |
| HTTP hooks | Send payloads to approved HTTPS endpoints; payloads may contain private content, so do not send workshop data to third parties |
| Prompt hooks | Event-specific model evaluation; consult the reference rather than assuming command-output schemas |
| `matcher` | Native regex matches the entire tool/event value; PascalCase pre-tool aliases use cross-tool matcher rules |
| Progress | Emit single-line `{"type":"progress","message":"Checking..."}` then exactly one final decision JSON |
| Local agent-scoped hooks | Additional hooks while that agent is selected; remote definitions do not execute them |
| `agentStop` / `subagentStop` | `decision: block` plus `reason` requests continuation; self-limit using `stop_hook_active`, with a bounded runtime guard |

Command `preToolUse` errors/nonzero exits deny (fail-closed), **but timeouts are fail-open**, including policy-hook timeouts. HTTP pre-tool network errors/timeouts/non-2xx responses are fail-open and fall through to normal permissions. Other event failures are generally logged/skipped. `ask` cannot show a confirmation in autopilot and is denied. Hooks are not a complete security boundary.

### Hook Script Environment

> Plugin-packaged hooks use plugin-specific paths; do not assume ordinary repository hooks have a plugin installation/data directory. The plugin environment includes these path names:
> - `PLUGIN_ROOT`, `COPILOT_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT` — the plugin's installation directory
> - `COPILOT_PLUGIN_DATA`, `CLAUDE_PLUGIN_DATA`, `PLUGIN_DATA` — the plugin's writable data directory
> - `COPILOT_PROJECT_DIR`, `CLAUDE_PROJECT_DIR` — the project root
>
> This lets hook scripts packaged with plugins reference sibling files reliably. Individual discovered hooks can be suppressed with the `disabledHooks` setting; `disableAllHooks` turns off both repository and personal hooks.

### Notification Hook Event

> The `notification` hook event fires on:
> - **Shell completion** — when a background shell command finishes
> - **Permission prompts** — when the agent requests tool permission
> - **Elicitation** — when the agent asks the user a question
> - **Agent completion** — when a background sub-agent finishes its task
>
> Use this hook to integrate with desktop notifications, Slack, or other alerting systems:
>
> ```json
> {
>   "hooks": {
>     "notification": [
>       {
>         "type": "command",
>       "bash": "INPUT=$(cat); TYPE=$(echo \"$INPUT\" | jq -r '.notification_type'); notify-send \"Copilot: $TYPE\"",
>         "cwd": ".",
>         "timeoutSec": 5
>       }
>     ]
>   }
> }
> ```

## Hands-On Exercises

Use a disposable repository. Each exercise writes its own hook file so unrelated configuration survives. Repeated lifecycle entries in retained examples can produce duplicate log lines when all files are enabled; for isolated output, move earlier exercise files to a non-`.json` suffix and restore them afterward. Never overwrite existing hook files. Logs contain prompt/error content: use only synthetic data, restrict access, and do not share them raw.

### Exercise 1: Create a Basic Hooks Configuration

**Goal:** Set up hooks infrastructure.

**Steps:**

1. Trust the folder you are working in. Start the CLI from the repository root and answer **Yes, and remember** at the trust prompt:
   ```bash
   copilot
   ```
   ```
   /exit
   ```

   > [!IMPORTANT]
   > Repository hooks in `.github/hooks/` are skipped in untrusted folders, with no error message. Do this first so the rest of the module works.

2. Create the hooks directory:
   ```bash
   mkdir -p .github/hooks
   ```

3. Create the hooks configuration file:
   ```bash
   test ! -e .github/hooks/workshop-01.json &&
   cat > .github/hooks/workshop-01.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [],
       "sessionEnd": [],
       "userPromptSubmitted": [],
       "preToolUse": [],
       "postToolUse": [],
       "errorOccurred": []
     }
   }
   EOF
   ```

   > **Note:** The file name is up to you — every `*.json` file in `.github/hooks/` is loaded. `hooks.json` is just a convention.

4. This is the skeleton - we'll add hooks in subsequent exercises.

**Expected Outcome:**
Hooks configuration file ready for customization, in a trusted folder so hooks will actually run.

### Exercise 2: Session Logging Hooks

**Goal:** Log session start and end for auditing.

**Steps:**

1. Create a logs directory:

   ```bash
   umask 077
   mkdir -p logs
   chmod 700 logs
   echo "logs/" >> .gitignore
   ```

2. Create a separate session hooks file:

   ```bash
   test ! -e .github/hooks/workshop-02.json &&
   cat > .github/hooks/workshop-02.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [
         {
           "type": "command",
           "bash": "umask 077; INPUT=$(cat); ID=$(printf '%s' \"$INPUT\" | jq -r '.sessionId | gsub(\"[^A-Za-z0-9_-]\"; \"_\")'); mkdir -p logs/session-times; printf '%s' \"$INPUT\" | jq -r '.timestamp' > \"logs/session-times/$ID\"; echo \"[$(date -Iseconds)] SESSION_START\" >> logs/copilot-audit.log",
           "powershell": "$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; $id = $data.sessionId -replace '[^A-Za-z0-9_-]', '_'; New-Item -ItemType Directory -Force logs/session-times | Out-Null; $data.timestamp | Out-File \"logs/session-times/$id\"; Add-Content logs/copilot-audit.log \"SESSION_START\"",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [
         {
           "type": "command",
           "bash": "umask 077; INPUT=$(cat); ID=$(printf '%s' \"$INPUT\" | jq -r '.sessionId | gsub(\"[^A-Za-z0-9_-]\"; \"_\")'); END=$(printf '%s' \"$INPUT\" | jq -r '.timestamp'); START=$(cat \"logs/session-times/$ID\" 2>/dev/null || echo \"$END\"); echo \"[$(date -Iseconds)] SESSION_END duration=$((END - START))ms\" >> logs/copilot-audit.log",
           "powershell": "$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; $id = $data.sessionId -replace '[^A-Za-z0-9_-]', '_'; $start = Get-Content \"logs/session-times/$id\" -ErrorAction SilentlyContinue; Add-Content logs/copilot-audit.log \"SESSION_END duration=$($data.timestamp - $start)ms\"",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "userPromptSubmitted": [],
       "preToolUse": [],
       "postToolUse": [],
       "errorOccurred": []
     }
   }
   EOF
   ```

3. Test the hooks:
   ```bash
   copilot
   ```
   ```
   Hello, Copilot!
   ```
   ```
   /exit
   ```

4. Check the log:
   ```bash
   cat logs/copilot-audit.log
   ```

**Expected Outcome:**
Sessions are logged with timestamps and duration:
```
[2026-02-24T10:30:00+00:00] SESSION_START
[2026-02-24T10:30:15+00:00] SESSION_END duration=15000ms
```

> **How it works:**
> - Hooks receive JSON data via stdin (standard input)
> - Use `jq` to parse JSON fields (e.g., `cat | jq -r '.timestamp'`)
> - The `sessionStart` hook saves a session-ID-keyed timestamp under restricted `logs/session-times/` (on Windows, use a private checkout with suitable ACLs)
> - The `sessionEnd` hook reads back the start time and calculates duration in milliseconds

### Exercise 3: Prompt Auditing Hook

**Goal:** Log all user prompts for compliance.

**Steps:**

1. Add prompt logging in a separate file. Use synthetic prompts only; truncation is not secret redaction:
   ```bash
   test ! -e .github/hooks/workshop-03.json &&
   cat > .github/hooks/workshop-03.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [
         {
           "type": "command",
           "bash": "echo \"[$(date -Iseconds)] SESSION_START\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [
         {
           "type": "command",
           "bash": "echo \"[$(date -Iseconds)] SESSION_END\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "userPromptSubmitted": [
         {
           "type": "command",
           "bash": "INPUT=$(cat); PROMPT=$(echo \"$INPUT\" | jq -r '.prompt // \"\"'); echo \"[$(date -Iseconds)] PROMPT: $(echo \"$PROMPT\" | head -c 100)...\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "preToolUse": [],
       "postToolUse": [],
       "errorOccurred": []
     }
   }
   EOF
   ```

2. Test with several prompts:
   ```bash
   copilot
   ```
   ```
   List all files in the current directory
   ```
   ```
   Show me the contents of .github/hooks/workshop-03.json
   ```
   ```
   /exit
   ```

3. Review the audit log:
   ```bash
   cat logs/copilot-audit.log
   ```

**Expected Outcome:**
All prompts logged with timestamps:
```
[2026-02-24T10:30:00+00:00] SESSION_START
[2026-02-24T10:30:01+00:00] PROMPT: List all files in the current directory...
[2026-02-24T10:30:10+00:00] PROMPT: Show me the contents of .github/hooks/workshop-03.json...
[2026-02-24T10:30:15+00:00] SESSION_END
```

> **Note:** Output above is illustrative, not a lifecycle ordering assertion. Session hooks are not expected for every prompt; capture sanitized fresh/resumed payloads to verify exact ordering on your runtime.

### Exercise 4: Pre-Tool Permission Control

**Goal:** Implement security guardrails with preToolUse hooks.

**Steps:**

1. Create a permission control script:
   ```bash
   mkdir -p .github/hooks/scripts

   cat > .github/hooks/scripts/check-tool.sh << 'EOF'
   #!/bin/bash

   # Read input from stdin
   INPUT=$(cat)

   # Accept both string and object arguments defensively
   TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // .tool_name')
   TOOL_ARGS=$(echo "$INPUT" | jq '.toolArgs // .tool_input | if type == "string" then fromjson else . end')

   # Log the tool request
   echo "[$(date -Iseconds)] TOOL_REQUEST: $TOOL_NAME" >> logs/copilot-audit.log

   # Define blocked patterns
   BLOCKED_COMMANDS=("rm -rf" "sudo" "chmod 777" "> /dev/sda" "mkfs")

   # Check if this is a shell command
   if [ "$TOOL_NAME" = "shell" ] || [ "$TOOL_NAME" = "bash" ] || [ "$TOOL_NAME" = "Bash" ]; then
     COMMAND=$(echo "$TOOL_ARGS" | jq -r '.command // empty')

     # Check against blocked patterns
     for BLOCKED in "${BLOCKED_COMMANDS[@]}"; do
       if [[ "$COMMAND" == *"$BLOCKED"* ]]; then
         echo "{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Command '$BLOCKED' is not allowed by policy\"}"
         exit 0
       fi
     done
   fi

   # Check for write operations to sensitive paths
   if [ "$TOOL_NAME" = "write" ] || [ "$TOOL_NAME" = "edit" ] || [ "$TOOL_NAME" = "create" ]; then
     FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.path // .filePath // empty')

     # Block writes to sensitive locations
     SENSITIVE_PATHS=("/etc" "/usr" "/bin" "/sbin" ".env" ".git/config" "package-lock.json")

     for SENSITIVE in "${SENSITIVE_PATHS[@]}"; do
       if [[ "$FILE_PATH" == *"$SENSITIVE"* ]]; then
         echo "{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Writing to '$SENSITIVE' is not allowed by policy\"}"
         exit 0
       fi
     done
   fi

   # Allow all other operations (return nothing for default behavior)
   echo "{}"
   EOF

   chmod +x .github/hooks/scripts/check-tool.sh
   ```

2. Add a dedicated configuration file for the script:
   ```bash
   test ! -e .github/hooks/workshop-04.json &&
   cat > .github/hooks/workshop-04.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [
         {
           "type": "command",
           "bash": "echo \"[$(date -Iseconds)] SESSION_START\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [
         {
           "type": "command",
           "bash": "echo \"[$(date -Iseconds)] SESSION_END\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "userPromptSubmitted": [],
       "preToolUse": [
         {
           "type": "command",
           "bash": ".github/hooks/scripts/check-tool.sh",
           "cwd": ".",
           "timeoutSec": 10
         }
       ],
       "postToolUse": [],
       "errorOccurred": []
     }
   }
   EOF
   ```

3. Test the guardrails:
   ```bash
   copilot
   ```
   ```
   Please execute the exact command: sudo whoami
   ```

4. The hook should deny this operation because `sudo` is in the blocked commands list.

5. Check the log to see the denied request:
   ```bash
   cat logs/copilot-audit.log
   ```

**Expected Outcome:**
The hook blocks the command:
```
[2026-02-26T08:10:00+00:00] SESSION_START
[2026-02-26T08:10:01+00:00] TOOL_REQUEST: report_intent
[2026-02-26T08:10:01+00:00] TOOL_REQUEST: bash
[2026-02-26T08:10:02+00:00] SESSION_END
```

Copilot shows: "Denied by preToolUse hook: Command 'sudo' is not allowed by policy"

> **Note:** This substring guard is illustrative and bypassable (aliases, alternate programs, shell syntax, and unhandled tool names). Its argument parser expects objects or JSON-encoded strings, not raw patch text. Do not test destructive commands or treat this as enforcement of a filesystem boundary.

### Exercise 5: Post-Tool Verification

**Goal:** Log and verify tool execution results.

**Steps:**

1. Create a post-tool logging script:
   ```bash
   cat > .github/hooks/scripts/log-tool-result.sh << 'EOF'
   #!/bin/bash

   INPUT=$(cat)

   TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
   RESULT_TYPE=$(echo "$INPUT" | jq -r 'if has("error") then "failure" else .toolResult.resultType end')

   echo "[$(date -Iseconds)] TOOL_COMPLETE: $TOOL_NAME result=$RESULT_TYPE" >> logs/copilot-audit.log

   # Alert on failures
   if [ "$RESULT_TYPE" = "failure" ]; then
     echo "[$(date -Iseconds)] ALERT: Tool $TOOL_NAME failed!" >> logs/copilot-alerts.log
   fi
   EOF

   chmod +x .github/hooks/scripts/log-tool-result.sh
   ```

2. Register the script for **success and failure** events in a separate file:
   ```bash
   test ! -e .github/hooks/workshop-05.json &&
   cat > .github/hooks/workshop-05.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [
         {
           "type": "command",
           "bash": "echo \"[$(date -Iseconds)] SESSION_START\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [],
       "userPromptSubmitted": [],
       "preToolUse": [
         {
           "type": "command",
           "bash": ".github/hooks/scripts/check-tool.sh",
           "cwd": ".",
           "timeoutSec": 10
         }
       ],
       "postToolUse": [
         {
           "type": "command",
           "bash": ".github/hooks/scripts/log-tool-result.sh",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "postToolUseFailure": [
         {
           "type": "command",
           "bash": ".github/hooks/scripts/log-tool-result.sh",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "errorOccurred": []
     }
   }
   EOF
   ```

3. Test with various operations and check logs:
   ```bash
   copilot
   ```
   ```
   list files in current directory
   ```
   ```
   /exit
   ```
   ```bash
   cat logs/copilot-audit.log
   ```

**Expected Outcome:**
All tool executions are logged with results:
```
[2026-02-26T08:10:00+00:00] SESSION_START
[2026-02-26T08:10:01+00:00] TOOL_REQUEST: report_intent
[2026-02-26T08:10:01+00:00] TOOL_REQUEST: bash
[2026-02-26T08:10:01+00:00] TOOL_COMPLETE: report_intent result=success
[2026-02-26T08:10:01+00:00] TOOL_COMPLETE: bash result=success
```

For a safe failure check, ask the agent to read an explicitly nonexistent file in the disposable repository exactly once, without retrying. Expect `TOOL_COMPLETE: view result=failure` and `ALERT: Tool view failed!` in `logs/copilot-alerts.log`. This exercises `postToolUseFailure`, not `errorOccurred`.

### Exercise 6: Error Handling Hooks

**Goal:** Capture and respond to internal Copilot errors.

> **Note:** Internal errors include `errorContext` and `recoverable`; tool failures have their own `postToolUseFailure` event. `postToolUse` handles successful calls only.
>
> Inspecting configuration or replaying synthetic nested error JSON tests only the script/parser. Neither proves an actual `errorOccurred` event fired. Do not induce authentication, account, or remote-service failures just to trigger this exercise.

**Steps:**

1. Create an error handling script:
   ```bash
   cat > .github/hooks/scripts/handle-error.sh << 'EOF'
   #!/bin/bash

   INPUT=$(cat)

   ERROR_TYPE=$(echo "$INPUT" | jq -r '.error.name // "unknown"')
   ERROR_MESSAGE=$(echo "$INPUT" | jq -r '.error.message // "No message"')
   ERROR_CONTEXT=$(echo "$INPUT" | jq -r '.errorContext // .error_context // "unknown"')
   RECOVERABLE=$(echo "$INPUT" | jq -r '.recoverable')
   TIMESTAMP=$(date -Iseconds)

   # Log the error
   echo "[$TIMESTAMP] ERROR: $ERROR_TYPE context=$ERROR_CONTEXT recoverable=$RECOVERABLE - $ERROR_MESSAGE" >> logs/copilot-errors.log
   EOF

   chmod +x .github/hooks/scripts/handle-error.sh
   ```

2. Create a separate error hook file:
   ```bash
   test ! -e .github/hooks/workshop-06.json &&
   cat > .github/hooks/workshop-06.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [
         {
           "type": "command",
           "bash": "echo \"[$(date -Iseconds)] SESSION_START\" >> logs/copilot-audit.log",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [],
       "userPromptSubmitted": [],
       "preToolUse": [],
       "postToolUse": [],
       "errorOccurred": [
         {
           "type": "command",
           "bash": ".github/hooks/scripts/handle-error.sh",
           "cwd": ".",
           "timeoutSec": 10
         }
       ]
     }
   }
   EOF
   ```

3. Verify the hook is configured:
   ```bash
   jq '.hooks.errorOccurred' .github/hooks/workshop-06.json
   ```

**Expected Outcome:**
```json
[
  {
    "type": "command",
    "bash": ".github/hooks/scripts/handle-error.sh",
    "cwd": ".",
    "timeoutSec": 10
  }
]
```

### Exercise 7: Directory-Restricted Hooks

**Goal:** Illustrate normalized-path checks for direct edit tools, not a security boundary.

**Steps:**

1. Create a path restriction script:
   ```bash
   cat > .github/hooks/scripts/restrict-paths.sh << 'EOF'
   #!/bin/bash

   INPUT=$(cat)
   TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // .tool_name')

   # Only check write operations (tool name is 'create' for file creation)
   if [ "$TOOL_NAME" != "write" ] && [ "$TOOL_NAME" != "edit" ] && [ "$TOOL_NAME" != "create" ]; then
     echo "{}"
     exit 0
   fi

   # Native camelCase exercise; string/object payloads both accepted
   FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs // .tool_input | if type == "string" then fromjson else . end | .path // .filePath // empty')
   CWD=$(echo "$INPUT" | jq -r '.cwd')
   ROOT=$(realpath -m -- "$CWD")
   case "$FILE_PATH" in
     /*) TARGET=$(realpath -m -- "$FILE_PATH") ;;
     *) TARGET=$(realpath -m -- "$ROOT/$FILE_PATH") ;;
   esac

   # Allowed directories
   ALLOWED_DIRS=("docs" "src" "test" "tests")

   ALLOWED=false
   for DIR in "${ALLOWED_DIRS[@]}"; do
     # Resolve existing symlinks and traversal; require containment in cwd
     if [[ "$TARGET" == "$ROOT/$DIR/"* ]]; then
       ALLOWED=true
       break
     fi
   done

   if [ "$ALLOWED" = false ]; then
     echo "{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Can only edit files in src/, test/, tests/, or docs/ directories\"}"
     exit 0
   fi

   echo "{}"
   EOF

   chmod +x .github/hooks/scripts/restrict-paths.sh
   ```

2. Use a separate path-check configuration:
   ```bash
   test ! -e .github/hooks/workshop-07.json &&
   cat > .github/hooks/workshop-07.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [],
       "sessionEnd": [],
       "userPromptSubmitted": [],
       "preToolUse": [
         {
           "type": "command",
           "bash": ".github/hooks/scripts/restrict-paths.sh",
           "cwd": ".",
           "timeoutSec": 10
         }
       ],
       "postToolUse": [],
       "errorOccurred": []
     }
   }
   EOF
   ```

3. Test creating a file in the root (should be denied):
   ```bash
   copilot
   ```
   ```
   Create a file called config.json in the root directory
   ```

4. Then test creating in docs/ (should be allowed):
   ```bash
   copilot
   ```
   ```
   Create a file called test.md in the docs directory
   ```

**Expected Outcome:**
- Root directory file creation is blocked: "Can only edit files in src/, test/, tests/, or docs/ directories"
- Files in `docs/` are allowed

These outcomes apply only to the recognized direct write tools and payload shape. `realpath` (GNU coreutils in this Linux exercise) normalizes traversal and existing symlinks, but races, symlink changes, other tools, and shell writes bypass this illustration. For enforcement use a suitable OS sandbox/filesystem policy.

Tool availability depends on the selected model. Capture `preToolUse` to verify that this exercise actually uses `create`, `edit`, or `write`. An `apply_patch` call carries raw patch text and is not checked by this script; a model reporting that `create` is unavailable is not a successful guardrail test.

## Hooks Configuration Reference

### Hook Input Variables

#### sessionStart
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925152,
  "cwd": "/path/to/workspace",
  "source": "new",
  "initialPrompt": "User's first prompt if provided"
}
```

> **Note:** Reference values are `startup`, `resume`, and `new`; inspect sanitized lifecycle payloads rather than assuming one value.

#### userPromptSubmitted
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925200,
  "cwd": "/path/to/workspace",
  "prompt": "User's prompt text"
}
```

#### preToolUse
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925300,
  "cwd": "/path/to/workspace",
  "toolName": "bash",
  "toolArgs": "{\"command\": \"ls -la\"}"
}
```

> **Note:** `toolArgs` is typed as unknown. The example is a JSON-encoded string; `if type == "string" then fromjson else . end` accepts that shape and objects, but not raw non-JSON tool strings. Validate the tool name and argument format before parsing.

> **Note:** Common tool names: `bash` (shell commands), `create` (file creation), `view` (directory listing), `report_intent` (internal).

#### sessionEnd
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976928952,
  "cwd": "/path/to/workspace",
  "reason": "complete"
}
```

#### postToolUse
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925400,
  "cwd": "/path/to/workspace",
  "toolName": "bash",
  "toolArgs": "{\"command\": \"ls -la\"}",
  "toolResult": {
    "resultType": "success",
    "textResultForLlm": "file1.txt\nfile2.txt"
  }
}
```

> **Note:** `postToolUse` has `resultType: success`; failures use `postToolUseFailure` with an `error` string. Tool arguments may be strings or objects.

#### postToolUseFailure
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925400,
  "cwd": "/path/to/workspace",
  "toolName": "view",
  "toolArgs": {"path": "/path/to/workspace/nonexistent-example.txt"},
  "error": "Path does not exist"
}
```

#### errorOccurred
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925400,
  "cwd": "/path/to/workspace",
  "error": {"name": "ExampleError", "message": "Synthetic example"},
  "errorContext": "system",
  "recoverable": true
}
```

This nested error schema is distinct from the string error in `postToolUseFailure`; the example alone is not evidence of event execution.

#### userPromptTransformed
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976925250,
  "cwd": "/path/to/workspace",
  "prompt": "User's prompt text",
  "transformedPrompt": "The model-facing form of the prompt"
}
```

#### agentStop
```json
{
  "sessionId": "uuid-string",
  "timestamp": 1771976928900,
  "cwd": "/path/to/workspace",
  "transcriptPath": "/home/you/.copilot/session-state/uuid-string/events.jsonl",
  "stopReason": "end_turn",
  "stop_hook_active": false
}
```

### Permission Decision Response

```json
{
  "permissionDecision": "allow|deny|ask",
  "permissionDecisionReason": "Explanation shown to user"
}
```

### Hook Command Schema

```json
{
  "type": "command",
  "bash": "script for bash",
  "powershell": "script for PowerShell",
  "cwd": ".",
  "timeoutSec": 10
}
```

## Summary

- ✅ Hooks execute at key points in agent lifecycle
- ✅ Repository hooks only run in **trusted folders** — untrusted folders skip them silently
- ✅ Repository hooks live in any `*.json` file under `<git root>/.github/hooks/`; personal hooks under `~/.copilot/hooks/`
- ✅ `preToolUse` enables security guardrails
- ✅ `postToolUse` allows verification and logging (fires only on successful tool calls)
- ✅ `postToolUseFailure` handles tool errors separately
- ✅ `permissionRequest` hook enables programmatic approve/deny of tool permissions
- ✅ Session hooks enable auditing
- ✅ `errorOccurred` fires when a model call fails
- ✅ Hooks must return JSON for permission decisions
- ✅ `preCompact` hook fires before context compaction
- ✅ `userPromptTransformed` fires after a prompt is turned into its model-facing form
- ⚠️ `preMcpToolCall` is unverified, not an active configuration recommendation
- ✅ `agentStop` fires when the agent stops at the end of a turn
- ✅ `subagentStart` and `subagentStop` fire when a sub-agent is spawned and when it completes
- ✅ Repository settings `disableAllHooks` skips non-policy hooks across sources; a hook-file flag affects only that file. `disabledHooks` suppresses individual hooks (policy hooks ignore both)
- ✅ Hook `ask` permission decision prompts user for confirmation
- ✅ Cross-platform hook configs work across VS Code, Claude Code, and CLI
- ✅ Hooks can also be declared inline under the `hooks` key in settings
- ✅ Pre-tool `modifiedArgs` replaces arguments with an object; verify actual execution, not just the displayed call
- ✅ Session hooks describe lifecycle boundaries, including resume/clear; validate exact ordering
- ✅ Most payload fields follow event casing; native notifications mix camelCase session fields with `hook_event_name`/`notification_type`
- ✅ Plugin-packaged hooks use plugin installation/data paths; do not assume ordinary repository hooks have plugin directories
- ✅ `notification` covers background shell completion, permission prompts, elicitation, and background agent completion

## Next Steps

→ Continue to [Module 10: Context Management](10-context.md)

## References

- [Hooks Reference - GitHub Docs](https://docs.github.com/en/copilot/reference/hooks-reference)
- [About Hooks - GitHub Docs](https://docs.github.com/en/copilot/concepts/customizations/hooks)
- [Using Hooks with Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks)
- [Use Hooks - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/use-hooks)
