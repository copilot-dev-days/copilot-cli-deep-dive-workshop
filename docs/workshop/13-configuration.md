# Module 13: Configuration & Environment

## Prerequisites

- Completed Modules 1-12
- Understanding of JSON configuration
- Access to ~/.copilot/ directory

## Learning Objectives

- Master the user settings in `settings.json`
- Understand every environment variable that controls Copilot CLI
- Use the comprehensive CLI flags reference
- Configure IDE integration, streaming, and accessibility options
- Customize the CLI experience for team standardization

## Concepts

### Configuration File Location

Copilot CLI stores user settings at `~/.copilot/settings.json` (or under the directory specified by `COPILOT_HOME`).

```bash
# Override config directory
export COPILOT_HOME=/path/to/custom/config
copilot
```

When you specify a custom config directory, the preferences stored in that directory's `settings.json` are used instead of the defaults.

> [!WARNING]
> `~/.copilot/config.json` sits next to `settings.json`, but it is managed automatically by the CLI and holds your authentication token along with machine state such as `trustedFolders`. Do not print, copy, or share it — this matters especially in a screen-shared workshop. Put your own preferences in `~/.copilot/settings.json`, or use `/settings` to edit them.

### Settings Scopes

Settings are layered. Later scopes override earlier ones, and organization-managed settings always win.

| Scope | Location | Set with |
| --- | --- | --- |
| User | `~/.copilot/settings.json` | `/settings <key> <value>` |
| Repository (shared) | `.github/copilot/settings.json` | `/settings --repo <key> <value>` |
| Repository (personal, not committed) | `.github/copilot/settings.local.json` | `/settings --local <key> <value>` |
| Organization-managed | Delivered by policy | Read-only; shown as `managed (read-only)` |

Managed settings apply on top of your own; keys marked `managed (read-only)` cannot be edited from the CLI. `/model` also accepts `--repo` and `--local` to set a repository default model, `/config model` to set your user default, and `plan` / `--plan` to set the plan-mode model.

### Configuration Options Reference

All options below are set in `~/.copilot/settings.json`:

