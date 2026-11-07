# Module 10: Context Management

## Prerequisites

- Completed Modules 1-9
- Understanding of LLM token limits
- Active Copilot CLI session experience

## Learning Objectives

- Understand how context works in Copilot CLI
- Use `/context` and `/usage` to monitor token usage and session stats
- Use `/compact` to compress session history
- Use `@path/to/file` to include specific files in prompts
- Optimize context for better responses
- Manage large codebases efficiently

## Concepts

### What is Context?

Context is everything Copilot "remembers" during a session:

```
┌────────────────────────────────────────────────┐
│ Context Window │
├────────────────────────────────────────────────┤
│ System Instructions (AGENTS.md, etc.) │
├────────────────────────────────────────────────┤
│ Conversation History (prompts + responses) │
├────────────────────────────────────────────────┤
│ File Contents (read during session) │
├────────────────────────────────────────────────┤
│ Tool Results (command outputs, etc.) │
├────────────────────────────────────────────────┤
│ Available Space for Response │
└────────────────────────────────────────────────┘
```

### Token Limits

> [!NOTE]
> Use `/model` to select a model and `/context` to see context window usage. Run `/model` or `copilot help config` to see the current model list. Model availability may vary by Copilot subscription tier.

### Context Window Tier

You can select a context window tier for tiered-pricing models using the `--context` flag or the `contextTier` setting:

```bash
# Use long context mode for a session
copilot --context long_context

# Or set "contextTier": "long_context" in ~/.copilot/settings.json
```

Available tiers: `"default"` and `"long_context"`. The `/model` command shows a context tier picker for eligible models.

> [!WARNING]
> User settings belong in `~/.copilot/settings.json` — you can also edit them with `/settings`. The `~/.copilot/config.json` file next to it is managed automatically and stores your authentication token. Never print, paste, or share its contents, especially while screen-sharing.

### Including Files with `@`

You can include a specific file's contents in your prompt using `@` followed by the relative path:

```
Explain @config/ci/ci-required-checks.yml
```
```
Fix the bug in @src/app.js
```

When you start typing a file path after `@`, matching paths are displayed below the prompt box. Use the arrow keys to select a path and press Tab to complete it.

#### Expanded `@` Paths

> `@` file mentions support paths outside the project:

| Syntax | Example | Description |
| --- | --- | --- |
| `@relative/path` | `@src/app.js` | Relative to project root (original) |
| `@/absolute/path` | `@/usr/local/config.yaml` | Absolute path |
| `@~/path` | `@~/notes/ideas.md` | Home directory path |
| `@../path` | `@../shared-lib/utils.js` | Relative parent path |

```
Review @~/company-standards/coding-guidelines.md and apply to this project
```

This is especially useful for referencing shared configuration, documentation, or libraries outside the current repository.

File mentions do not grant access. Outside the allowed directories, approve the read interactively or add the specific directory with `/add-dir` (or `--add-dir` at launch). An unattended `-p` request can be denied when no one is available to approve it.

### Referencing GitHub Issues, PRs & Discussions with `#`

Similar to `@` for files, you can type `#` followed by a number to pull a GitHub issue, pull request, or discussion directly into context:

```
Summarize the discussion in #42
```
```
What's the status of #150 and are there related PRs?
```

When you type `#`, matching issues and PRs from the current repository are displayed below the prompt box. Use the arrow keys to select and press Tab to complete.

### Auto-Compaction

Background compaction starts at approximately **80%** capacity. If usage reaches approximately **95%** before it finishes, the CLI can pause to wait. Thresholds depend on configuration; compaction summarizes, not securely erases, history.

### Routing, Retrieval, and Large Results

With model `auto`, `--auto-tier` selects an advertised profile such as `efficiency`, `balance`, or `intelligence`; `COPILOT_AUTO_TIER` and `autoTier` also configure routing. Actual model/catalog availability depends on your account. `--dynamic-retrieval skills=on|off` persists skill-retrieval preference, so not every skill's metadata necessarily enters the parent context.

Large tool results can spill to a temporary file with a preview/path rather than enter context in full. `COPILOT_LARGE_OUTPUT_THRESHOLD_BYTES` controls the threshold; increasing it leaves less conversation headroom. File previews/summaries still cost context, and spilled files may hold sensitive data.

## Hands-On Exercises

### Exercise 1: Monitor Context Usage

**Goal:** Learn to track context consumption.

**Steps:**

1. Start a fresh session:
 ```bash
 copilot
 ```

2. Check initial context:
 ```
 /context
 ```

 Before the first message, `/context` can report that context information is not yet available. Send a short message, then run `/context` again to see the visual overview of your current token usage.

3. Check session stats with `/usage`:
 ```
 /usage
 ```

 You'll see:
 - AI credits used in the current session (premium requests are shown instead only on the legacy billing platform)
 - Session duration
 - Total lines of code edited
 - Token usage breakdown per model

