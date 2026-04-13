# Module 1: Installing Copilot CLI

## Prerequisites

- GitHub account with active Copilot subscription (Pro, Pro+, Business, or Enterprise)
- Node.js v22+ and npm v10+ (for npm method)
- macOS, Linux, or Windows
- Terminal access

## Learning Objectives

- Install Copilot CLI using your preferred method
- Authenticate with your GitHub account
- Verify the installation is working
- Understand subscription requirements

## Concepts

> [!NOTE]
> 🎉 **Generally Available** — GitHub Copilot CLI is now at **v1.0.x**. No preview or beta opt-in is required.

### Subscription Requirements

Before installing, ensure you have one of:

- **Copilot Pro** - Individual subscription
- **Copilot Pro+** - Enhanced individual subscription
- **Copilot Business** - Organization subscription
- **Copilot Enterprise** - Enterprise subscription

For organization members, your admin must enable the Copilot CLI policy.

### Installation Methods

Copilot CLI supports multiple installation methods:

| Method | Command | Best For |
| --- | --- | --- |
| **Script** | `curl -fsSL https://gh.io/copilot-install \| bash` | Quick setup |
| npm | `npm install -g @github/copilot` | Node.js developers |
| Homebrew | `brew install copilot-cli` | macOS/Linux users |
| WinGet | `winget install GitHub.Copilot` | Windows users |
| Dev Container | Built-in | Codespaces users |

## Updating Copilot CLI

> [!NOTE]
> 💡 **Already have Copilot CLI installed?** To update to the latest version, simply run:
>
> ```bash
> copilot update
> ```
>
> `copilot update` replaces the full binary executable, not just the JS package .

### Version & Changelog Commands

Check the installed binary version without launching a full session:

```bash
copilot --binary-version
```

Inside an interactive session, use these commands:

| Command | Description |
| --- | --- |
| `/version` | Display CLI version and check for updates |
| `/changelog` | View the latest release changelog |
| `/changelog last 5` | Show the last 5 release changelogs |
| `/changelog since v1.0.3` | Show changelogs since a specific version |
| `/changelog summarize` | Get an AI-generated summary of recent changes |

## Hands-On Exercises

### Exercise 1a: Install via Script (Quick Method) - Recommended option

**Goal:** Use the automated installation script.

**Steps:**

1. Run the installation script:

 ```bash
 curl -fsSL https://gh.io/copilot-install | bash
 ```

2. Follow any prompts to add to your PATH.

3. Restart your terminal or source your profile:

 ```bash
 source ~/.bashrc # or ~/.zshrc
 ```

4. Verify:

 ```bash
 copilot --version
 ```

**Expected Outcome:**

```
GitHub Copilot CLI 1.0.7
```

> **Note:** The exact version number will reflect whichever release is current when you install. The format is the same regardless of installation method.

### Exercise 1b: Install via npm option

**Goal:** Install Copilot CLI globally using npm.

**Steps:**

1. Verify Node.js and npm versions:

 ```bash
 node --version # Should be v22.0.0 or higher
 npm --version # Should be v10.0.0 or higher
 ```

2. If Node.js needs updating, use nvm:

 ```bash
 # Install or update nvm
 curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

 # Install Node.js v22
 nvm install 22
 nvm use 22
 ```

3. Install Copilot CLI globally:

 ```bash
 npm install -g @github/copilot
 ```

4. Verify installation:

 ```bash
 copilot --version
 ```

**Expected Outcome:**

```
GitHub Copilot CLI 1.0.7
```

### Exercise 1c: Install via Homebrew (macOS/Linux) option

**Goal:** Install using Homebrew package manager.

**Steps:**

1. Ensure Homebrew is installed:

 ```bash
 brew --version
 ```

2. Install Copilot CLI:

 ```bash
 brew install copilot-cli
 ```

3. Verify installation:

 ```bash
 copilot --version
 ```

**Expected Outcome:**

```
GitHub Copilot CLI 1.0.7
```

### Exercise 1d: Windows Installation (WinGet)

**Goal:** Install Copilot CLI on Windows.

**Steps:**

1. Open PowerShell or Windows Terminal.

2. Install via WinGet:

 ```powershell
 winget install GitHub.Copilot
 ```

