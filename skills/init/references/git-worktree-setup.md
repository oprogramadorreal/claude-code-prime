# Git Worktree Setup and Cleanup

Shared patterns for creating, using, and cleaning up git worktrees for isolated work.

## Slug Derivation

Derive a worktree directory name from the branch name: replace `/` with `-`, then strip any character not in `[a-zA-Z0-9._-]` (e.g., `feature/auth` → `feature-auth`). Always quote the resulting path in shell commands.

## Directory and Gitignore Setup

1. Check if `.worktrees/` exists — if not, create it: `mkdir -p .worktrees`
2. Ensure `.worktrees/` is gitignored: check if `.gitignore` contains `.worktrees/` or `.worktrees`. If not, append on a new line (ensuring a preceding newline so it doesn't merge with the last entry): `printf '\n.worktrees/\n' >> .gitignore`

## Dependency Installation

Run project setup inside the worktree (detect from `CLAUDE.md` or manifests):

| Stack | Install command |
|-------|----------------|
| Node.js | `npm install` / `pnpm install` / `yarn install` / `bun install` (match project's lock file) |
| Python | `pip install -e .` / `poetry install` / `uv sync` (match project's lock file) |
| Rust | `cargo build` |
| Go | `go mod download` |
| C#/.NET | `dotnet restore` |
| Java (Maven) | `mvn install -DskipTests` |
| Java (Gradle) | `gradle build -x test` |
| C/C++ | `cmake -B build && cmake --build build` (or project-specific) |

## Baseline Verification

Run the test suite inside the worktree as a sanity check:
- **Tests pass** → worktree is functional, record results as baseline
- **Tests fail** → record failures as baseline (may be pre-existing or introduced by the branch)
- **Build fails** → record as a significant finding, continue with what is possible

## Worktree Fallback

If `git worktree add` fails (git version < 2.15, filesystem issues, etc.):
1. Warn the user that worktree creation failed and the skill will fall back to running directly on the current branch
2. Create a temporary directory for artifacts (e.g., `mkdir -p .<skill>-sandbox`) and ensure it is gitignored
3. Proceed with subsequent steps using the current working directory instead of the worktree

## Cleanup

When cleaning up a worktree:
1. Switch to the main workspace directory (parent of `.worktrees/`)
2. Remove the worktree: `git worktree remove .worktrees/<worktree-path>`
   - If removal fails due to changes: `git worktree remove --force .worktrees/<worktree-path>`
3. If `.worktrees/` is empty, remove it: `rmdir .worktrees 2>/dev/null`
4. If `extensions.worktreeConfig` was enabled and no other worktrees remain: `git config --unset extensions.worktreeConfig 2>/dev/null`
5. If a fallback sandbox directory was created, remove it
