# optimus:pr

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that creates or updates pull requests (GitHub) and merge requests (GitLab) with structured descriptions — Summary, Changes, Rationale, Test plan.

Well-structured PR descriptions help both human reviewers and AI tools understand what changed and why. This skill analyzes the branch diff, generates a description following a consistent template, and handles platform detection, CLI verification, and branch pushing automatically.

## Features

- Creates PRs (GitHub) and MRs (GitLab) with structured descriptions
- Detects hosting platform from remote URL and CI files
- Verifies and optionally installs `gh` or `glab` CLI
- Updates existing PRs/MRs — refreshes title and description
- Auto-pushes the branch before creating the PR/MR
- Supports multi-repo workspaces — targets specific repos
- Works independently of `/optimus:init` — no project setup required

## Quick Start

This skill is part of the [optimus](https://github.com/oprogramadorreal/optimus-claude) plugin. See the [main README](../../README.md) for installation instructions.

## Usage

In Claude Code, use any of these:

- `/optimus:pr`
- "create a pull request"
- "update the PR description"
- "open a merge request"

The skill detects the platform, analyzes the diff between your branch and the repo's default branch, generates a structured description, and creates (or updates) the PR/MR.

## When to Run

- **After feature work** — create a PR with a clear description of what changed and why
- **After `/optimus:code-review`** — once review findings are addressed, create or update the PR
- **When updating an existing PR** — regenerate the description after pushing new commits
- **When you want consistent PR format** — same structure across all PRs in the project

## Example Output

Given a branch with 3 commits adding email validation:

```
## Pull Request

- Branch: `feat/email-validation` → `main`
- Platform: GitHub
- Action: Created
- URL: https://github.com/owner/repo/pull/42
- Files changed: 3
- Commits: 3
```

The generated PR description:

```markdown
### Summary
Introduces **email format validation** to the signup form. Validates email
format before the API call to prevent invalid submissions and reduce
server-side 400 errors.

- Client-side validation with RFC 5322 regex
- Error message displayed inline below the email field

### Changes
- **`src/auth/validate.ts`** — New `validateEmail` function with RFC 5322 pattern
- **`src/components/SignupForm.tsx`** — Integrated client-side validation on blur and submit
- **`src/auth/__tests__/validate.test.ts`** — Tests for invalid formats

### Test Plan
- Run `npm test` — all tests pass including 12 new validation tests
- Submit signup form with invalid email — error message appears inline
- Submit with valid email — form submits normally
```

## How It Works

1. Validates the current branch (not main/master, not detached HEAD)
2. Detects platform (GitHub or GitLab) from remote URL, falling back to CI file detection
3. Verifies CLI availability (`gh` or `glab`) and authentication
4. Determines the base branch (repo's default branch)
5. Checks for existing PR/MR — offers to update or create new
6. Pushes the branch to origin if needed
7. Analyzes the diff and generates a structured description (Summary, Changes, Rationale, Test Plan)
8. Creates or updates the PR/MR via CLI
9. Reports the result with branch, URL, and file/commit counts

## Relationship to Other Skills

| | `/optimus:pr` | `/optimus:tdd` |
|---|---|---|
| PR creation | Dedicated — any branch, any workflow | Built-in — creates PR at end of TDD session |
| Description | Generated from branch diff | Includes TDD-specific content (behaviors, coverage) |
| When to use | After any feature work or code review | Automatic — part of the TDD workflow |

| | `/optimus:pr` | `/optimus:code-review` |
|---|---|---|
| Timing | After implementation (create PR) | Before merging (review PR) |
| Focus | Describe what changed and why | Catch issues in the changes |
| Workflow | Build → `/optimus:pr` → `/optimus:code-review` → merge |

| | `/optimus:pr` | `/optimus:commit-message` |
|---|---|---|
| Scope | Entire branch diff → PR description | Single commit → commit message |
| Format | Summary, Changes, Rationale, Test Plan | Conventional commit (type, scope, description) |

**Recommended sequence**: Implement feature → `/optimus:pr` (create PR) → `/optimus:code-review` (review) → merge.

## Skill Structure

| File | Purpose |
|---|---|
| `SKILL.md` | Skill definition with 9-step PR/MR creation workflow |
| `references/pr-template.md` | Shared description format template (also used by `/optimus:tdd`) |

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 1.0.33+ (plugin support)
- Git
- GitHub CLI (`gh`) or GitLab CLI (`glab`) — the skill offers to install if missing

## License

[MIT](../../LICENSE)
