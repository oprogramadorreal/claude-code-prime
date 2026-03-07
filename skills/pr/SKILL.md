---
description: This skill creates or updates pull requests (GitHub) and merge requests (GitLab) with structured descriptions — Summary, Changes, Rationale, Test plan. Detects platform, verifies CLI, auto-pushes branch.
disable-model-invocation: true
---

# Pull Request / Merge Request Creator

Create or update a PR (GitHub) or MR (GitLab) with a structured description generated from the branch diff.

## Step 1: Pre-flight

### Multi-repo workspace detection

If the current directory is a multi-repo workspace (no `.git/` at root, 2+ child directories containing a `.git` *directory* — not `.git` files, which indicate submodules):
- Ask the user which repo to target via `AskUserQuestion` (header "Target repo", options: list detected repo directories)
- `cd` into the selected repo for all subsequent steps

### Branch validation

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
```

If `CURRENT_BRANCH` is `main`, `master`, or `HEAD` (detached):
- Inform the user: "You are on `<branch>` — switch to a feature branch before creating a PR/MR."
- Stop

## Step 2: Detect Platform

Determine whether the repo is hosted on GitHub or GitLab:

1. Check the `origin` remote URL: `git remote get-url origin`
   - Contains `gitlab` → **GitLab**
   - Contains `github` → **GitHub**
2. If neither matches, check for CI files:
   - `.gitlab-ci.yml` exists → **GitLab**
   - `.github/` directory exists → **GitHub**
3. If the remote URL and CI files give conflicting signals, trust the remote URL (it's authoritative)
4. If platform is still unknown → ask the user via `AskUserQuestion` (header "Platform", options: "GitHub" / "GitLab")

Store the result as `<platform>`.

## Step 3: Verify CLI

### Check CLI availability

- **GitHub**: Run `gh --version`
- **GitLab**: Run `glab --version`

If the CLI is not found:
- Ask the user via `AskUserQuestion`:
  - Header: "Install CLI"
  - Options: "Install <gh/glab>" / "Skip — I'll create manually"
- If **Install**:
  - `gh`: Try `conda install -y -c conda-forge gh` → fallback to OS package manager (`apt`, `brew`, etc.)
  - `glab`: Try `pip install glab` → fallback to OS package manager
  - Verify installation: re-run `<cli> --version`
  - If installation fails: inform the user, provide the manual install URL, and stop
- If **Skip**: provide the browser URL for manual PR/MR creation and stop

### Check authentication

- **GitHub**: Run `gh auth status`
- **GitLab**: Run `glab auth status`

If not authenticated:
- Inform the user and provide the auth command:
  - GitHub: `gh auth login`
  - GitLab: `glab auth login`
- Stop

## Step 4: Determine Base Branch

Get the repository's default branch:

```bash
DEFAULT_BRANCH=$(git remote show origin | sed -n 's/  HEAD branch: //p')
```

Store the result as `<base>` (typically `main` or `master`).

Fetch the latest state of the base branch:

```bash
git fetch origin "$DEFAULT_BRANCH"
```

Verify commits exist ahead of the base branch:

```bash
git log --oneline "origin/$DEFAULT_BRANCH..HEAD"
```

If no commits ahead: inform the user ("No commits ahead of `<base>` — nothing to create a PR/MR for.") and stop.

## Step 5: Check for Existing PR/MR

Check whether a PR/MR already exists for the current branch:

- **GitHub**: `gh pr view --json url,title,body,state`
- **GitLab**: `glab mr view --output json`

Handle results:
- **Exists and open** → ask the user via `AskUserQuestion`:
  - Header: "Existing PR"
  - Options: "Update title and description" / "Open in browser" / "Cancel"
  - If **Update**: proceed to Step 6 (will update instead of create in Step 8)
  - If **Open in browser**: open the URL and stop
  - If **Cancel**: stop
- **Exists but closed/merged** → inform the user, ask via `AskUserQuestion`:
  - Header: "Closed PR"
  - Options: "Create new PR/MR" / "Cancel"
- **Does not exist** → proceed to create

## Step 6: Push Branch

Ensure the branch is pushed to the remote:

```bash
# Check if upstream is configured
UPSTREAM=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
```

- **No upstream**: `git push -u origin "$CURRENT_BRANCH"`
- **Has upstream, unpushed commits** (check with `git status`): `git push`
- **Already up to date**: proceed silently

If push fails: report the error and stop.

## Step 7: Analyze Changes and Generate Description

Read the PR/MR description format from: `$CLAUDE_PLUGIN_ROOT/skills/pr/references/pr-template.md`

Gather change data:

```bash
# Commit list
git log --oneline "origin/$DEFAULT_BRANCH..HEAD"

# File change summary
git diff --stat "origin/$DEFAULT_BRANCH..HEAD"

# Full diff (for understanding intent)
git diff "origin/$DEFAULT_BRANCH..HEAD"

# File list
git diff --name-only "origin/$DEFAULT_BRANCH..HEAD"
```

Generate the PR/MR title and body following the template:
- **Title**: Conventional commit format, under 72 chars, imperative mood
- **Summary**: 2-4 sentences on what and why, with bullet list of key aspects if multi-dimensional
- **Changes**: Bold file paths with descriptions, capped at 20 entries
- **Rationale**: Only if non-obvious trade-offs exist
- **Test Plan**: Verification steps (commands, manual checks)

For large diffs (many files): use `--stat` output for the Changes section and read the full diff selectively for the most significant files.

## Step 8: Create or Update PR/MR

Write the generated body to a temp file:

```bash
TMPFILE=$(mktemp /tmp/pr-body-XXXXXX.md)
```

### Create (new PR/MR)

- **GitHub**:
  ```bash
  gh pr create --title "<title>" --body-file "$TMPFILE" --base "$DEFAULT_BRANCH"
  ```
- **GitLab**:
  ```bash
  glab mr create --title "<title>" --description "$(cat "$TMPFILE")" --target-branch "$DEFAULT_BRANCH"
  ```

### Update (existing PR/MR)

- **GitHub**:
  ```bash
  gh pr edit --title "<title>" --body-file "$TMPFILE"
  ```
- **GitLab**:
  ```bash
  glab mr update --title "<title>" --description "$(cat "$TMPFILE")"
  ```

Clean up:

```bash
rm -f "$TMPFILE"
```

## Step 9: Report

Display a structured summary:

```
## Pull Request

- Branch: `<current-branch>` → `<base>`
- Platform: GitHub / GitLab
- Action: Created / Updated
- URL: [link]
- Files changed: [N]
- Commits: [N]
```

If the PR/MR was just created (not updated), suggest running `/optimus:code-review` to review the changes before merging.

## Important

- Never modify source code — this skill only creates/updates PR/MR descriptions
- If the CLI is unavailable and the user declines installation, provide the URL for manual creation
- Always clean up temp files after PR/MR creation
- Respect existing PR/MR state — ask before overwriting