3. Restart your terminal.

4. Verify installation:

 ```powershell
 copilot --version
 ```

**Expected Outcome:**

```
GitHub Copilot CLI 1.0.7
```

### Exercise 2: Authenticate with GitHub

**Goal:** Connect Copilot CLI to your GitHub account.

**Steps:**

1. Start Copilot CLI:

 ```bash
 copilot
 ```

2. When prompted, press Enter to authenticate.

3. A browser window opens. Sign in to GitHub if needed.

4. Authorize the application when prompted.

5. Return to your terminal. You should see the Copilot prompt:

 ```
 >
 ```

**Expected Outcome:**
Interactive session starts with `>` prompt ready for input.

### Exercise 3: Verify Setup with First Prompt

**Goal:** Test that everything works with a simple query.

**Steps:**

1. In the interactive session, type:

 ```
 What directory am I in?
 ```

2. Copilot should use the shell tool and report your current directory.

3. When prompted to approve the tool, select:
 - **Yes** - Allow this time only
 - Or **Yes, and approve for session** - Allow for the entire session

4. Type `/help` to see available commands.

5. Type `/exit` or press `Ctrl+C` to exit.

**Expected Outcome:**
Copilot correctly identifies your working directory and shows available commands.

## Troubleshooting

### Common Issues

| Problem | Solution |
| --- | --- |
| `command not found: copilot` | Ensure npm global bin is in PATH: `npm config get prefix` |
| Node.js version too old | Use nvm to install v22+: `nvm install 22` |
| Authentication fails | Check subscription status at github.com/settings/copilot |
| Permission denied (npm) | Don't use sudo; fix npm permissions instead |
| Organization policy error | Ask your admin to enable Copilot CLI policy |
| Auto-update interfering | Disable with `--no-auto-update` or set `COPILOT_AUTO_UPDATE=false` |
| Auth fails in Docker/container | Use PAT auth: `export GH_TOKEN="ghp_..."`. See [Authentication in Containers](#authentication-in-containers-and-ci-cd) below |

### Fixing npm Permissions

If you get permission errors with npm:

```bash
# Create a directory for global packages
mkdir ~/.npm-global

# Configure npm to use it
npm config set prefix '~/.npm-global'

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH=~/.npm-global/bin:$PATH

# Reload shell
source ~/.bashrc
```

### Checking Subscription Status

1. Go to <https://github.com/settings/copilot>
2. Verify your subscription is active
3. Check that CLI access is enabled

### Authentication in Containers and CI/CD

1. Create a fine-grained PAT at <https://github.com/settings/personal-access-tokens/new>
2. Under "Permissions," add **"Copilot Requests"**
3. Export the token:

 ```bash
 export GH_TOKEN="ghp_your_token_here"
 # or
 export GITHUB_TOKEN="ghp_your_token_here"
 ```

4. Start Copilot CLI — it will authenticate automatically without a browser

### Authentication with GitHub Enterprise Cloud (Data Residency)

If your organization uses GitHub Enterprise Cloud with data residency, authenticate with the `--host` flag:

```bash
copilot login --host https://example.ghe.com
```

This stores credentials separately from github.com, allowing you to connect to your enterprise's dedicated environment.

## Summary

- ✅ Copilot CLI requires Node.js v22+ for npm installation
- ✅ Multiple installation methods: npm, Homebrew, script, WinGet
- ✅ Authentication uses GitHub OAuth in your browser
- ✅ GHEC data residency supported via `copilot login --host`
- ✅ Organization members need admin-enabled CLI policy
- ✅ Dev Containers and Codespaces include Copilot CLI by default
- ✅ Auto-updates can be disabled with `--no-auto-update`
- ✅ Use `--binary-version` to check the installed version without launching
- ✅ Use `/version` and `/changelog` inside sessions for version info

## Next Steps

→ Continue to [Module 2: Operating Modes](02-modes.md)

## References

- [Install Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)
- [Copilot CLI - GitHub Docs](https://docs.github.com/copilot/how-tos/copilot-cli)
- [Node.js Downloads](https://nodejs.org/en/download/)
- [nvm - Node Version Manager](https://github.com/nvm-sh/nvm)