4. Have a conversation that uses context:
 ```
 Explain the concept of dependency injection
 ```

5. Check context again:
 ```
 /context
 ```

6. Read some files (try using `@` to include a file):
 ```
 Show me the contents of package.json
 ```

7. Check how file reading affects context:
 ```
 /context
 ```

8. Continue building context:
 ```
 Now explain how TypeScript interfaces work
 ```
 ```
 Give me examples of generics in TypeScript
 ```

9. Monitor the growth:
 ```
 /context
 ```

**Expected Outcome:**
You understand how different actions consume context.

### Exercise 2: Manual Compaction

**Goal:** Use `/compact` to compress session history.

**Steps:**

1. Continue from Exercise 1 or start a session with significant history.

2. Check current context:
 ```
 /context
 ```

3. Run manual compaction:
 ```
 /compact
 ```

4. Check context after compaction:
 ```
 /context
 ```

5. Notice:
 - Token count decreased
 - Core information preserved
 - Detailed conversation history summarized

6. Verify context was preserved:
 ```
 What were we discussing earlier?
 ```

 Copilot should remember the key topics.

**Expected Outcome:**
Context reduced while preserving important information.

### Exercise 3: Context-Efficient Prompting

**Goal:** Learn to use context efficiently.

**Steps:**

1. **Inefficient approach** (uses lots of context):
 ```bash
 copilot
 ```
 ```
 Read all the files in the src directory and tell me what each one does
 ```

 This can cause broad reading and high context use, but tool selection is model-dependent and large output may spill. Inspect actual tool calls rather than assuming every file is loaded.

2. Check context:
 ```
 /context
 ```

3. Start a new session with efficient approach:
 ```bash
 copilot
 ```
 ```
 List the files in src directory
 ```

 Then selectively:
 ```
 Show me just the main entry point file
 ```

4. Compare context usage:
 ```
 /context
 ```

 Compare actual readings and tool calls, not just prompt length. A selective request does not guarantee a lower token total: model/tool overhead, permission retries, and the requested files can outweigh savings in a small project.

5. **Best practices for efficient context:**
 - Load files on-demand, not all at once
 - Use specific queries instead of broad exploration
 - Compact regularly during long sessions
 - Clear context when switching topics

**Expected Outcome:**
You can manage context efficiently.

### Exercise 4: Working with Large Codebases

**Goal:** Strategies for large projects without exhausting context.

**Steps:**

1. **Use the Explore agent for overview:**
 ```bash
 copilot
 ```
 ```
 Give me an overview of this codebase structure
 ```

 Copilot may delegate to Explore, which has separate context and reduces parent-context pressure. Its returned summary still enters parent context and consumes usage. Inspect `/tasks` and `/context`; GitHub tool availability depends on the loaded inventory.

2. **Focus on specific areas:**
 ```
 I want to understand the authentication flow. What files should I look at?
 ```

3. **Read selectively:**
 ```
 Show me only the auth middleware file
 ```

4. **Use grep instead of reading entire files:**
 ```
 Search for "authenticate" in the codebase
 ```

5. **Clear when switching tasks:**
 ```
 /clear
 ```
 ```
 Now let's look at the database layer
 ```

6. **Leverage file-specific questions:**
 ```
 In src/db/connection.ts, how is the connection pool configured?
 ```

 Substitute an existing database file from your project for `src/db/connection.ts`. A focused prompt encourages selective reading; inspect actual tools to see what it reads.

**Expected Outcome:**
Large codebases manageable without hitting limits.

### Exercise 5: Context Window Optimization

**Goal:** Configure for optimal context usage.

**Steps:**

1. **Choose the right model:**
 ```bash
 copilot
 ```
 ```
 /model
 ```

 Select a model with larger context if available.

2. **Use specific instructions:**

 The filenames and function names below are illustrative. Substitute existing files and symbols in your project for `payment.ts`, `auth.ts`, and their example functions.

 Instead of:
 ```
 Tell me everything about this file
 ```

 Use:
 ```
 What does the processPayment function in payment.ts do?
 ```

3. **Batch related questions:**

 Instead of:
 ```
 What does function A do?
 What does function B do?
 What does function C do?
 ```

 Use:
 ```
 Explain functions A, B, and C in auth.ts
 ```

4. **Use references instead of copies:**
 ```
 Look at the PaymentService class - don't repeat the code, just explain the flow
 ```

5. **Summarize when appropriate:**
 ```
 Summarize what we've learned so far in 3 bullet points
 ```

 Then clear and continue with the summary as context.

**Expected Outcome:**
Maximum utility from available context.

### Exercise 6: Understanding Auto-Compaction

**Goal:** See auto-compaction in action.

> [!NOTE]
> Keep this practice bounded: request short answers and stop after the prompts below. Do not deliberately exhaust a large context window or test billing limits. If auto-compaction does not trigger, record it as not observed; use Exercise 2 to demonstrate compaction and continuity safely.

**Steps:**

