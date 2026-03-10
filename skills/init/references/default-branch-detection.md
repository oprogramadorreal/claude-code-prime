# Default Branch Detection

Detect the repository's default branch using this fallback chain:

1. **Symbolic ref** — `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'`
2. **Try `main`** — if step 1 fails, check if `origin/main` exists: `git rev-parse --verify origin/main 2>/dev/null`
3. **Try `master`** — if step 2 fails, check if `origin/master` exists: `git rev-parse --verify origin/master 2>/dev/null`
4. **All failed** — if no default branch can be determined (all methods fail), inform the user: "Could not detect the default branch. Ensure `origin` is configured and has been fetched." Stop.