```json
{
  "model": "auto",
  "theme": "github",
  "mouse": true,
  "banner": "once",
  "beep": false,
  "stream": true,
  "autoUpdate": true,
  "bashEnv": false,
  "experimental": false,
  "compactPaste": true,
  "copyOnSelect": false,
  "renderMarkdown": true,
  "screenReader": false,
  "streamerMode": false,
  "memory": true,
  "includeCoAuthoredBy": true,
  "updateTerminalTitle": true,
  "terminalProgress": true,
  "logLevel": "default",
  "keepAlive": "off",
  "continueOnAutoMode": false,
  "respectGitignore": true,
  "disableAllHooks": false,
  "ide": {
    "autoConnect": true,
    "openDiffOnEdit": true
  },
  "customAgents": {
    "defaultLocalOnly": false
  },
  "allowedUrls": [],
  "deniedUrls": [],
  "companyAnnouncements": []
}
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `model` | string | (varies) | AI model to use; changeable via `/model` or `--model` |
| `defaultMode` | string | `"interactive"` | Agent mode new interactive sessions start in: `"interactive"`, `"plan"`, or `"autopilot"`; `--mode`, `--autopilot`, and `--plan` still win when passed |
| `defaultPermissionMode` | string | `"manual"` | Permission mode new interactive sessions start in: `"manual"`, `"assisted"`, or `"allow-all"`; pairs with `defaultMode: "autopilot"` to skip the autopilot permission confirmation entirely |
| `theme` | string | `"github"` | Color theme: `"default"`, `"github"`, `"dim"`, `"high-contrast"`, or `"colorblind"` |
| `mouse` | bool | `true` | Mouse support |
| `banner` | string | `"once"` | Startup banner: `"always"`, `"never"`, or `"once"` |
| `bannerStyle` | string | `"mona"` | Which artwork the startup banner uses: `"mona"` (two-Mona pixel-art hi-five) or `"classic"` (COPILOT wordmark with the goggled mascot); ignored when `banner` resolves to `"never"` |
| `beep` | bool | `false` | Terminal beep when user attention is required |
| `beepOnSchedule` | bool | `true` | Beep when a scheduled `/every` or `/after` run finishes (only when `beep` is enabled) |
| `notifications` | bool | `false` | Show OS notifications when attention is required and when the agent finishes |
| `showTipsOnStartup` | bool | `true` | Show a random command tip when the CLI starts |
| `commandHistoryMaxSize` | number | `50` | Prompts kept for `Ctrl+R` history search (integer between `1` and `1000`) |
| `stream` | bool | `true` | Enable response streaming |
| `autoUpdate` | bool | `true` | Auto-download CLI updates (disabled in CI by default) |
| `bashEnv` | bool | `false` | Source BASH_ENV in shell sessions |
| `experimental` | bool | `false` | Enable experimental features |
| `compactPaste` | bool | `true` | Collapse large pasted content (>10 lines) into compact tokens |
| `copyOnSelect` | bool | macOS: `true`, else: `false` | Auto-copy text selection to clipboard |
| `renderMarkdown` | bool | `true` | Render markdown formatting in terminal output |
| `scrollbar` | bool | `true` | Show the scrollbar in scrollable views |
| `inlineImages` | bool | `true` | Render images inline using the Kitty graphics protocol on supporting terminals |
| `inlineImageLiveWindow` | number | `50` | Maximum inline images kept resident in the terminal; `0` disables the cap |
| `screenReader` | bool | `false` | Enable screen reader optimizations |
| `streamerMode` | bool | `false` | Hide preview model names and quota details (for streaming/screen sharing) |
| `memory` | bool | `true` | Enable agentic memory (cross-session fact recall); toggle with `/memory on\|off` |
| `includeCoAuthoredBy` | bool | `true` | Instruct agent to add Co-authored-by trailer to git commits |
| `updateTerminalTitle` | bool | `true` | Show current intent in terminal title bar |
| `terminalProgress` | bool | `true` | Emit terminal progress indicators (OSC 9;4) while agent is working |
| `logLevel` | string | `"default"` | Log level: `"none"`, `"error"`, `"warning"`, `"info"`, `"debug"`, `"all"` |
| `keepAlive` | string | `"off"` | Prevent system sleep: `"off"`, `"on"`, or `"busy"` (busy = only while agent is working) |
| `continueOnAutoMode` | bool | `false` | Auto-switch to auto mode on rate limit errors; does not apply to global limits |
| `stayInAutopilot` | bool | `true` | Stay in autopilot mode after an autopilot task completes |
| `effortLevel` | string | (varies) | Reasoning effort level; also set with `--effort` / `--reasoning-effort` |
| `contextTier` | string | `"default"` | Context window tier for tiered-pricing models: `"default"` or `"long_context"` |
| `respectGitignore` | bool | `true` | Exclude gitignored files from the `@` file mention picker |
| `disableAllHooks` | bool | `false` | Disable all hooks (repo-level and user-level) |
| `ide.autoConnect` | bool | `true` | Auto-connect to IDE workspace on startup |
| `ide.openDiffOnEdit` | bool | `true` | Open file edit diffs in connected IDE for approval |
| `customAgents.defaultLocalOnly` | bool | `false` | Default to local agents only (skip remote org/enterprise agents) |
| `allowedUrls` | array | `[]` | URLs/domains allowed without prompting (supports wildcards like `*.github.com`) |
| `deniedUrls` | array | `[]` | URLs/domains denied access (takes precedence over allowed) |
| `companyAnnouncements` | array | `[]` | Custom startup messages (one randomly selected per session) |
| `statusLine` | object | (none) | Custom status line config with `type`, `command`, `padding`, and `refreshInterval` |
| `tabs` | object | (none) | Home screen tab bar: `enabled`, `sort`, and `hide` |
| `proxyUrl` | string | (none) | Proxy URL for HTTP(S) requests; overridden by `HTTP_PROXY` / `HTTPS_PROXY` |
| `proxyKerberosServicePrincipal` | string | (none) | SPN for Kerberos/Negotiate proxy auth; overridden by `COPILOT_PROXY_KERBEROS_SPN` |
| `powershellFlags` | array | `["-NoProfile", "-NoLogo"]` | Flags passed to PowerShell (pwsh) on startup (Windows only) |

#### Discovery and Extension Settings

| Option | Type | Description |
|--------|------|-------------|
| `skillDirectories` | array | Extra directories to search for skills |
| `disabledSkills` | array | Skill names to keep from loading |
| `disabledHooks` | array | Hook names to keep from running |
| `hooks` | object | Inline hook definitions keyed by event name (same schema as `.github/hooks/*.json`) |
| `disabledMcpServers` | array | MCP servers to keep from starting |
| `enabledMcpServers` | array | MCP servers to start explicitly |
| `enabledPlugins` | array | Plugins enabled for this user |
| `extraKnownMarketplaces` | array | Additional trusted plugin marketplaces |
| `strictKnownMarketplaces` | bool | Restrict plugin installs to known marketplaces |
| `extensions.disabledExtensions` | array | CLI extensions to keep from loading |
| `githubMcpToolsets` / `githubMcpTools` | array | Toolsets and tools enabled on the built-in GitHub MCP server |
| `enableAllGithubMcpTools` | bool | Enable every GitHub MCP server tool instead of the default subset |

#### Subagent Settings

| Option | Type | Description |
|--------|------|-------------|
| `subagents.agents.<name>` | object | Per-subagent `model`, `effortLevel`, and `contextTier`; each accepts `"inherit"` |
| `subagents.disabledSubagents` | array | Subagents to keep from running |
| `subagents.maxConcurrency` | number | Maximum subagents running at once |
| `subagents.maxDepth` | number | Maximum subagent nesting depth |

Configure these interactively with `/subagents`.

#### Footer Settings

`footer.show*` keys toggle individual status bar items. Configure them interactively with `/footer`.

| Option | Shows |
|--------|-------|
| `footer.showModelEffort` | Active model and reasoning effort |
| `footer.showDirectory` | Working directory |
| `footer.showBranch` | Current git branch |
| `footer.showContextWindow` | Context window usage |
| `footer.showQuota` | Remaining plan quota |
| `footer.showAiUsed` | AI credits used this session |
| `footer.showAgent` | Active custom agent |
| `footer.showCodeChanges` | Lines added/removed |
| `footer.showUsername` | Logged-in GitHub user |
| `footer.showSandbox` | Command sandboxing status |
| `footer.showYolo` | Allow-all/YOLO status |
| `footer.showCiStatus` | CI status for the current branch |
| `footer.showSchedules` | Pending `/after` and `/every` schedules |
| `footer.showPullRequest` | Pull request for the current branch |
| `footer.showCustom` | Custom `statusLine` output |

#### Permission Settings

| Option | Type | Description |
|--------|------|-------------|
| `permissions.allow` | array | Tool patterns allowed without prompting |
| `permissions.ask` | array | Tool patterns that always prompt |
| `permissions.deny` | array | Tool patterns always refused (takes precedence) |

#### Command Sandboxing Settings

Command sandboxing is experimental: enable experimental features, then use `/sandbox` to view or configure the policy. All keys live under `sandbox` in `settings.json`. See `copilot help sandbox`.

| Option | Type | Description |
|--------|------|-------------|
| `sandbox.enabled` | bool | Whether shell commands run inside an OS-level sandbox |
| `sandbox.addCurrentWorkingDirectory` | bool | Grant read/write access to the current working directory |
| `sandbox.allowDevToolAccess` | bool | Auto-grant access to dev-tool caches, toolchains, and registry config |
| `sandbox.allowBypass` | bool | Allow a per-command escape hatch out of the sandbox |
| `sandbox.auth.git` / `sandbox.auth.gh` | bool | Inject git and `gh` credentials into sandboxed commands so authenticated git/`gh` operations keep working inside the sandbox. Tokens are never injected while the sandbox is disabled. |
| `sandbox.sandboxMcpServers` | bool | Spawn local (stdio) MCP servers inside the sandbox |
| `sandbox.sandboxLspServers` | bool | Spawn language servers inside the sandbox |
| `sandbox.userPolicy.filesystem.readwritePaths` | array | Extra paths granted read/write |
| `sandbox.userPolicy.filesystem.readonlyPaths` | array | Extra paths granted read-only |
| `sandbox.userPolicy.filesystem.deniedPaths` | array | Paths denied outright |
| `sandbox.userPolicy.filesystem.clearPolicyOnExit` | bool | Reset the stored filesystem policy when the session ends |
| `sandbox.userPolicy.network.allowOutbound` | bool | Allow outbound network connections |
| `sandbox.userPolicy.network.allowLocalNetwork` | bool | Allow connections to the local network |
| `sandbox.userPolicy.network.proxy.url` | string | Proxy URL for sandboxed network access |
| `sandbox.userPolicy.network.proxy.username` / `.password` | string | Proxy credentials (kept out of the URL) |
| `sandbox.userPolicy.seatbelt.keychainAccess` | bool | Allow system keychain access from inside the sandbox (macOS) |

#### Voice Settings

| Option | Type | Description |
|--------|------|-------------|
| `voice.enabled` | bool | Enable voice mode (dictation) |
| `voice.selectedModel` | string | Transcription model used by voice mode |

> Run `copilot help config` for the authoritative settings reference, or `/settings` to open the settings dialog and browse every key with its effective value and default.

### Environment Variables Reference

| Variable | Description | Precedence |
|----------|-------------|------------|
| `COPILOT_GITHUB_TOKEN` | Authentication token | Highest (over GH_TOKEN, GITHUB_TOKEN) |
| `GH_TOKEN` | Authentication token | Middle |
| `GITHUB_TOKEN` | Authentication token | Lowest |
| `COPILOT_HOME` | Override config/state directory (default: ~/.copilot) | -- |
| `COPILOT_MODEL` | Set default model (overridden by --model or /model) | -- |
| `COPILOT_ALLOW_ALL` | Set "true" to allow all tools without confirmation | -- |
| `COPILOT_ASSISTED_APPROVAL` | Review tool permission requests with the assisted-approval safety judge (same as `--assisted-approval`) | -- |
| `COPILOT_AUTO_UPDATE` | Set "false" to disable auto-updates | -- |
| `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | Comma-separated additional dirs for instruction files | -- |
| `COPILOT_EDITOR` | Editor for interactive editing (plan, prompts) | Highest (over VISUAL, EDITOR) |
| `VISUAL` | Editor fallback | Middle |
| `EDITOR` | Editor fallback | Lowest |
| `COPILOT_OFFLINE` | Set "true" for offline mode (skips auth, telemetry, web; requires BYOK provider) | -- |
| `COPILOT_GH_HOST` | GitHub hostname for Copilot CLI only (overrides GH_HOST) | -- |
| `GH_HOST` | GitHub hostname for auth and API requests (for GHEC data residency) | -- |
| `COPILOT_PROVIDER_BASE_URL` | API endpoint URL for custom model provider (activates BYOK mode) | -- |
| `COPILOT_PROVIDER_TYPE` | Provider type: "openai" (default), "azure", or "anthropic" | -- |
| `COPILOT_PROVIDER_API_KEY` | API key for custom provider | -- |
| `PLAIN_DIFF` | Set "true" to disable rich diff rendering | -- |
| `USE_BUILTIN_RIPGREP` | Set "false" to use PATH ripgrep instead of bundled | -- |
| `USE_TGREP` | Set "true" to always enable tgrep indexed search, "false" to force ripgrep | -- |
| `USE_TGREP_WARM_START` | Set "true" to block startup until the tgrep index is ready | -- |
| `NO_COLOR` | Disable colored output (standard convention) | -- |
| `COPILOT_DISABLE_TERMINAL_TITLE` | Disable updating the terminal tab/window title | -- |
| `COPILOT_INLINE_IMAGE_LIMIT` | Override the `inlineImageLiveWindow` setting | -- |
| `COPILOT_INLINE_IMAGES_HERDR` | Set "1" to opt in to inline images inside a herdr pane, once `inlineImages` is on | -- |
| `COPILOT_MULTIPLEXER` | Override which terminal multiplexer the CLI believes it is running directly inside: "tmux", "herdr", or "none"; set it when detection guesses wrong | -- |
| `COPILOT_SKILLS_DIRS` | Additional directories to search for skills | -- |
| `COPILOT_PLUGIN_DIR_ONLY` | Load plugins only from directories passed with `--plugin-dir` | -- |
| `COPILOT_HOOK_ALLOW_LOCALHOST` | Allow hooks to call localhost endpoints | -- |
| `COPILOT_HOOK_ALLOW_HTTP_AUTH_HOOKS` | Allow hooks that send HTTP auth headers | -- |
| `HTTP_PROXY` | HTTP proxy URL for network requests | -- |
| `HTTPS_PROXY` | HTTPS proxy URL for network requests | -- |
| `NO_PROXY` | Comma-separated hosts to bypass proxy | -- |
| `COPILOT_PROXY_KERBEROS_SPN` | Service principal name for Kerberos/Negotiate proxy auth | Over `proxyKerberosServicePrincipal` |
| `CI`, `BUILD_NUMBER`, `RUN_ID`, `SYSTEM_COLLECTIONURI` | CI environment detection (disables auto-update) | -- |

#### Custom Model Provider (BYOK) Variables

| Variable | Description |
|----------|-------------|
| `COPILOT_PROVIDER_BEARER_TOKEN` | Bearer token for the provider; takes precedence over `COPILOT_PROVIDER_API_KEY` |
| `COPILOT_PROVIDER_WIRE_API` | API format: `completions` (default) or `responses` |
| `COPILOT_PROVIDER_TRANSPORT` | Transport: `http` (default) or `websockets` |
| `COPILOT_PROVIDER_AZURE_API_VERSION` | Azure API version when using provider type `azure` |
| `COPILOT_PROVIDER_MODEL_ID` | Well-known model ID used for agent configuration and token limits |
| `COPILOT_PROVIDER_WIRE_MODEL` | Model name sent to the provider API for inference |
| `COPILOT_PROVIDER_MAX_PROMPT_TOKENS` | Maximum prompt tokens for the BYOK model |
| `COPILOT_PROVIDER_MAX_OUTPUT_TOKENS` | Maximum output tokens for the BYOK model |
| `COPILOT_PROVIDER_HEADERS` | Newline-separated `Name: Value` headers sent only to the BYOK endpoint |

#### OpenTelemetry / Monitoring Variables

Run `copilot help monitoring` for configuration examples.

| Variable | Description |
|----------|-------------|
| `COPILOT_OTEL_ENABLED` | Set "true" to explicitly enable OpenTelemetry instrumentation |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP endpoint URL; setting it enables OTel automatically |
| `COPILOT_OTEL_EXPORTER_TYPE` | Exporter backend: `otlp-http` (default) or `file` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP HTTP protocol: `http/json` (default) or `http/protobuf` |
| `COPILOT_OTEL_FILE_EXPORTER_PATH` | File path for JSON-lines output; setting it enables OTel automatically |
| `COPILOT_OTEL_SOURCE_NAME` | Instrumentation scope name; defaults to `github.copilot` |
| `OTEL_SERVICE_NAME` | Service name in resource attributes; defaults to `github-copilot` |
| `OTEL_RESOURCE_ATTRIBUTES` | Extra resource attributes as comma-separated `key=value` pairs |
| `OTEL_EXPORTER_OTLP_HEADERS` | Authentication headers for the OTLP exporter |
| `OTEL_EXPORTER_OTLP_CERTIFICATE` | PEM file with extra CA certificates to trust for the OTLP endpoint |
| `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE` / `OTEL_EXPORTER_OTLP_CLIENT_KEY` | Client certificate and key for mutual TLS (both required) |
| `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` | Set "true" to capture full prompt/response content |
| `OTEL_LOG_LEVEL` | OTel diagnostic log level: `NONE`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `VERBOSE`, or `ALL` |

> **Tip:** Run `copilot help environment` for the authoritative list of environment variables.

### CLI Flags Quick Reference

| Flag | Description |
|------|-------------|
| `-p, --prompt <text>` | Non-interactive mode (exits after completion) |
| `-i, --interactive <prompt>` | Interactive mode with auto-executed prompt |
| `-s, --silent` | Output only agent response (no stats) |
| `-v, --version` | Show version information |
| `-C <directory>` | Change working directory before doing anything else |
| `-n, --name <name>` | Set a name for the new session |
| `--mode <mode>` | Set the initial agent mode: `interactive`, `plan`, or `autopilot` |
| `--plan` | Start in plan mode |
| `--model <model>` | Set AI model |
| `--reasoning-effort <level>` | Set reasoning effort level for model |
| `--effort <level>` | Shorthand for `--reasoning-effort` |
| `--context <tier>` | Set context window tier (`default` or `long_context`) |
| `--enable-reasoning-summaries` | Request reasoning summaries for OpenAI models |
| `--connect[=sessionId]` | Connect directly to a remote session |
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
| `--assisted-approval` | Review tool permission requests with the assisted-approval safety judge instead of approving them outright (equivalent to the `assisted` mode of `/permissions`); takes precedence over `--allow-all-tools` when the judge engages, and requires `--experimental` or `enabledFeatureFlags.AUTO_APPROVAL` |
| `--sandbox` | Enable command sandboxing for the session at launch; not listed in `copilot --help` — see `copilot help sandbox` |
| `--add-dir <directory>` | Add directory to allowed list (repeatable) |
| `--disallow-temp-dir` | Prevent auto-access to system temp directory |
| `--available-tools [tools...]` | Only these tools visible to model |
| `--excluded-tools [tools...]` | These tools hidden from model |
| `--autopilot` | Enable autopilot mode |
| `--max-autopilot-continues <n>` | Limit autopilot rounds (default: 5) |
| `--no-ask-user` | Disable agent questions |
| `--agent <agent>` | Use a specific custom agent |
| `--additional-mcp-config <json-or-@file>` | Add MCP config as inline JSON or an `@`-prefixed file path (repeatable) |
| `--max-ai-credits <credits>` | Set a session AI credit limit |
| `--usage-output-file <file>` | Write final usage statistics as JSON to the specified file |
| `--session-id <id>` | Resume a session/task by ID or set a UUID for a new session |
| `--remote-export` | Export session to GitHub web/mobile read-only |
| `--remote` | Enable remote control of your session from GitHub web and mobile |
| `--no-remote` | Disable remote control |
| `--no-remote-export` | Disable remote export |
| `--enable-memory` | Enable memory in prompt mode |
| `--allow-all-mcp-server-instructions` | Include initialization instructions from all MCP servers |
| `--no-bash-env` | Disable BASH_ENV support |
| `--add-github-mcp-tool <tool>` | Add GitHub MCP server tool (repeatable) |
| `--add-github-mcp-toolset <set>` | Add GitHub MCP toolset (repeatable) |
| `--enable-all-github-mcp-tools` | Enable all GitHub MCP tools |
| `--disable-builtin-mcps` | Disable built-in MCP servers |
| `--disable-mcp-server <name>` | Disable specific MCP server (repeatable) |
| `--plugin-dir <directory>` | Load plugin from local dir (repeatable) |
| `--extension-sdk-path <directory>` | Override the bundled `@github/copilot-sdk` injected into extension subprocesses with a local `copilot-sdk/` folder; invalid paths fall back to the bundled SDK |
| `--secret-env-vars [vars...]` | Redact env var values from output |
| `--no-custom-instructions` | Disable AGENTS.md loading |
| `--output-format <format>` | Output as text or json (JSONL) |
| `--stream <mode>` | Streaming: on or off |
| `--acp` | Start as Agent Client Protocol server |
| `--share [path]` | Export session to markdown file after completion in non-interactive mode |
| `--share-gist` | Export session to GitHub Gist after completion in non-interactive mode |
| `--attachment <path>` | Attach a file (image or document) to prompt; non-interactive only (repeatable) |
| `--log-dir <directory>` | Set log file directory |
| `--log-level <level>` | Set log level |
| `--banner` | Show startup banner |
| `--no-color` | Disable color output |
| `--no-auto-update` | Disable auto-update |
| `--mouse [on\|off]` | Enable or disable mouse support in alt screen mode |
| `--no-mouse` | Disable mouse support in alt screen mode |
| `--bash-env [on\|off]` | Toggle BASH_ENV support |
| `--no-eager-powershell-resolution` | Disable background PowerShell prompt resolution on Windows (pairs with the `powershellFlags` setting) |
| `--experimental` / `--no-experimental` | Toggle experimental features |
| `--screen-reader` | Enable screen reader optimizations |
| `--plain-diff` | Disable rich diff rendering |

### The `/env` Command

Use `/env` inside an interactive session to see a comprehensive view of the loaded environment:

```
/env
```

This displays all eight loaded environment kinds:
- Active instruction files and their sources
- Loaded MCP servers and their status
- Available skills (project, personal, built-in)
- Available agents
- Loaded hooks
- Installed plugins
- Configured LSP servers
- Loaded extensions

### The `copilot app` Subcommand

```bash
copilot app
```

Opens the GitHub Copilot app in the current directory. The `/app` slash command does the same thing from inside a running session.

### The `copilot help monitoring` Topic

```bash
copilot help monitoring
```

This displays documentation on configuring OpenTelemetry for Copilot CLI observability, including OTLP exporter settings, span attributes, and monitoring backend integration.

## Hands-On Exercises

### Exercise 1: Explore Your Configuration

**Goal:** Understand and modify your `settings.json` settings.

> [!WARNING]
> Do not `cat` `~/.copilot/config.json`. It is managed automatically and contains your authentication token — printing it in a shared terminal exposes a live credential.

**Steps:**

1. View your current user settings:

   ```bash
   cat ~/.copilot/settings.json | jq .
   ```

2. Check the available settings:

   ```bash
   copilot help config
   ```

3. Modify a setting -- enable mouse mode:

   ```json
   {
     "mouse": true
   }
   ```

   Or set it from inside a session, which writes to `settings.json` for you:

   ```bash
   copilot
   ```

   ```
   /settings mouse on
   /settings show mouse
   ```

4. Start Copilot and verify the change takes effect.

5. Try toggling options via CLI flags (flags persist to your settings):

   ```bash
   # These flags update settings.json automatically
   copilot --mouse off
   copilot --bash-env on
   ```

6. Target repository scope instead of your user scope:

   ```bash
   copilot
   ```

   ```
   /settings --repo theme dim     # writes .github/copilot/settings.json
   /settings --local theme github # writes .github/copilot/settings.local.json
   ```

**Expected Outcome:**
You can view, modify, and verify settings at user and repository scope, and you understand that certain CLI flags persist their values to `settings.json`.

### Exercise 2: Environment Variable Control

**Goal:** Control Copilot behavior via environment variables.

**Steps:**

1. Set a custom config directory:

   ```bash
   export COPILOT_HOME=/tmp/copilot-test
   copilot -p "Reply with OK"
   ls /tmp/copilot-test/
   ```

   > [!NOTE]
   > Start a session before listing the directory. `copilot --version` exits before the config directory is initialized, so the directory would not exist yet.

2. Set the default model via environment:

   ```bash
   export COPILOT_MODEL=auto
   copilot -p "What model are you using?"
   ```

3. Add extra instruction directories:

   ```bash
   mkdir -p /tmp/team-instructions
   echo "Always use TypeScript" > /tmp/team-instructions/AGENTS.md
   export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="/tmp/team-instructions"
   copilot
   ```

   ```
   /instructions
   ```

4. Set a custom editor for plan editing:

   ```bash
   export COPILOT_EDITOR="code --wait"
   copilot
   # Ctrl+Y opens the plan in VS Code
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
   ```

   ```
   /ide
   ```

2. The `/ide` command shows connected IDE workspaces. If VS Code is running with a workspace open, Copilot auto-connects.

3. Modify IDE behavior in `settings.json`:

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

1. Enable streamer mode (hides preview model names and quota details) in `settings.json`:

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
       "Sprint ends this week - update your PRs"
     ]
   }
   ```

2. Set up team-wide defaults:

   ```json
   {
     "model": "auto",
     "includeCoAuthoredBy": true,
     "compactPaste": true,
     "updateTerminalTitle": true,
     "beep": true,
     "customAgents": {
       "defaultLocalOnly": false
     }
   }
   ```

3. Commit these as repository settings so everyone on the project picks them up:

   ```bash
   copilot
   ```

   ```
   /settings --repo model auto
   /settings --repo includeCoAuthoredBy on
   ```

   Shared values land in `.github/copilot/settings.json`; personal overrides that should not be committed go to `.github/copilot/settings.local.json` via `/settings --local`.

4. Document the template in your AGENTS.md.

5. Verify the announcements appear on startup:

   ```bash
   copilot
   # One of the announcement messages should appear in the banner
   ```

**Expected Outcome:**
You can create and distribute team-standard configurations across user and repository scopes.

### Exercise 6: Logging and Debugging

**Goal:** Configure logging for troubleshooting.

**Steps:**

1. Enable debug logging:

   ```bash
   copilot --log-level debug
   ```

2. Capture everything into a custom log directory:

   ```bash
   copilot --log-level all --log-dir ./my-logs
   ```

   Valid levels are `none`, `error`, `warning`, `info`, `debug`, `all`, and `default`. The equivalent setting is `logLevel`.

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

### Exercise 7: Session Limits and AI Credits

**Goal:** Cap how many AI credits a session can consume.

**Steps:**

1. Read the reference topics:

   ```bash
   copilot help limits
   copilot help billing
   ```

2. Start a session with an initial limit (the minimum is 30 AI credits):

   ```bash
   copilot --max-ai-credits 30
   ```

3. Inspect or change the limit from inside the session:

   ```
   /limits
   /limits set max-ai-credits 50
   ```

4. Watch usage in the footer and with `/usage`. Enable the relevant footer items if they are hidden:

   ```
   /footer
   ```

5. Capture the final usage numbers from a scripted run as JSON:

   ```bash
   copilot -p "Summarize the README" --allow-all-tools --usage-output-file ./usage.json
   jq . ./usage.json
   ```

6. Remove the limit when you are done:

   ```
   /limits unset max-ai-credits
   ```

**Expected Outcome:**
You can set, inspect, and clear a session AI credit limit, and export final usage statistics to a JSON file with `--usage-output-file`. You understand the limit is a soft cap — usage is only known after a model response returns, so one call can exceed the limit before the next call is blocked.

## Summary

- ✅ `settings.json` centralizes all CLI preferences; `/settings` reads and writes it
- ✅ `config.json` is machine-managed and holds credentials — never print or share it
- ✅ Settings layer across user, repository (`--repo`), personal repository (`--local`), and organization-managed scopes
- ✅ Config options cover model, theme, streaming, mouse, and more
- ✅ `compactPaste` auto-collapses large pastes into compact tokens
- ✅ `copyOnSelect` enables clipboard integration
- ✅ `companyAnnouncements` broadcasts team messages on startup
- ✅ `includeCoAuthoredBy` auto-adds Co-authored-by to commits
- ✅ `updateTerminalTitle` shows current intent in terminal title
- ✅ IDE integration is controlled via `ide.autoConnect` and `ide.openDiffOnEdit`
- ✅ `/ide` connects to IDE workspaces, and `streamerMode` hides sensitive info
- ✅ `/copy` copies last response to clipboard
- ✅ Environment variables control auth, model, editor, and instruction paths
- ✅ `COPILOT_HOME` overrides the config directory
- ✅ `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` adds extra instruction search paths
- ✅ `--log-dir` and `--log-level` enable debugging
- ✅ `--screen-reader`, `--no-color`, `--plain-diff` for accessibility
- ✅ `memory` config enables cross-session fact recall; toggle with `/memory on|off`
- ✅ `terminalProgress` shows progress indicators in terminal title bar
- ✅ Proxy support via `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` environment variables
- ✅ `--reasoning-effort` flag controls model reasoning level
- ✅ `/env` command shows loaded environment details
- ✅ `COPILOT_HOME` overrides config directory
- ✅ `copilot help monitoring` documents OpenTelemetry configuration
- ✅ `keepAlive` prevents system sleep (off/on/busy)
- ✅ `continueOnAutoMode` auto-switches to auto mode on rate limits
- ✅ `respectGitignore` controls `@` picker file filtering
- ✅ `statusLine` enables custom status line via external command
- ✅ BYOK support via `COPILOT_PROVIDER_*` env vars — run `copilot help providers` for details
- ✅ `COPILOT_OFFLINE` enables offline mode with local model providers
- ✅ `COPILOT_GH_HOST` overrides GitHub hostname for Copilot CLI only
- ✅ `footer.show*` settings control individual status bar items
- ✅ `sandbox.*` settings define the command sandboxing policy (experimental; see `copilot help sandbox`)
- ✅ `--sandbox` turns sandboxing on at launch; `sandbox.auth.git` / `sandbox.auth.gh` control credential injection
- ✅ `defaultMode` and `defaultPermissionMode` persist the mode and permission mode new interactive sessions start in
- ✅ `--assisted-approval` routes permission requests through the assisted-approval safety judge
- ✅ `copilot app` opens the GitHub Copilot app in the current directory; `/app` does the same from a session
- ✅ Session limits are opt-in via `--max-ai-credits` and `/limits` (soft cap, minimum 30 AI credits)
- ✅ `--usage-output-file` writes final usage statistics as JSON for scripted runs
- ✅ OpenTelemetry is configured entirely through `COPILOT_OTEL_*` and `OTEL_*` environment variables
- ✅ `copilot help config` and `copilot help environment` are the authoritative references

## Workshop Complete! 🎉

Congratulations on completing the GitHub Copilot CLI Workshop!

### What You've Learned

1. **Installation** - Multiple methods to install and authenticate
2. **Operating Modes** - Interactive, interactive-with-prompt (`-i`), programmatic (`-p`), and delegate
3. **Sessions** - Management, persistence, and control
4. **Instructions** - AGENTS.md, copilot-instructions.md, path-specific instructions
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

- [Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Use Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot CLI Blog Posts](https://github.blog/tag/copilot/)
- [GitHub Community Discussions](https://github.com/orgs/community/discussions)
- [agentskills.io](https://agentskills.io/)

---

**Thank you for participating in this workshop!**

→ Return to [Workshop Index](00-index.md)
