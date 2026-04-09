# Module 13: Configuration & Environment

## Prerequisites

- Completed Modules 1-12
- Understanding of JSON configuration
- Access to ~/.copilot/ directory

## Learning Objectives

- Master all configuration options in config.json
- Understand every environment variable that controls Copilot CLI
- Use the comprehensive CLI flags reference
- Configure IDE integration, streaming, and accessibility options
- Customize the CLI experience for team standardization

## Concepts

### Configuration File Location

Copilot CLI stores its configuration at ~/.copilot/config.json (or the directory specified by COPILOT_HOME). Use --config-dir to specify an alternative directory at startup.

```bash
# Override config directory
copilot --config-dir /path/to/custom/config
```

### Configuration Options Reference

All options below are set in ~/.copilot/config.json:

```json
{
  "model": "claude-sonnet-4.6",
  "theme": "auto",
  "mouse": true,
  "banner": "once",
  "beep": true,
  "stream": true,
  "autoUpdate": true,
  "bashEnv": false,
  "experimental": false,
  "compactPaste": true,
  "copyOnSelect": false,
  "renderMarkdown": true,
  "screenReader": false,
  "streamerMode": false,
  "includeCoauthor": true,
  "updateTerminalTitle": true,
  "logLevel": "default",
  "ide": {
    "autoConnect": true,
    "openDiffOnEdit": true
  },
  "customAgents": {
    "defaultLocalOnly": false
  },
  "trustedFolders": [],
  "allowedUrls": [],
  "deniedUrls": [],
  "companyAnnouncements": []
}
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `model` | string | (varies) | AI model to use; changeable via `/model` or `--model` |
| `theme` | string | `"auto"` | Color theme: `"auto"`, `"dark"`, or `"light"` |
| `mouse` | bool | `true` | Mouse support |
| `banner` | string | `"once"` | Startup banner: `"always"`, `"never"`, or `"once"` |
| `beep` | bool | `true` | Terminal beep when user attention is required |
| `stream` | bool | `true` | Enable response streaming |
| `autoUpdate` | bool | `true` | Auto-download CLI updates (disabled in CI by default) |
| `bashEnv` | bool | `false` | Source BASH_ENV in shell sessions |
| `experimental` | bool | `false` | Enable experimental features |
| `compactPaste` | bool | `true` | Collapse large pasted content (>10 lines) into compact tokens |
| `copyOnSelect` | bool | macOS: `true`, else: `false` | Auto-copy text selection to clipboard |
| `renderMarkdown` | bool | `true` | Render markdown formatting in terminal output |
| `screenReader` | bool | `false` | Enable screen reader optimizations |
| `streamerMode` | bool | `false` | Hide preview model names and quota details (for streaming/screen sharing) |
| `includeCoauthor` | bool | `true` | Instruct agent to add Co-authored-by trailer to git commits |
| `updateTerminalTitle` | bool | `true` | Show current intent in terminal title bar |
| `logLevel` | string | `"default"` | Log level: `"none"`, `"error"`, `"warning"`, `"info"`, `"debug"`, `"all"` |
| `ide.autoConnect` | bool | `true` | Auto-connect to IDE workspace on startup |
| `ide.openDiffOnEdit` | bool | `true` | Open file edit diffs in connected IDE for approval |
| `customAgents.defaultLocalOnly` | bool | `false` | Default to local agents only (skip remote org/enterprise agents) |
| `trustedFolders` | array | `[]` | Folders granted read/execute permission |
| `allowedUrls` | array | `[]` | URLs/domains allowed without prompting (supports wildcards like `*.github.com`) |
| `deniedUrls` | array | `[]` | URLs/domains denied access (takes precedence over allowed) |
| `companyAnnouncements` | array | `[]` | Custom startup messages (one randomly selected per session) |
| `mergeStrategy` | string | `"merge"` | Git merge strategy for PR operations (renamed from `merge_strategy` in v1.0.3) |

### Environment Variables Reference

| Variable | Description | Precedence |
|----------|-------------|------------|
| `COPILOT_GITHUB_TOKEN` | Authentication token | Highest (over GH_TOKEN, GITHUB_TOKEN) |
| `GH_TOKEN` | Authentication token | Middle |
| `GITHUB_TOKEN` | Authentication token | Lowest |
| `COPILOT_HOME` | Override config/state directory (default: ~/.copilot) | -- |
| `COPILOT_MODEL` | Set default model (overridden by --model or /model) | -- |
| `COPILOT_ALLOW_ALL` | Set "true" to allow all tools without confirmation | -- |
| `COPILOT_AUTO_UPDATE` | Set "false" to disable auto-updates | -- |
| `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | Comma-separated additional dirs for instruction files | -- |
| `COPILOT_EDITOR` | Editor for interactive editing (plan, prompts) | Highest (over VISUAL, EDITOR) |
| `VISUAL` | Editor fallback | Middle |
| `EDITOR` | Editor fallback | Lowest |
| `PLAIN_DIFF` | Set "true" to disable rich diff rendering | -- |
| `USE_BUILTIN_RIPGREP` | Set "false" to use PATH ripgrep instead of bundled | -- |
| `NO_COLOR` | Disable colored output (standard convention) | -- |
| `COLORFGBG` | Fallback for dark/light background detection ("fg;bg" format) | -- |
| `GH_HOST` | Override GitHub API hostname (for GHEC data residency) | -- |
| `HTTP_PROXY` | HTTP proxy URL for network requests | -- |
| `HTTPS_PROXY` | HTTPS proxy URL for network requests | -- |
| `NO_PROXY` | Comma-separated hosts to bypass proxy | -- |
| `CI`, `BUILD_NUMBER`, `RUN_ID`, `SYSTEM_COLLECTIONURI` | CI environment detection (disables auto-update) | -- |

