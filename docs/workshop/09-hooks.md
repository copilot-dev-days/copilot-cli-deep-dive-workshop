# Module 9: Hooks

## Prerequisites

- Completed Modules 1-8
- Understanding of shell scripting (bash/PowerShell)
- JSON basics
- A **trusted** working folder — repository hooks only run in trusted folders

> [!IMPORTANT]
> Answer **Yes, and remember** at the trust prompt the first time you launch Copilot in the folder you use for this module. Without folder trust, `.github/hooks/*.json` is discovered but never executed and no error is shown, so every exercise below would silently produce nothing.

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
User Prompt → Session Start → Pre-Tool → Tool Execution → Post-Tool → Session End
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
| `preMcpToolCall` | Before an MCP tool request is sent | Adjust MCP request metadata |
| `postToolUse` | After successful tool execution | Logging, verification |
| `postToolUseFailure` | After tool execution fails | Error handling, retry logic |
| `errorOccurred` | A model call fails | Error handling, alerts |
| `preCompact` | Before context compaction | Pre-compaction tasks, state saving |
| `agentStop` | The agent stops at the end of a turn | Turn-level automation, notifications |
| `subagentStart` | Sub-agent is spawned | Context injection, logging |
| `subagentStop` | Sub-agent completes | Collect sub-agent results |
| `permissionRequest` | Tool permission requested | Programmatic approve/deny of tool permissions |
| `notification` | Shell completion, permission prompts, elicitation, agent completion | External notification integration |

### Hook Locations

- **Repository hooks**: any `*.json` file in `<git root>/.github/hooks/` (for example `hooks.json`)
- **Personal hooks**: any `*.json` file in `~/.copilot/hooks/`
- **Inline hooks**: the `hooks` key, keyed by event name, using the same schema as `.github/hooks/*.json`. In the global `config.json` these act as user-level hooks; in repository `settings.json` they act as repo-level hooks.

> [!NOTE]
> `~/.copilot/config.json` is managed automatically by the CLI and holds your authentication token, so do not hand-edit it to add inline hooks. Define your personal hooks as `*.json` files in `~/.copilot/hooks/`, and keep repository inline hooks in the repository's `settings.json` (edit it with `/settings --repo`).

> [!IMPORTANT]
> Repository hooks run only in **trusted folders**. The first time you launch Copilot in a directory, answer **Yes, and remember** at the trust prompt (or add the path to `trustedFolders`). In an untrusted folder, `.github/hooks/*.json` is discovered but never executed, and no error is shown. Personal hooks in `~/.copilot/hooks/` run regardless of folder trust.
>
> Complete this before Exercise 1, or every repository hook in this module will silently do nothing.

### Disabling All Hooks

> Use the `disableAllHooks` setting to disable all hooks, both user-level and repo-level:

```json
{
  "disableAllHooks": true
}
```

This is useful for debugging or CI environments where hooks may interfere with automation.

To suppress specific hooks rather than all of them, list their content-hash keys under `disabledHooks`. Policy-delivered hooks cannot be suppressed and ignore both settings.

### Hook Permission Decisions

Hooks support three permission decisions in `preToolUse`:

| Decision | Behavior |
| --- | --- |
| `allow` | Allow the tool to execute |
| `deny` | Block the tool with a reason |
| `ask` | Prompt the user for confirmation before executing |

> The `ask` decision lets hooks request user confirmation instead of silently allowing or denying — useful for semi-automated workflows.

### Cross-Platform Hook Compatibility

> Hook configuration files work across **VS Code, Claude Code, and the CLI** without modification:
> - PascalCase event names are accepted alongside camelCase (e.g., `PreToolUse` and `preToolUse` both work)
> - Claude Code's nested `matcher/hooks` structure is supported
> - The optional `type` field is accepted but not required
> - Hooks config files that omit the `version` field are accepted

### Hook Behavior

#### `preToolUse` hooks respect `modifiedArgs`/`updatedInput`/`additionalContext`

> **Note:** `preToolUse` hooks can return `modifiedArgs`, `updatedInput`, and/or `additionalContext` fields in their JSON response. These fields are **respected by the CLI** and modify the tool invocation:
>
> ```json
> {
>   "modifiedArgs": "{\"command\": \"ls -la --color=never\"}",
>   "updatedInput": "Modified prompt text",
>   "additionalContext": "Extra context injected by hook"
> }
> ```
>
> Return only `permissionDecision`/`permissionDecisionReason` or the fields above — other keys are ignored.

#### `sessionStart`/`sessionEnd` hooks fire once per session

> **Note:** `sessionStart` and `sessionEnd` hooks fire **once per session**, not once per prompt. They fire exactly once at session start and session end. For per-prompt logic, use the `userPromptSubmitted` hook.

