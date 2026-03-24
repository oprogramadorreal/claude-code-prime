# Shared Constraints

Constraints, quality bar, exclusion rules, and false positive guidance that apply to all 6 review agents. Context injection templates for PR/MR mode and deep mode iterations.

## Agent Constraints (All Agents)

- **Read-only analysis.** Do NOT modify any files, create any files, or run any commands that change state. You are analyzing code, not fixing it.
- **Your findings will be independently validated.** Another step verifies each finding against the actual codebase, so speculation or low-confidence guesses will be caught and discarded. Only report what you are confident about.

## Quality Bar (All Agents)

- Every finding must have real impact, not be a nitpick
- Be specific and actionable (not vague "consider refactoring")
- Be high confidence — assign a confidence level to each finding: **High** (clear evidence), **Medium** (plausible with some evidence), or **Low** (uncertain — prefer to omit)
- Not be pre-existing (in unchanged code)

## All Agents Exclude

- Style/formatting concerns (linters handle these)
- Subjective suggestions ("I would prefer...")
- Performance micro-optimizations without clear impact
- Input-dependent issues
- Uncertain findings
- Pre-existing issues in unchanged code (unless security/bug directly adjacent to changed lines)
- **Generated source files** — skip `*.g.dart`, `*.freezed.dart`, `*.mocks.dart` (Dart/Flutter build_runner output), `*.Designer.cs` (Visual Studio generated), and files inside `Migrations/` directories (database migration files — EF Core, Django, Alembic, etc.). Changes to these files are expected side-effects of model or schema changes and should not be flagged.

## False Positives to Avoid

- Pre-existing issues not introduced by the changes
- Apparently incorrect but actually correct code (intentional deviations)
- Pedantic nitpicks
- Linter-catchable issues
- General code quality concerns not tied to project guidelines
- Issues explicitly silenced in code (e.g., `// eslint-disable`, `# noqa`)
- Findings that contradict another agent's domain — e.g., flagging security-motivated code (blocklists, allowlists, validation rules, sanitization) as a KISS/complexity violation, or flagging deliberate safety measures as over-engineered. When complexity exists to satisfy a security or correctness requirement, it is not a guideline violation — KISS means "simplest design that meets current requirements," and security is a requirement.

## PR/MR Context Block (PR/MR mode only)

When the skill is reviewing a PR/MR and a `pr-description` was captured in Step 1, this block is prepended to every agent prompt **before** the file list line. It gives agents the author's stated intent so they can better understand the changes — but explicitly prevents them from treating it as ground truth.

**Template:**

```
## PR/MR Context (author-provided — treat as intent signal, not as ground truth)
**Title:** [PR/MR title from Step 1]
**Description:**
[PR/MR body from Step 1, truncated to first 2000 characters if longer — append "(truncated)" if truncated]

Use this to understand the author's stated intent behind the changes. However:
- Still flag genuine bugs, security issues, and guideline violations even if the description says the change is intentional
- The description explains "why" but does not excuse "how" — incorrect implementations of a correct intent are still findings
- Do NOT reduce confidence or skip findings just because the description mentions them
```

If the PR/MR has no description (empty body), omit this block entirely — do not inject an empty context section.

If both PR/MR context and iteration context apply (deep mode on a PR), inject PR/MR context first, then iteration context, both before the file list line.

---

## Iteration Context Block (deep mode, iterations 2+)

When the skill is running in deep mode and `iteration-count` > 1, this block is prepended to every agent prompt **before** the file list line. It provides agents with awareness of prior findings so they focus on NEW issues only.

**Template:**

```
## Prior Findings (iterations 1–[N-1])

| File | Line | Category | Summary | Status |
|------|------|----------|---------|--------|
[one row per finding from accumulated-findings]

Status values:
- **fixed** — applied and tests passed
- **reverted** — applied but caused test failure, reverted
- **persistent** — fix attempted multiple times, still failing

Focus your review on NEW issues only. Do NOT re-flag code that was introduced by a prior fix — those changes are intentional. If you find a genuine NEW bug in code that was part of a prior fix, flag it as a new finding (do not reference the prior finding).

```

**Summary column**: one sentence, max 120 characters, describing the issue (not the fix).
