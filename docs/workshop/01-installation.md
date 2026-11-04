# Module 1: Installing Copilot CLI

## Prerequisites

- GitHub account with Copilot access (Free, Pro, Pro+, Business, or Enterprise)
- Current Node.js LTS and npm (for npm method)
- macOS, Linux, or Windows
- Terminal access

## Learning Objectives

- Install Copilot CLI using your preferred method
- Authenticate with your GitHub account
- Verify the installation is working
- Understand subscription requirements

## Concepts

### Subscription Requirements

Before installing, ensure you have one of:

- **Copilot Free** - Free plan, subject to its usage limits
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
| Homebrew | `brew install --cask copilot-cli` | macOS and Linux users |
| WinGet | `winget install GitHub.Copilot` | Windows users |
| Dev Container | Check `copilot --help`; install if absent | Configured containers/Codespaces |

## Updating Copilot CLI

> [!NOTE]
> 💡 **Already have Copilot CLI installed?** Run `copilot update` to check for and install updates. `copilot update` updates the full binary executable.

### Version and Update Commands

Check the installed binary version without launching a full session:

```bash
copilot --version
```

To check for updates without installing them:

```bash
copilot version
```

Inside an interactive session, use `/version` to display version information and check for updates.

`copilot update` follows the stable channel. To choose a channel explicitly:

```bash
copilot update stable
copilot update prerelease
```

### Shell Completion

