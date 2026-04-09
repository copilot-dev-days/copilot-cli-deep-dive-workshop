# GitHub Copilot CLI Workshop

> **Tested against:** GitHub Copilot CLI **v1.0.16** (Generally Available, version 1.0 since v1.0.0). Check [releases](https://github.com/github/copilot-cli/releases) for newer versions — some features may change or new ones may be added.

Welcome to this hands-on workshop for mastering GitHub Copilot CLI! This workshop will take you from installation to advanced automation techniques.

## Prerequisites

- GitHub account with an active Copilot subscription (Pro, Pro+, Business, or Enterprise)
- Node.js v22+ and npm v10+ (for npm installation method)
- Basic command-line experience
- A code editor (VS Code recommended)
- Git installed and configured

## Learning Objectives

By the end of this workshop, you will be able to:

- Install and configure Copilot CLI on any platform
- Use interactive, interactive-with-prompt, and programmatic modes effectively, including slash commands
- Manage sessions and delegate tasks to cloud agents
- Create custom instructions with AGENTS.md and llm.txt
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
| 03 | [Custom Instructions](03-instructions.md) | 25 min | AGENTS.md, llm.txt, copilot-instructions.md |
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
copilot --allow-tool 'shell(git)'

# Full autonomy (use carefully!)
copilot --yolo

# Resume last session
copilot --resume
```

### Essential Slash Commands

| Command | Description |
| --- | --- |
| `/help` | Show all available commands |
| `/clear` | Abandon session and start fresh |
| `/new` | Start new conversation (old session stays backgrounded) |
| `/context` | View token usage |
| `/compact` | Compress session history |
| `/plan` | Create implementation plan before coding |
| `/review` | Run code review agent |
| `/diff` | Review changes made in current directory |
| `/delegate` | Hand off to cloud agent |
| `/model` | Switch AI model |
| `/mcp` | Manage MCP servers |
| `/init` | Initialize Copilot config for repo |
| `/instructions` | View and toggle custom instruction files |
| `/cwd` | Change working directory |
| `/research` | Deep research with exportable reports |
| `/undo` | Undo last turn and revert file changes |
| `/rewind` | Roll back to any point in conversation history |
| `/copy` | Copy last response to clipboard |
| `/ide` | Connect to IDE workspace |
| `/streamer-mode` | Toggle streamer mode |

## Environment Setup Check

Before starting, verify your environment:

```bash
# Check Node.js version (need v22+)
node --version

# Check npm version (need v10+)
npm --version

# Check Git
git --version

# Check GitHub CLI (optional but recommended)
gh --version
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
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install --lts
```

## Getting Help

- **Official Docs**: <https://docs.github.com/en/copilot>
- **GitHub Community**: <https://github.com/orgs/community/discussions>
- **Issue Tracker**: <https://github.com/github/copilot-cli/issues>

---

**Ready to begin?** → Continue to [Module 1: Installation](01-installation.md)