### CLI Flags Quick Reference

| Flag | Description |
|------|-------------|
| `-p, --prompt <text>` | Non-interactive mode (exits after completion) |
| `-i, --interactive <prompt>` | Interactive mode with auto-executed prompt |
| `-s, --silent` | Output only agent response (no stats) |
| `-v, --version` | Show version information |
| `--model <model>` | Set AI model |
| `--reasoning-effort <level>` | Set reasoning effort level for model |
| `--binary-version` | Query CLI binary version without launching |
| `--resume [sessionId]` | Resume previous session |
| `--continue` | Resume most recent session |
| `--yolo` / `--allow-all` | Enable all permissions |
| `--allow-tool [tools...]` | Allow specific tools |
| `--deny-tool [tools...]` | Deny specific tools |
| `--allow-url [urls...]` | Allow specific URLs/domains |
| `--deny-url [urls...]` | Deny specific URLs/domains |
| `--allow-all-tools` | Allow all tools without confirmation |
| `--allow-all-paths` | Disable file path verification |
| `--allow-all-urls` | Allow all URLs without confirmation |
| `--add-dir <directory>` | Add directory to allowed list (repeatable) |
| `--disallow-temp-dir` | Prevent auto-access to system temp directory |
| `--available-tools [tools...]` | Only these tools visible to model |
| `--excluded-tools [tools...]` | These tools hidden from model |
| `--autopilot` | Enable autopilot mode |
| `--max-autopilot-continues <n>` | Limit autopilot rounds |
| `--no-ask-user` | Disable agent questions |
| `--agent <agent>` | Use a specific custom agent |
| `--additional-mcp-config <json>` | Add MCP config (repeatable) |
| `--add-github-mcp-tool <tool>` | Add GitHub MCP server tool (repeatable) |
| `--add-github-mcp-toolset <set>` | Add GitHub MCP toolset (repeatable) |
| `--enable-all-github-mcp-tools` | Enable all GitHub MCP tools |
| `--disable-builtin-mcps` | Disable built-in MCP servers |
| `--disable-mcp-server <name>` | Disable specific MCP server (repeatable) |
| `--plugin-dir <directory>` | Load plugin from local dir (repeatable) |
| `--secret-env-vars [vars...]` | Redact env var values from output |
| `--no-custom-instructions` | Disable AGENTS.md loading |
| `--output-format <format>` | Output as text or json (JSONL) |
| `--stream <mode>` | Streaming: on or off |
| `--acp` | Start as Agent Client Protocol server |
| `--share [path]` | Export session to markdown file |
| `--share-gist` | Export session to GitHub Gist |
| `--config-dir <directory>` | Override config directory |
| `--log-dir <directory>` | Set log file directory |
| `--log-level <level>` | Set log level |
| `--banner` | Show startup banner |
| `--no-color` | Disable color output |
| `--no-auto-update` | Disable auto-update |
| `--mouse [on\|off]` | Toggle mouse support |
| `--bash-env [on\|off]` | Toggle BASH_ENV support |
| `--experimental` / `--no-experimental` | Toggle experimental features |
| `--screen-reader` | Enable screen reader optimizations |
| `--plain-diff` | Disable rich diff rendering |