Enable tab completion for `copilot` subcommands and flags:

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
GitHub Copilot CLI <version>.
Run 'copilot update' to check for updates.
```

> **Note:** Check that the command identifies GitHub Copilot CLI; diagnostic output and hints can vary by installation.

### Exercise 1b: Install via npm option

**Goal:** Install Copilot CLI globally using npm.

**Steps:**

1. Verify Node.js and npm:

 ```bash
 node --version # Use the current Node.js LTS
 npm --version # Use the npm bundled with Node.js LTS
 ```

2. If Node.js needs updating, use nvm:

 ```bash
 # Install or update nvm
 curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash

 # Install and use Node.js LTS
 nvm install --lts
 nvm use --lts
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
GitHub Copilot CLI <version>.
Run 'copilot update' to check for updates.
```

> **Note:** The update hint line may or may not appear; the version line is the part to check.

### Exercise 1c: Install via Homebrew (macOS or Linux) option

**Goal:** Install using Homebrew package manager.

**Steps:**

1. Ensure Homebrew is installed:

 ```bash
 brew --version
 ```

2. Install Copilot CLI:

 ```bash
 brew install --cask copilot-cli
 ```

 > **Note:** Official installation supports Homebrew on macOS and Linux. Install `copilot-cli`, not the unrelated `copilot` package.

3. Verify installation:

 ```bash
 copilot --version
 ```

**Expected Outcome:**

```
GitHub Copilot CLI <version>.
Run 'copilot update' to check for updates.
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
GitHub Copilot CLI <version>.
Run 'copilot update' to check for updates.
```

### Exercise 2: Authenticate with GitHub

**Goal:** Connect Copilot CLI to your GitHub account.

**Steps:**

1. Start Copilot CLI:

 ```bash
 copilot
 ```

2. When prompted, press Enter to authenticate.

3. Copilot starts the OAuth flow. On a local desktop it opens your browser and captures the result on a loopback callback. In remote or headless environments (SSH, Codespaces, dev containers, CI, headless Linux) it uses the device code flow instead. Force a mode with `copilot login --web-flow` or `copilot login --device-code`.

4. Sign in to GitHub if needed, and authorize the application when prompted.

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

2. Copilot can use session information or a read tool/shell command to report your directory; tool selection is not guaranteed.

3. Reads are auto-approved in manual mode. If another request prompts, inspect its displayed rule and select:
 - **Yes** - Allow this time only
 - Or **Yes, and approve for session** - Allow for the entire session

4. Type `/help` to see available commands. From a separate shell, inspect settings without dumping credential state:
 ```bash
 copilot config --help
 copilot config theme
 ```

 An unset setting prints nothing and exits with status `1`; this is not an authentication failure.

5. Type `/exit` or press `Ctrl+C` to exit.

**Expected Outcome:**
Copilot correctly identifies your working directory and shows available commands.

## Troubleshooting

### Common Issues

| Problem | Solution |
| --- | --- |
| `command not found: copilot` | Ensure npm global bin is in PATH: `npm config get prefix` |
| Node.js runtime too old | Use nvm to install Node.js LTS: `nvm install --lts` |
| Authentication fails | Check subscription status at github.com/settings/copilot |
| Permission denied (npm) | Don't use sudo; fix npm permissions instead |
| Organization policy error | Ask your admin to enable Copilot CLI policy |
| `/logout` shows warning | When signed in via gh CLI, PAT, API key, or env var, `/logout` displays a warning explaining that the credential source must be removed separately |
| Auto-update interfering | Disable with `--no-auto-update` or set `COPILOT_AUTO_UPDATE=false` |
| Auth fails in Docker/container | Check an existing authorized `gh` login, or use fine-grained PAT auth: `export GH_TOKEN="github_pat_..."`. See [Authentication in Containers](#authentication-in-containers-and-cicd) below |
| Classic PAT rejected | Classic personal access tokens (`ghp_`) are not supported. Use a fine-grained PAT with the "Copilot Requests" permission |
| Browser never opens on a remote host | Remote and headless environments use the device code flow. Run `copilot login --web-flow` to force the browser flow, or `copilot login --device-code` to request the device code explicitly |

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

An existing authorized GitHub CLI (`gh`) login can supply authentication in a container; a PAT is not required merely because the CLI runs in Docker. Transfer credentials only through a secure local channel, never through logs or committed files. To use a fine-grained PAT instead:

1. Create a fine-grained PAT at <https://github.com/settings/personal-access-tokens/new>
2. Under "Permissions," add **"Copilot Requests"**
3. Export the token:

 ```bash
 export COPILOT_GITHUB_TOKEN="github_pat_your_token_here"
 # or
 export GH_TOKEN="github_pat_your_token_here"
 # or
 export GITHUB_TOKEN="github_pat_your_token_here"
 ```

 > **Note:** Supported token types include fine-grained PATs (with "Copilot Requests" permission), OAuth tokens from the GitHub Copilot CLI app, and OAuth tokens from the GitHub CLI (`gh`) app. **Classic personal access tokens are not supported.**

4. Start Copilot CLI — it will authenticate automatically without a browser

### Authentication with GitHub Enterprise Cloud (Data Residency)

If your organization uses GitHub Enterprise Cloud with data residency, authenticate with the `--host` flag:

```bash
copilot login --host https://example.ghe.com
```

This stores credentials separately from github.com, allowing you to connect to your enterprise's dedicated environment.

## Summary

- ✅ Copilot CLI requires current Node.js LTS for npm installation
- ✅ Multiple installation methods: script, npm, Homebrew (macOS/Linux), WinGet
- ✅ Authentication uses GitHub OAuth: browser flow on local desktops, device code flow in remote and headless environments
- ✅ `copilot login --web-flow` and `copilot login --device-code` force a specific OAuth mode
- ✅ GHEC data residency supported via `copilot login --host`
- ✅ Organization members need admin-enabled CLI policy
- ✅ Check container/Codespaces setup; not every environment includes the CLI
- ✅ Auto-updates can be disabled with `--no-auto-update`
- ✅ Use `--version`, `copilot version`, and `/version` to inspect the installed version
- ✅ `copilot update` takes a `stable` (default) or `prerelease` channel argument
- ✅ `/logout` warns when credential source is external (gh CLI, PAT, env var)
- ✅ Shell completion available for bash, zsh, and fish via `copilot completion`
- ✅ Classic PATs are not supported — use fine-grained PATs with "Copilot Requests" permission

## Next Steps

→ Continue to [Module 2: Operating Modes](02-modes.md)

## References

- [Install Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli)
- [Copilot CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Node.js Downloads](https://nodejs.org/en/download/)
- [nvm - Node Version Manager](https://github.com/nvm-sh/nvm)
