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

- **GitHub account** with Copilot access
  - Free, Pro, Pro+, Business, or Enterprise; plan usage limits apply
- **Terminal access** (macOS, Linux, or Windows)
- For npm method: **current Node.js LTS** and **npm**

---

## Installation Methods

| Method | Command | Best for |
|--------|---------|----------|
| **Script** | `curl -fsSL https://gh.io/copilot-install \| bash` | Quick setup |
| npm | `npm install -g @github/copilot` | Node.js devs |
| Homebrew | `brew install --cask copilot-cli` | macOS/Linux |
| WinGet | `winget install GitHub.Copilot` | Windows |
| Dev Container | Verify/install if absent | Configured containers |

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

For containers/CI: an existing authorized **gh login** can supply authentication, or use a **fine-grained PAT** with **"Copilot Requests"** permission. Classic PATs (`ghp_`) are **not** supported.

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

Manual mode auto-approves reads; the directory question need not prompt or use shell.

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

Selected settings inspection: `copilot config --help`, `copilot config theme`.
An unset setting prints nothing and exits with status `1`; this is not an authentication failure.
Do not dump authentication/configuration files in a shared terminal.

| Symptom | Check |
|---------|-------|
| `copilot` not found | npm global bin is on `PATH` |
| Runtime too old | Install current Node.js LTS |
| npm permission denied | Fix npm prefix; do not use `sudo` |
| Authentication fails | Subscription, org policy, and token type |
| Remote browser does not open | Use `copilot login --device-code` |

> Containers can use an existing authorized **gh login** or supported token. Fine-grained PATs need **Copilot Requests** permission; classic PATs are unsupported. Token variables: `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or `GITHUB_TOKEN`. Never log credentials.

---

## Your Turn! 🚀

Open **Module 1** in `docs/workshop/01-installation.md`

1. **Exercise 1a/b/c/d** — Install via your preferred method
2. **Exercise 2** — Authenticate with GitHub
3. **Exercise 3** — Verify first prompt and inspect help/settings; prompts depend on permissions

⏱️ You have **~12 minutes**