## Hands-On Exercises

### Exercise 1: Explore Your Configuration

**Goal:** Understand and modify config.json settings.

**Steps:**

1. View your current configuration:

   ```bash
   cat ~/.copilot/config.json | jq .
   ```

2. Check the available config options:

   ```bash
   copilot help config
   ```

3. Modify a setting -- enable mouse mode:

   ```json
   {
     "mouse": true
   }
   ```

4. Start Copilot and verify the change takes effect.

5. Try toggling options via CLI flags (flags persist to config):

   ```bash
   # These flags update config.json automatically
   copilot --mouse off
   copilot --bash-env on
   ```

**Expected Outcome:**
You can view, modify, and verify config options and understand that certain CLI flags persist their values to config.

### Exercise 2: Environment Variable Control

**Goal:** Control Copilot behavior via environment variables.

**Steps:**

1. Set a custom config directory:

   ```bash
   export COPILOT_HOME=/tmp/copilot-test
   copilot --version
   ls /tmp/copilot-test/
   ```

2. Set the default model via environment:

   ```bash
   export COPILOT_MODEL=gpt-4.1
   copilot -p "What model are you using?"
   ```

3. Add extra instruction directories:

   ```bash
   mkdir -p /tmp/team-instructions
   echo "Always use TypeScript" > /tmp/team-instructions/AGENTS.md
   export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="/tmp/team-instructions"
   copilot
   /instructions
   ```

4. Set a custom editor for plan editing:

   ```bash
   export COPILOT_EDITOR="code --wait"
   copilot
   # Ctrl+Y will now open the plan in VS Code
   ```

5. Clean up:

   ```bash
   unset COPILOT_HOME COPILOT_MODEL COPILOT_CUSTOM_INSTRUCTIONS_DIRS COPILOT_EDITOR
   rm -rf /tmp/copilot-test /tmp/team-instructions
   ```

**Expected Outcome:**
You can control Copilot behavior via environment variables and understand their precedence.

### Exercise 3: IDE Integration

**Goal:** Configure the IDE connection and diff review experience.

**Steps:**

1. Check IDE connection status:

   ```bash
   copilot
   /ide
   ```

2. The `/ide` command shows connected IDE workspaces. If VS Code is running with a workspace open, Copilot auto-connects.

3. Modify IDE behavior in config:

   ```json
   {
     "ide": {
       "autoConnect": true,
       "openDiffOnEdit": true
     }
   }
   ```

   - `autoConnect: false` prevents auto-connecting to IDEs on startup
   - `openDiffOnEdit: false` shows file diffs in terminal only, not in IDE

4. Test the difference: with `openDiffOnEdit: true`, ask Copilot to edit a file and observe the diff opening in VS Code.

**Expected Outcome:**
You understand how Copilot integrates with IDEs and can customize the behavior.

### Exercise 4: Streamer Mode and Accessibility

**Goal:** Configure privacy and accessibility settings.

**Steps:**

1. Enable streamer mode (hides model names and quota):

   ```bash
   copilot
   /streamer-mode
   ```

   Or via config:

   ```json
   { "streamerMode": true }
   ```

2. Enable screen reader optimizations:

   ```bash
   copilot --screen-reader
   ```

3. Disable color output for logging or plain terminals:

   ```bash
   copilot --no-color
   # or
   NO_COLOR=1 copilot
   ```

4. Disable rich diff rendering:

   ```bash
   copilot --plain-diff
   # or
   PLAIN_DIFF=true copilot
   ```

**Expected Outcome:**
You can configure Copilot for streaming, screen readers, and plain-text environments.

### Exercise 5: Team Configuration Standardization

**Goal:** Create shareable configuration for team consistency.

**Steps:**

1. Create team announcements that show on startup:

   ```json
   {
     "companyAnnouncements": [
       "Remember: never commit secrets to the repo",
       "Check the team wiki for coding standards",
       "Sprint 14 ends Friday - update your PRs"
     ]
   }
   ```