### Hook Payload Shapes

> The payload a hook receives is determined by how you write the event key in the hooks file. The two shapes are mutually exclusive:
>
> | Event key casing | Payload fields |
> | --- | --- |
> | camelCase (`sessionStart`, `preToolUse`) | `sessionId`, `timestamp` (Unix milliseconds), `cwd`, `toolName`, `toolArgs` (JSON **string**), `initialPrompt` |
> | PascalCase (`SessionStart`, `PreToolUse`) | `hook_event_name`, `session_id`, `timestamp` (ISO 8601 string), `cwd`, `tool_name` (capitalised, e.g. `Bash`), `tool_input` (JSON **object**), `initial_prompt` |
>
> Use camelCase keys for hooks written for Copilot CLI; use PascalCase keys when reusing a hooks file authored for VS Code or Claude Code.

### Hook Script Environment

> Hook and plugin scripts receive:
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
> - **Agent completion** — when a sub-agent finishes its task
>
> Use this hook to integrate with desktop notifications, Slack, or other alerting systems:
>
> ```json
> {
>   "hooks": {
>     "notification": [
>       {
>         "type": "command",
>         "bash": "INPUT=$(cat); TYPE=$(echo \"$INPUT\" | jq -r '.notificationType'); echo \"Copilot: $TYPE\" | notify-send -",
>         "cwd": ".",
>         "timeoutSec": 5
>       }
>     ]
>   }
> }
> ```

## Hands-On Exercises

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
   cat > .github/hooks/hooks.json << 'EOF'
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
   mkdir -p logs
   echo "logs/" >> .gitignore
   ```

2. Update hooks.json with session hooks:

   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
   {
     "hooks": {
       "sessionStart": [
         {
           "type": "command",
           "bash": "cat | jq -r '.timestamp' > /tmp/copilot-session-start; echo \"[$(date -Iseconds)] SESSION_START\" >> logs/copilot-audit.log",
           "powershell": "$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; $data.timestamp | Out-File /tmp/copilot-session-start; Add-Content -Path logs/copilot-audit.log -Value \"[$(Get-Date -Format o)] SESSION_START\"",
           "cwd": ".",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [
         {
           "type": "command",
           "bash": "END=$(cat | jq -r '.timestamp'); START=$(cat /tmp/copilot-session-start 2>/dev/null || echo $END); echo \"[$(date -Iseconds)] SESSION_END duration=$((END - START))ms\" >> logs/copilot-audit.log",
           "powershell": "$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; $start = Get-Content /tmp/copilot-session-start -ErrorAction SilentlyContinue; Add-Content -Path logs/copilot-audit.log -Value \"[$(Get-Date -Format o)] SESSION_END duration=$($data.timestamp - $start)ms\"",
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
> - The `sessionStart` hook saves the timestamp to a temp file
> - The `sessionEnd` hook reads back the start time and calculates duration in milliseconds

### Exercise 3: Prompt Auditing Hook

**Goal:** Log all user prompts for compliance.

**Steps:**

1. Add prompt logging to hooks.json:
   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
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
   Show me the contents of hooks.json
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
[2026-02-24T10:30:00+00:00] PROMPT: List all files in the current directory...
[2026-02-24T10:30:01+00:00] SESSION_START
[2026-02-24T10:30:05+00:00] SESSION_END
[2026-02-24T10:30:10+00:00] PROMPT: Show me the contents of hooks.json...
[2026-02-24T10:30:11+00:00] SESSION_START
[2026-02-24T10:30:15+00:00] SESSION_END
```

> **Note:** The `userPromptSubmitted` hook fires when you submit a prompt, which triggers the session to start. So the order is: PROMPT → SESSION_START → SESSION_END.

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

   # Parse tool information (toolArgs is a JSON string, so parse with fromjson)
   TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
   TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs | fromjson')

   # Log the tool request
   echo "[$(date -Iseconds)] TOOL_REQUEST: $TOOL_NAME" >> logs/copilot-audit.log

   # Define blocked patterns
   BLOCKED_COMMANDS=("rm -rf" "sudo" "chmod 777" "> /dev/sda" "mkfs")

   # Check if this is a shell command
   if [ "$TOOL_NAME" = "shell" ] || [ "$TOOL_NAME" = "bash" ]; then
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

2. Update hooks.json to use the script:
   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
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

> **Note:** Some dangerous commands like `rm -rf /` are blocked by Copilot's built-in safety before the hook runs.

### Exercise 5: Post-Tool Verification

**Goal:** Log and verify tool execution results.

**Steps:**

