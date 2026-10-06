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

# Module 1: Installing Copilot CLI

### GitHub Copilot CLI Workshop

---

## Prerequisites

- **GitHub account** with active Copilot subscription
  - Pro, Pro+, Business, or Enterprise
- **Terminal access** (macOS, Linux, or Windows)
- For npm method: **current Node.js LTS** and **npm**

---

## Installation Methods

| Method | Command | Best for |
|--------|---------|----------|
| **Script** | `curl -fsSL https://gh.io/copilot-install \| bash` | Quick setup |
| npm | `npm install -g @github/copilot` | Node.js devs |
| Homebrew | `brew install --cask copilot-cli` | macOS |
| WinGet | `winget install GitHub.Copilot` | Windows |
| Dev Container | Built-in | Codespaces |

> 💡 Already installed? `copilot update` checks for and installs updates

---

## Authentication

```bash
# Start Copilot — OAuth flow begins
copilot

# Force a specific OAuth mode
copilot login --web-flow      # browser (default on desktops)
copilot login --device-code   # default when remote/headless

# Or use a token (CI/CD, containers)
export COPILOT_GITHUB_TOKEN="github_pat_your_token"
copilot
```

For containers/CI: create a **fine-grained PAT** with **"Copilot Requests"** permission — classic PATs (`ghp_`) are **not** supported

---

## Enterprise Cloud & Signing Out

**GHEC data residency** — authenticate against your enterprise host:

```bash
copilot login --host https://example.ghe.com
```

Credentials are stored separately from github.com, so you connect to your
enterprise's dedicated environment.

**Signing out:** when you signed in via the **gh CLI, a PAT, an API key, or an
env var**, `/logout` displays a warning — that credential source must be
removed separately.

---

## Shell Completion

Tab completion for `copilot` subcommands and flags:

```bash
# Bash (current session)
source <(copilot completion bash)

# Bash (persistent, Linux)
copilot completion bash | sudo tee /etc/bash_completion.d/copilot

# Zsh — write to a directory on your $fpath, then restart the shell
copilot completion zsh > "${fpath[1]}/_copilot"

# Fish
copilot completion fish > ~/.config/fish/completions/copilot.fish
```

---

## Verify Your Setup

```bash
# Check version
copilot --version

# Start interactive session
copilot

# Inside session — test it works
> What directory am I in?

# See available commands
> /help

# Exit
> /exit
```

---

## Updates & Troubleshooting

```bash
copilot --version              # installed binary
copilot version                # check for updates
copilot update stable          # install update
copilot update prerelease      # alternate channel
/version                       # check inside a session
copilot --no-auto-update       # disable for this run
COPILOT_AUTO_UPDATE=false copilot
```

| Symptom | Check |
|---------|-------|
| `copilot` not found | npm global bin is on `PATH` |
| Runtime too old | Install current Node.js LTS |
| npm permission denied | Fix npm prefix; do not use `sudo` |
| Authentication fails | Subscription, org policy, and token type |
| Remote browser does not open | Use `copilot login --device-code` |

> Containers need a fine-grained PAT with **Copilot Requests** permission; classic PATs are unsupported. Token alternatives: `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or `GITHUB_TOKEN`.

---

## Your Turn! 🚀

Open **Module 1** in `docs/workshop/01-installation.md`

1. **Exercise 1a/b/c/d** — Install via your preferred method
2. **Exercise 2** — Authenticate with GitHub
3. **Exercise 3** — Verify with your first prompt

⏱️ You have **~12 minutes**
