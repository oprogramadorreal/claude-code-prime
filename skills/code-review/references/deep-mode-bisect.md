# Deep Mode Fix Protocol

Stash-based snapshot/restore procedure for applying and validating fixes during deep mode iterations.

## Before applying fixes

1. On iteration 1 only, create a baseline snapshot: `git stash push --include-untracked -m "deep-mode-baseline-$(date +%s)"`, then immediately restore the working tree: `git stash apply --index stash@{0}`. Record the exact stash message for all subsequent baseline lookups. This is the user's escape hatch if deep mode goes wrong across multiple iterations — document it in the iteration progress output.
2. Snapshot the current state: `git stash push --include-untracked -m "pre-iteration-N"` (using `--include-untracked` to capture new files), then immediately restore: `git stash apply --index stash@{0}`. If the apply fails, abort deep mode immediately — drop both the pre-iteration and baseline stashes and report the failure.

## Apply and test

1. For each finding, apply the suggested fix
2. After applying all fixes for this iteration, run the project's test command (from `.claude/CLAUDE.md`)

## If tests pass

1. `git stash drop` the `pre-iteration-N` snapshot (find it by checking `git stash list` for the matching message before dropping)
2. Add this iteration's fixed count to `total-fixed`

## If tests fail — bisect

1. Discard the failed fixes and restore pre-iteration state: `git checkout .` and `git clean -fd` (removes untracked files left by fixes), then `git stash apply --index $(git stash list | grep -F 'pre-iteration-N' | head -1 | cut -d: -f1)` (applies `pre-iteration-N` without removing it — preserves the entry for fallback). If the apply reports conflicts, abort the bisect: run `git checkout .` and `git clean -fd`, then attempt `git stash apply --index $(git stash list | grep -F '<baseline-message>' | head -1 | cut -d: -f1)` from the baseline. If the baseline restore also fails, do NOT run `git checkout .` — halt deep mode immediately and instruct the user to run `git stash list` for manual recovery (the baseline and pre-iteration stashes are preserved).
2. Re-apply fixes one at a time (in the same order they were originally applied), with a test run after each:
   - If the fix passes tests → keep it
   - If the fix fails tests → restore affected files from the pre-iteration snapshot (`git show $(git stash list | grep -F 'pre-iteration-N' | head -1 | cut -d: -f1):<file> > <file>`) and remove any new files it created, before proceeding to the next fix
   - If a fix fails to apply cleanly after an earlier fix was skipped → treat it as failed
3. After bisect completes, run the full test suite once more on the combined retained changes
   - If this combined run passes → `git stash drop` the `pre-iteration-N` entry. Add passing count to `total-fixed`, failing count to `total-reverted`
   - If this combined run fails → `git checkout .` and `git clean -fd`, then `REF=$(git stash list | grep -F 'pre-iteration-N' | head -1 | cut -d: -f1)`, `git stash apply --index "$REF"` to restore pre-iteration state, then `git stash drop "$REF"`. If apply conflicts, do NOT run `git checkout .` — halt deep mode immediately and instruct the user to run `git stash list` for manual recovery. Count all fixes as reverted in `total-reverted`
4. Mark reverted findings in `accumulated-findings` as "(reverted — test failure)"
