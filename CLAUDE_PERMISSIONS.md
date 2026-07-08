# Claude Code Permissions

This document explains how Claude Code's permission allowlist is configured for this
repository, the rule syntax used, and how to change it.

## Where permissions live

Claude Code reads permissions from `permissions.allow` / `permissions.deny` /
`permissions.ask` arrays across four settings files. They are evaluated in precedence
order (highest wins), and a **`deny` at any level can never be overridden**:

| Scope | File | In this repo |
|-------|------|--------------|
| Managed / enterprise | `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS) | not used |
| **Project-local** (gitignored) | `.claude/settings.local.json` | **active allowlist** |
| Project (shared, committed) | `.claude/settings.json` | not present |
| User (personal defaults) | `~/.claude/settings.json` | `defaultMode`, theme, tui |

This project's allowlist is kept in **`.claude/settings.local.json`**, which is
personal and not committed. Rules that should be shared with everyone working on the
repo belong in `.claude/settings.json` instead.

## Rule syntax

Rules take the form `Tool(specifier)`. Within a scope, rules are checked
`deny` → `ask` → `allow`, first match wins.

| Pattern | Matches |
|---------|---------|
| `Bash(pwd)` | Exact command, no arguments |
| `Bash(git config *)` | `git config` followed by a space and any arguments |
| `Bash(ls:*)` | `ls` and `ls` with any arguments (prefix matcher) |
| `Read(~/**)` | Any path under the home directory |
| `Read(//Users/name/x)` | An absolute filesystem path (note the leading `//`) |
| `Read(/src/**)` | Project-relative glob (anchored at the settings file) |
| `WebFetch(domain:github.com)` | Web fetches to a domain |
| `Skill(update-config)` | A specific skill / slash command |
| `mcp__server__*` | All tools from an MCP server |

Notes:
- `cmd:*` is the **prefix matcher** — it covers the bare command and any arguments.
  `cmd *` (space + wildcard) only matches when an argument is present.
- Prefer `~` over absolute home paths (`/Users/<you>/...`) so rules stay portable.
- Process wrappers (`timeout`, `time`, `nice`, `nohup`, `stdbuf`) are stripped before
  matching, so wrap the underlying command in the rule.
- The deprecated top-level `allowedTools` field is no longer recognized — use
  `permissions.allow`.

## Managing rules

- Run **`/permissions`** inside Claude Code to view every active rule (and which file
  it came from) and to add/remove rules through the UI.
- Answering **"Yes, don't ask again"** on a permission prompt appends a rule to
  `.claude/settings.local.json` automatically.
- You can also edit the JSON files by hand; keep them valid with:
  ```bash
  python3 -m json.tool .claude/settings.local.json
  ```

## Current project allowlist

The rules currently in `.claude/settings.local.json`, grouped by purpose:

**Setup / test scripts**
- `Bash(bash -n setup.sh)`, `Bash(bash -n test.sh)` — syntax-check the scripts
- `Bash(./test.sh)` — run the test suite

**Shell config verification**
- `Bash(timeout 8 zsh -xc 'source ~/.zshrc')`
- `Bash(zsh -c 'source ~/.zshrc')`
- `Bash(echo "SOURCE EXIT: $?")`
- `Read(~/**)` — read files under the home directory

**Git / GPG**
- `Bash(git config *)`, `Bash(git rm *)`
- `Bash(git status:*)`, `Bash(git log:*)`, `Bash(git diff:*)`
- `Bash(gpg --list-secret-keys --keyid-format=long)`
- `Bash(echo "commit.gpgsign is now: $\(git config --global commit.gpgsign\)")`

**Homebrew**
- `Bash(brew info *)`

**Read-only shell utilities**
- `Bash(ls:*)`, `Bash(pwd)`, `Bash(cat:*)`, `Bash(head:*)`, `Bash(tail:*)`, `Bash(grep:*)`

**Tooling**
- `Skill(update-config)`
- `Bash(python3 -m json.tool .claude/settings.local.json)`


# Approval Categories

### ✅ Auto-Approve (Safe)
- `ls`, `pwd`, `cat`, `head`, `tail`
- `grep`, `find`
- `git status`, `git log`, `git diff`, `git lp`
- `npm list`, `pip list`

### ⚠️ Review Carefully
- `git commit` (check commit message)
- `git checkout` (verify branch name)
- `npm install <package>` (verify package name is correct)
- File writes inside `src/` (verify path and content)

### ❌ Always Deny
- `rm -rf` anywhere
- `git push --force`
- `curl` or `wget` (unless explicitly requested and target verified)
- Any command operating on `~/.ssh/`, `~/.aws/`, `/etc/`
- `chmod`, `chown` without clear justification

## Approval Process
1. Read the FULL command before approving
2. Check file paths — must be inside project directory
3. Verify the command matches Claude Code's description
4. If unsure, DENY and ask Claude Code to explain
5. Never use "Approve Always" for write operations

## --dangerously-skip-permissions
- ❌ NEVER use on local development machines
- ✅ ONLY use in Docker containers or CI/CD pipelines
- Document every exception in team chat


> Keep this list in sync with `.claude/settings.local.json` when rules change.