1. Create a post-tool logging script:
   ```bash
   cat > .github/hooks/scripts/log-tool-result.sh << 'EOF'
   #!/bin/bash

   INPUT=$(cat)

   TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
   RESULT_TYPE=$(echo "$INPUT" | jq -r '.toolResult.resultType')

   echo "[$(date -Iseconds)] TOOL_COMPLETE: $TOOL_NAME result=$RESULT_TYPE" >> logs/copilot-audit.log

   # Alert on failures
   if [ "$RESULT_TYPE" = "error" ]; then
     echo "[$(date -Iseconds)] ALERT: Tool $TOOL_NAME failed!" >> logs/copilot-alerts.log
   fi
   EOF

   chmod +x .github/hooks/scripts/log-tool-result.sh
   ```

2. Add to hooks.json:
   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
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

### Exercise 6: Error Handling Hooks

**Goal:** Capture and respond to internal Copilot errors.

> **Note:** The `errorOccurred` hook fires for internal Copilot errors (network failures, API errors, etc.), not for tool failures. Tool failures are handled by the `postToolUseFailure` hook. The `postToolUse` hook fires only after successful tool calls.

**Steps:**

1. Create an error handling script:
   ```bash
   cat > .github/hooks/scripts/handle-error.sh << 'EOF'
   #!/bin/bash

   INPUT=$(cat)

   ERROR_TYPE=$(echo "$INPUT" | jq -r '.errorType // "unknown"')
   ERROR_MESSAGE=$(echo "$INPUT" | jq -r '.errorMessage // .message // "No message"')
   TIMESTAMP=$(date -Iseconds)

   # Log the error
   echo "[$TIMESTAMP] ERROR: $ERROR_TYPE - $ERROR_MESSAGE" >> logs/copilot-errors.log
   EOF

   chmod +x .github/hooks/scripts/handle-error.sh
   ```

2. Update hooks.json to include the error hook:
   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
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
   cat .github/hooks/hooks.json | jq '.hooks.errorOccurred'
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

**Goal:** Allow edits only in specific directories.

**Steps:**

1. Create a path restriction script:
   ```bash
   cat > .github/hooks/scripts/restrict-paths.sh << 'EOF'
   #!/bin/bash

   INPUT=$(cat)
   TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')

   # Only check write operations (tool name is 'create' for file creation)
   if [ "$TOOL_NAME" != "write" ] && [ "$TOOL_NAME" != "edit" ] && [ "$TOOL_NAME" != "create" ]; then
     echo "{}"
     exit 0
   fi

   # toolArgs is a JSON string, so parse it with fromjson
   FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs | fromjson | .path // .filePath // empty')

   # Allowed directories
   ALLOWED_DIRS=("/docs/" "/src/" "/test/" "/tests/")

   ALLOWED=false
   for DIR in "${ALLOWED_DIRS[@]}"; do
     if [[ "$FILE_PATH" == *"$DIR"* ]]; then
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

2. Update hooks.json to use the path restriction:
   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
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

> **Note:** In CLI sessions, `source` is always "new" (even when using `--resume`).

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

> **Note:** `toolArgs` is a JSON **string**, not an object. Parse it with `jq -r '.toolArgs | fromjson'`.

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

> **Note:** `resultType` is `"success"` or `"error"`. `toolArgs` is a JSON string.

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
- ✅ `preMcpToolCall` fires before an MCP tool request is sent
- ✅ `agentStop` fires when the agent stops at the end of a turn
- ✅ `subagentStart` and `subagentStop` fire when a sub-agent is spawned and when it completes
- ✅ `disableAllHooks` disables every hook; `disabledHooks` suppresses individual ones (policy hooks ignore both)
- ✅ Hook `ask` permission decision prompts user for confirmation
- ✅ Cross-platform hook configs work across VS Code, Claude Code, and CLI
- ✅ Hooks can also be declared inline under the `hooks` key in settings
- ✅ `preToolUse` hooks respect `modifiedArgs`/`updatedInput`/`additionalContext`
- ✅ `sessionStart`/`sessionEnd` hooks fire once per session, not per prompt
- ✅ camelCase event keys yield camelCase payloads; PascalCase event keys yield `hook_event_name`/`session_id`/ISO 8601 payloads
- ✅ Hook and plugin scripts receive `PLUGIN_ROOT`, `COPILOT_PLUGIN_DATA`, and `COPILOT_PROJECT_DIR` env vars
- ✅ `notification` hook event fires on shell completion, permission prompts, elicitation, agent completion

## Next Steps

→ Continue to [Module 10: Context Management](10-context.md)

## References

- [Hooks Reference - GitHub Docs](https://docs.github.com/en/copilot/reference/hooks-reference)
- [About Hooks - GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/hooks)
- [Using Hooks with Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks)
- [Use Hooks - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/use-hooks)
