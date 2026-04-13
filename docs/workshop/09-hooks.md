# Module 9: Hooks

## Prerequisites

- Completed Modules 1-9
- Understanding of shell scripting (bash/PowerShell)
- JSON basics

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
| `sessionStart` | Session begins | Logging, environment setup |
| `sessionEnd` | Session ends | Cleanup, metrics |
| `userPromptSubmitted` | User sends prompt | Audit, filtering |
| `preToolUse` | Before tool execution | Permission control, validation |
| `postToolUse` | After successful tool execution | Logging, verification |
| `postToolUseFailure` | After tool execution fails | Error handling, retry logic |
| `errorOccurred` | Error happens | Error handling, alerts |
| `preCompact` | Before context compaction | Pre-compaction tasks, state saving |
| `subagentStart` | Sub-agent is spawned | Context injection, logging |
| `permissionRequest` | Tool permission requested | Programmatic approve/deny of tool permissions |

### Hook Locations

- **Copilot Coding Agent**: `.github/hooks/hooks.json` (on default branch)
- **Copilot CLI**: Hooks loaded from current working directory

### Disabling All Hooks

> Since v1.0.4, use the `disableAllHooks` flag in configuration to disable all hooks:

```json
{
  "disableAllHooks": true
}
```

This is useful for debugging or CI environments where hooks may interfere with automation.

### Hook Permission Decisions

Hooks support three permission decisions in `preToolUse`:

| Decision | Behavior |
| --- | --- |
| `allow` | Allow the tool to execute |
| `deny` | Block the tool with a reason |
| `ask` | Prompt the user for confirmation before executing |

> The `ask` decision (v1.0.4+) lets hooks request user confirmation instead of silently allowing or denying — useful for semi-automated workflows.

### Cross-Platform Hook Compatibility

> Since v1.0.6, hook configuration files work across **VS Code, Claude Code, and the CLI** without modification:
> - PascalCase event names are accepted alongside camelCase (e.g., `PreToolUse` and `preToolUse` both work)
> - Claude Code's nested `matcher/hooks` structure is supported
> - The optional `type` field is accepted but not required
> - Hooks config files that omit the `version` field are accepted (v1.0.5+)

## Hands-On Exercises

### Exercise 1: Create a Basic Hooks Configuration

**Goal:** Set up hooks infrastructure.

**Steps:**

1. Create the hooks directory:
   ```bash
   mkdir -p .github/hooks
   ```

2. Create the hooks configuration file:
   ```bash
   cat > .github/hooks/hooks.json << 'EOF'
   {
     "version": 1,
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

3. This is the skeleton - we'll add hooks in subsequent exercises.

**Expected Outcome:**
Hooks configuration file ready for customization.

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
     "version": 1,
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
     "version": 1,
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
     "version": 1,
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
     "version": 1,
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
     "version": 1,
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
     "version": 1,
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

### Permission Decision Response

```json
{
  "permissionDecision": "allow|deny",
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
- ✅ `preToolUse` enables security guardrails
- ✅ `postToolUse` allows verification and logging (fires only on successful tool calls)
- ✅ `postToolUseFailure` handles tool errors separately
- ✅ `permissionRequest` hook enables programmatic approve/deny of tool permissions
- ✅ Session hooks enable auditing
- ✅ Error hooks support monitoring integration
- ✅ Hooks must return JSON for permission decisions
- ✅ `preCompact` hook fires before context compaction (v1.0.5+)
- ✅ `subagentStart` hook fires when a sub-agent is spawned (v1.0.7+)
- ✅ `disableAllHooks` flag disables all hooks (v1.0.4+)
- ✅ Hook `ask` permission decision prompts user for confirmation (v1.0.4+)
- ✅ Cross-platform hook configs work across VS Code, Claude Code, and CLI (v1.0.6+)
- ✅ Hooks can also be defined in `settings.json`, `settings.local.json`, and `config.json`

## Next Steps

→ Continue to [Module 10: Context Management](10-context.md)

## References

- [Hooks Configuration - GitHub Docs](https://docs.github.com/en/copilot/reference/hooks-configuration)
- [Use Hooks - GitHub Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/use-hooks)
