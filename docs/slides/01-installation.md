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
- For npm method: **Node.js v22+** and **npm v10+**

---

## Installation Methods

| Method | Command | Best for |
|--------|---------|----------|
| **Script** | `curl -fsSL https://gh.io/copilot-install \| bash` | Quick setup |
| npm | `npm install -g @github/copilot` | Node.js devs |
| Homebrew | `brew install copilot-cli` | macOS/Linux |
| WinGet | `winget install GitHub.Copilot` | Windows |
| Dev Container | Built-in | Codespaces |

> 🎉 Copilot CLI is **Generally Available** (v1.0.x)
> 💡 Already installed? `copilot update` — now replaces the full binary

---

## Authentication

```bash
# Start Copilot — browser opens for OAuth
copilot

# Or use a token (CI/CD, containers)
export GITHUB_TOKEN="ghp_your_token"
copilot
```

For containers/CI: create a **fine-grained PAT** with **"Copilot Requests"** permission

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

## Version & Changelog (v1.0.3+)

```bash
# Check binary version without launching
copilot --binary-version

# Inside a session:
/version        # Version + update check
/changelog      # Latest release notes
/changelog last 5            # Last 5 releases
/changelog since v1.0.3      # Since a version
/changelog summarize         # AI summary
```

---

## Your Turn! 🚀

Open **Module 1** in `docs/workshop/01-installation.md`

1. **Exercise 1a/b/c/d** — Install via your preferred method
2. **Exercise 2** — Authenticate with GitHub
3. **Exercise 3** — Verify with your first prompt

⏱️ You have **~12 minutes**

