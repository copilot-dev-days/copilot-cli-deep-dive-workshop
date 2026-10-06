# GitHub Copilot CLI Workshop

Welcome to this hands-on workshop for mastering GitHub Copilot CLI! This workshop will take you from installation to advanced automation techniques.

## Prerequisites

- GitHub account with an active Copilot subscription (Pro, Pro+, Business, or Enterprise)
- Current Node.js LTS and npm (for npm installation method)
- Basic command-line experience
- A code editor (VS Code recommended)
- Git installed and configured
- `jq` installed (used by several exercises to inspect JSON output)
- GitHub CLI (`gh`) installed and authenticated (used by several exercises)

## Learning Objectives

By the end of this workshop, you will be able to:

- Install and configure Copilot CLI on any platform
- Use interactive, interactive-with-prompt, and programmatic modes effectively, including slash commands
- Manage sessions and delegate tasks to cloud agents
- Create custom instructions with AGENTS.md and copilot-instructions.md
- Control tool permissions, URL access, and use `--yolo` mode safely
- Configure and use MCP servers, including the built-in GitHub MCP server
- Create and use skills from agentskills.io
- Build custom agents for specialized workflows
- Set up hooks for lifecycle automation
- Manage context effectively with `/context` and `/compact`
- Use autopilot mode for autonomous task execution
- Leverage fleet command for parallel multi-agent workflows
- Configure IDE integration, accessibility, and team standardization

## Workshop Modules

| # | Module | Duration | Description |
| --- | --- | --- | --- |
| 01 | [Installation](01-installation.md) | 15 min | Install via npm, Homebrew, or script |
| 02 | [Operating Modes & Commands](02-modes.md) | 30 min | Interactive chat, slash commands, programmatic, and `/delegate` |
| 03 | [Custom Instructions](03-instructions.md) | 25 min | AGENTS.md, copilot-instructions.md, path-specific instructions |
| 04 | [Tools & Permissions](04-tools.md) | 20 min | Built-in tools, allow/deny, `--yolo` mode |
| 05 | [MCP Servers](05-mcps.md) | 25 min | Configure remote and local MCP servers |
| 06 | [Agent Skills](06-skills.md) | 20 min | Create and use skills, agentskills.io |
| 07 | [Plugins](07-plugins.md) | 15 min | Plugins and the marketplace ecosystem |
| 08 | [Custom Agents](08-custom-agents.md) | 25 min | Build specialized agents and subagents |
| 09 | [Hooks](09-hooks.md) | 20 min | Lifecycle hooks and automation |
| 10 | [Context Management](10-context.md) | 15 min | `/context`, `/compact`, token optimization |
| 11 | [Session Management](11-sessions.md) | 15 min | Continue, resume, clear, and track sessions |
| 12 | [Advanced Topics](12-advanced.md) | 30 min | Autopilot, Fleet, environment, CI/CD, LSP config, tips |
| 13 | [Configuration & Environment](13-configuration.md) | 20 min | Config options, env vars, IDE integration, accessibility |

**Total estimated time: ~4.5 hours**

## Workshop Flow

```
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Installation │────▶│ Core Concepts │────▶│ Advanced │
│ (Module 1) │ │ (Modules 2-5) │ │ (Modules 6-13) │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## How to Use This Workshop

1. **Follow in order** - Modules build on each other
2. **Complete exercises** - Hands-on practice reinforces learning
3. **Check expected outcomes** - Verify your understanding
4. **Use the references** - Official docs have more detail

## Quick Reference Card

### Essential Commands

```bash
# Start interactive session
copilot

# Interactive mode with auto-executed prompt
copilot -i "Fix the bug in main.js"

# Programmatic mode (single prompt)
copilot -p "your prompt here"

# Allow specific tools
copilot --allow-tool 'shell(git status)'

# Full autonomy (use carefully!)
copilot --yolo

# Resume last session
copilot --continue
```

### Essential Slash Commands

| Command | Description |
| --- | --- |
| `/help` | Show all available commands |
| `/ask` | Ask a quick question without affecting conversation history |
| `/refine` | Rewrite a rough prompt into a clear one for review |
| `/clear` | Abandon session and start fresh |
| `/new` | Start new conversation (old session stays backgrounded) |
| `/session` | View and manage sessions |
| `/fork` | Fork the current session into a new session |
| `/worktree` | Create a git worktree from your base ref and switch into it |
| `/move` | Move uncommitted changes into a new git worktree and switch into it |
| `/usage` | Display session usage metrics |
| `/context` | View token usage |
| `/compact` | Compress session history |
| `/plan` | Create implementation plan before coding |
| `/review` | Run code review agent |
| `/rubber-duck` | Get high-signal critique of a plan, design, or implementation |
| `/security-review` | Analyze changes for security vulnerabilities |
| `/diff` | Review changes made in current directory |
| `/pr` | Operate on pull requests for the current branch |
| `/delegate` | Hand off to cloud agent |
| `/model` | Switch AI model |
| `/mcp` | Manage MCP servers |
| `/plugin` | Manage plugins and plugin marketplaces |
| `/init` | Initialize Copilot config for repo |
| `/instructions` | View and toggle custom instruction files |
| `/allow-all` | Enable all permissions during the session |
| `/permissions` | Switch between permission modes (`manual`, `assisted`, `allow-all`, `show`) |
| `/add-dir` | Add a directory to the session access scope |
| `/list-dirs` | Display all accessible directories |
| `/cwd` | Change working directory |
| `/research` | Deep research with exportable reports |
| `/rewind` (alias `/undo`) | Rewind the last turn and revert file changes (also via double-Esc) |
| `/copy` | Copy last response to clipboard |
| `/ide` | Connect to IDE workspace |
| `/lsp` | Manage language server configuration |
| `/terminal-setup` | Configure multiline terminal input |
| `/voice` | Manage voice mode (dictation) |
| `/after` | Schedule a one-shot prompt or skill |
| `/every` | Schedule a recurring prompt or skill |
| `/fleet` | Enable fleet mode for parallel subagent execution |
| `/tasks` | View and manage tasks (subagents and shell commands) |
| `/env` | Show loaded instructions, MCP servers, skills, agents, hooks, plugins, LSPs, and extensions |
| `/settings` | Open or edit CLI settings |
| `/statusline` | Configure status line items |
| `/changelog` | Display the changelog for CLI releases |
| `/subagents` | Configure default and per-agent subagent models |
| `/vim` | Toggle Vim mode for the prompt input |
| `/collect-debug-logs` | Collect debug logs to a local `.tgz` file or a secret gist |

## Environment Setup Check

Before starting, verify your environment:

```bash
# Check Node.js runtime (use current LTS)
node --version

# Check npm
npm --version

# Check Git
git --version

# Check GitHub CLI (used by several exercises)
gh --version

# Check jq (used by several exercises to inspect JSON output)
jq --version
```

### Ubuntu/Debian Quick Setup (example)

If you're missing prerequisites (e.g., in a fresh Docker container):

```bash
# Basic tools
apt-get update && apt-get install -y curl git jq gh

# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# Install nvm and Node.js LTS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
source ~/.bashrc
nvm install --lts
```

## Getting Help

- **Official Docs**: <https://docs.github.com/en/copilot>
- **GitHub Community**: <https://github.com/orgs/community/discussions>
- **Issue Tracker**: <https://github.com/github/copilot-cli/issues>

---

**Ready to begin?** → Continue to [Module 1: Installation](01-installation.md)