2. Set up team-wide defaults:

   ```json
   {
     "model": "gpt-4.1",
     "includeCoauthor": true,
     "compactPaste": true,
     "updateTerminalTitle": true,
     "beep": true,
     "customAgents": {
       "defaultLocalOnly": false
     }
   }
   ```

3. Create a team config template and document it in your AGENTS.md.

4. Verify the announcements appear on startup:

   ```bash
   copilot
   # One of the announcement messages should appear in the banner
   ```

**Expected Outcome:**
You can create and distribute team-standard configurations.

### Exercise 6: Logging and Debugging

**Goal:** Configure logging for troubleshooting.

**Steps:**

1. Enable debug logging:

   ```bash
   copilot --log-level debug
   ```

2. Set a custom log directory:

   ```bash
   copilot --log-dir ./my-logs
   ```

3. After a session, inspect the logs:

   ```bash
   ls ~/.copilot/logs/
   # or
   ls ./my-logs/
   ```

4. Use the built-in ripgrep or switch to system ripgrep:

   ```bash
   # Use the system ripgrep instead of bundled
   USE_BUILTIN_RIPGREP=false copilot
   ```

**Expected Outcome:**
You can enable detailed logging and understand the log directory structure.

## Summary

- ✅ config.json centralizes all CLI preferences
- ✅ Config options cover model, theme, streaming, mouse, and more
- ✅ `compactPaste` auto-collapses large pastes into compact tokens
- ✅ `copyOnSelect` enables clipboard integration
- ✅ `companyAnnouncements` broadcasts team messages on startup
- ✅ `includeCoauthor` auto-adds Co-authored-by to commits
- ✅ `updateTerminalTitle` shows current intent in terminal title
- ✅ IDE integration is controlled via `ide.autoConnect` and `ide.openDiffOnEdit`
- ✅ `/ide` connects to IDE workspaces, `/streamer-mode` hides sensitive info
- ✅ `/copy` copies last response to clipboard
- ✅ Environment variables control auth, model, editor, and instruction paths
- ✅ `COPILOT_HOME` overrides the config directory
- ✅ `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` adds extra instruction search paths
- ✅ `--log-dir` and `--log-level` enable debugging
- ✅ `--screen-reader`, `--no-color`, `--plain-diff` for accessibility
- ✅ Proxy support via `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` environment variables
- ✅ `--reasoning-effort` flag controls model reasoning level (v1.0.4+)
- ✅ `mergeStrategy` replaces deprecated `merge_strategy` config key (v1.0.3+)
- ✅ `--binary-version` checks installed version without launching (v1.0.3+)

## Workshop Complete! 🎉

Congratulations on completing the GitHub Copilot CLI Workshop!

### What You've Learned

1. **Installation** - Multiple methods to install and authenticate
2. **Operating Modes** - Interactive, interactive-with-prompt, programmatic, and delegate
3. **Sessions** - Management, persistence, and control
4. **Instructions** - AGENTS.md, copilot-instructions.md, llm.txt
5. **Tools** - Permissions, allow/deny, URL access, YOLO mode
6. **MCP Servers** - Configuration, built-in GitHub MCP, custom integrations
7. **Skills** - Creating and using specialized capabilities
8. **Plugins** - Ecosystem, marketplaces, and custom extensions
9. **Custom Agents** - Building specialized personas
10. **Hooks** - Lifecycle automation and security
11. **Context** - Monitoring and optimization
12. **Advanced** - Autopilot, Fleet, ACP, CI/CD, LSP config, `/research`, `/chronicle`, and team practices
13. **Configuration** - Config options, environment variables, and comprehensive reference

### Next Steps

- Practice daily with real projects
- Create custom agents for your workflow
- Share skills with your team
- Contribute to the Copilot ecosystem

## References

- [Copilot CLI - GitHub Docs](https://docs.github.com/copilot/how-tos/copilot-cli)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot CLI Blog Posts](https://github.blog/tag/copilot/)
- [GitHub Community Discussions](https://github.com/orgs/community/discussions)
- [agentskills.io](https://agentskills.io/)

---

**Thank you for participating in this workshop!**

→ Return to [Workshop Index](00-index.md)
