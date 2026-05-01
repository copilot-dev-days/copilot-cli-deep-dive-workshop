# GitHub Copilot CLI — Deep-Dive Workshop

[![Copilot CLI version](https://img.shields.io/badge/Copilot%20CLI-v1.0.39-blue?logo=github)](https://github.com/github/copilot-cli/releases/tag/v1.0.39)
[![APS version](https://img.shields.io/badge/APS-v1.2.1-blue?logo=github)](https://github.com/chris-buckley/agnostic-prompt-standard/releases/tag/v1.2.1)

A **half-day, instructor-led** workshop that takes teams from first install to advanced automation with GitHub Copilot CLI. Covers operating modes, custom instructions, MCP servers, agent skills, plugins, custom agents, hooks, context management, and more — all through hands-on exercises tested against **Copilot CLI v1.0.39**.

## What's Inside

| Component | Path | Description |
|-----------|------|-------------|
| **Workshop modules** | [`docs/workshop/`](docs/workshop/00-index.md) | 13 progressive modules (~4.5 h total) from installation to fleet command |
| **Presentation slides** | [`docs/slides/`](docs/slides/) | Marp-powered slide decks, one per module — ready for live delivery |
| **Tryout sandbox** | [`tryout/`](tryout/) | Scratch space for hands-on exercises (`.gitignored` — your work stays local) |
| **Dev Container** | [`.devcontainer/`](.devcontainer/) | One-click reproducible environment with all prerequisites pre-installed |
| **Responsible AI guide** | [`docs/responsible-ai.md`](docs/responsible-ai.md) | Detailed guidance on applying Microsoft's Responsible AI principles |

## Related Workshops

This repo is part of a family of Copilot CLI learning resources. Pick the format that fits your audience:

| Workshop | Format | Audience | Link |
|----------|--------|----------|------|
| **Tailspin Toys Workshop** | 90-min event kickstart | First exposure — uses a real app to show Copilot CLI in action | [copilot-dev-days/tailspin-toys-workshop](https://github.com/copilot-dev-days/tailspin-toys-workshop) |
| **Copilot CLI for Beginners** | Self-paced solo course | Absolute beginners learning at their own pace | [github/copilot-cli-for-beginners](https://github.com/github/copilot-cli-for-beginners) |
| **Deep-Dive Workshop** *(this repo)* | Half-day instructor-led | Teams wanting to go beyond the basics | [copilot-dev-days/copilot-cli-deep-dive-workshop](https://github.com/copilot-dev-days/copilot-cli-deep-dive-workshop) |

> **Suggested learning path:** Start with *Tailspin Toys* or *Beginners* for a quick intro, then move to this *Deep-Dive* workshop for the full treatment.

## Viewing the Slides

Slide decks for each module are in [`docs/slides/`](docs/slides/) (powered by [Marp](https://marp.app/)):

- **VS Code** — Install the [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode) extension (pre-installed in Dev Container), open any slide `.md` file, and click the preview icon (or `Marp: Open Preview to the Side`).
- **Browser (direct preview)** — `npx @marp-team/marp-cli docs/slides/02-modes.md --preview`
- **Browser (server-client)** — `npx @marp-team/marp-cli docs/slides/ --server` then visit http://localhost:8080
- **Export to PDF/PPTX** — `npx @marp-team/marp-cli docs/slides/02-modes.md -o slides.pdf`

## Getting Started

### Recommended: Open in Dev Container

This repo includes a `.devcontainer` configuration for a fully isolated workshop environment:

1. Open this repo in VS Code
2. Click **"Reopen in Container"** when prompted (or run `Dev Containers: Reopen in Container` from the command palette)
3. All prerequisites (Node.js, npm, git, gh) are pre-installed

> This is the recommended approach — it avoids polluting your host machine and ensures a consistent environment for all participants.

### Alternative: Run Directly on Host

If you prefer not to use the Dev Container, you can follow the workshop directly on your machine (requires Node.js 22+).

### Alternative: Run in Docker

To try out the workshop without affecting your local environment, use Docker:

1. **Create the tryout folder** (if it doesn't exist):
   ```bash
   mkdir -p tryout
   ```

2. **Start the container:**
   ```bash
   # Set HOST_PROJECT_PATH to your project location (required if running inside a devcontainer)
   # export HOST_PROJECT_PATH=/path/to/copilot-cli-deep-dive-workshop

   docker run -it \
     --name copilot-workshop \
     -v "${HOST_PROJECT_PATH:-$(pwd)}/tryout":/workspace \
     -w /workspace \
     ubuntu:24.04 \
     bash
   ```

3. **Inside the container**, install prerequisites:
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

**Useful Docker commands:**

| Action | Command |
|--------|---------|
| Reconnect to stopped container | `docker start -ai copilot-workshop` |
| Open parallel shell | `docker exec -it copilot-workshop bash` |
| Remove container when done | `docker rm copilot-workshop` |

## Responsible AI

This workshop uses AI-assisted development tools. We follow [Microsoft's Responsible AI principles](https://www.microsoft.com/ai/responsible-ai), which are grounded in six core values:

1. **Fairness** — AI systems should treat all people fairly
2. **Reliability & Safety** — AI systems should perform reliably and safely
3. **Privacy & Security** — AI systems should be secure and respect privacy
4. **Inclusiveness** — AI systems should empower everyone and engage people
5. **Transparency** — AI systems should be understandable
6. **Accountability** — People should be accountable for AI systems

> **Remember:** AI is a tool, not an authority. Always review, test, and validate AI-generated code before committing. You are responsible for every line in your codebase.

For detailed guidance on applying these principles in practice, see [`docs/responsible-ai.md`](docs/responsible-ai.md).