1. Start a session for bounded observation:
 ```bash
 copilot
 ```

2. Try these prompts, appending “Keep the answer under 150 words” to each:
 ```
 Write a detailed explanation of microservices architecture with examples
 ```
 ```
 Now explain event-driven architecture in detail
 ```
 ```
 Compare REST vs GraphQL with code examples for both
 ```

3. Try one final bounded prompt, then stop whether or not auto-compaction triggers:
 ```
 Explain the CQRS pattern with implementation details
 ```

4. Watch for the auto-compaction message.

5. After compaction:
 ```
 /context
 ```

6. Verify continuity:
 ```
 What architectural patterns have we discussed?
 ```

**Expected Outcome:**
If auto-compaction triggers, check whether session continuity is preserved. Otherwise, record it as not observed rather than forcing context exhaustion.

### Exercise 7: Context-Aware Workflow

**Goal:** Build a workflow that manages context intelligently.

**Steps:**

1. **Phase 1: Discovery (low context)**
 ```bash
 copilot
 ```
 ```
 What are the main components of this application?
 ```

 Copilot may delegate to the Explore agent, keeping main context clean.

2. **Phase 2: Focus (targeted context)**
 ```
 /clear
 ```
 ```
 Let's focus on the API layer. Show me the main router file.
 ```

3. **Phase 3: Deep dive (specific context)**
 ```
 I want to add a new endpoint. Show me an existing endpoint as a template.
 ```

4. **Phase 4: Implementation (working context)**
 ```
 Create a new endpoint for user preferences based on that pattern
 ```

5. **Phase 5: Cleanup (compact)**
 ```
 /compact
 ```
 ```
 Now let's write tests for the new endpoint
 ```

6. **Monitor throughout:**
 After each phase:
 ```
 /context
 ```

**Expected Outcome:**
Systematic workflow keeps context under control.

## Context Commands Reference

### Slash Commands

| Command | Description |
|---------|-------------|
| `/context` | Show visual overview of token usage |
| `/usage` | Show session stats (requests, duration, lines edited, token usage per model) |
| `/compact` | Compress session history |
| `/clear` | Abandon active conversation and start fresh; not transcript/memory/log erasure |
| `/new` | Start new conversation (old session stays backgrounded) |
| `/cwd` | Change working directory (affects context scope) |
| `/add-dir` | Add file access and trust that root's skills/agents; relative paths resolve from the current working directory; inspect grants with `/list-dirs` |
| `@path/to/file` | Include specific file contents in your prompt |
| `#<number>` | Include a GitHub issue, PR, or discussion in your prompt |

### Context Categories

| Category | Description | Impact |
|----------|-------------|--------|
| System | Instructions, agents | Fixed overhead |
| History | Conversation turns | Grows with conversation |
| Files | Read file contents | Can be large |
| Tools | Command outputs | Varies by tool |
| Response | Space for answer | Reduces with context |

### Optimization Strategies

| Strategy | When to Use |
|----------|-------------|
| `/clear` | Abandoning session entirely |
| `/new` | Starting new topic but keeping old session accessible |
| `/compact` | Long session, need to continue |
| Explore agent | Separate context reduces parent pressure; returned summaries and usage still count |
| `@path/to/file` | Include specific files without broad reads |
| `#<number>` | Pull issue/PR/discussion context directly |
| Selective reading | Large files, specific needs |
| Summarization | Preserve knowledge, reduce tokens |

## Context Usage Tips

### Do ✅

- Check `/context` and `/usage` regularly
- Use `@path/to/file` to include specific files
- Use `#<number>` to reference GitHub issues, PRs, or discussions
- Compact before running out
- Clear when switching topics
- Use targeted queries
- Leverage the Explore agent for overview

### Don't ❌

- Read entire codebase at once
- Ask broad questions in large projects
- Let auto-compaction be your only strategy
- Repeat information already in context
- Ignore context warnings

## Summary

- ✅ Context is limited - monitor with `/context` and `/usage`
- ✅ `/compact` compresses while preserving key info
- ✅ `/clear` abandons the session; `/new` starts fresh while keeping the old session backgrounded
- ✅ Background compaction begins around 80%; near 95% the CLI may wait for it to finish
- ✅ Use `@path/to/file` to include specific files in prompts
- ✅ Use `#<number>` to pull GitHub issues, PRs, or discussions into context
- ✅ Efficient prompting extends useful session length
- ✅ Explore reduces parent-context pressure, not context/usage cost to zero
- ✅ `@` file mentions support absolute, home, and parent paths
- ✅ `--context` flag and the `contextTier` setting in `~/.copilot/settings.json` select the context window tier for eligible models
- ✅ Reasoning token usage shown in per-model breakdown via `/usage`

## Next Steps

→ Continue to [Module 11: Session Management](11-sessions.md)

## References

- [Managing context for GitHub Copilot - GitHub Docs](https://docs.github.com/en/copilot/concepts/prompting-and-context/context-management)
