# Shared Constraints

Constraints, quality bar, exclusion rules, and false positive guidance that apply to all 4 refactoring agents. Iteration context template for deep mode.

## Agent Constraints (All Agents)

- **Read-only analysis.** Do NOT modify any files, create any files, or run any commands that change state. You are analyzing code, not fixing it.
- **Your findings will be independently validated.** Another step verifies each finding against the actual codebase, so speculation or low-confidence guesses will be caught and discarded. Only report what you are confident about.

## Quality Bar (All Agents)

- Every finding must have real impact, not be a nitpick
- Be specific and actionable (not vague "consider refactoring")
- Be high confidence — assign a confidence level to each finding: **High** (clear evidence), **Medium** (plausible with some evidence), or **Low** (uncertain — prefer to omit)
- The fix must be concrete and demonstrable

## All Agents Exclude

- Style/formatting concerns (linters handle these)
- Subjective suggestions ("I would prefer...")
- Performance micro-optimizations without clear impact
- Uncertain findings
- Issues explicitly silenced in code (e.g., `// eslint-disable`, `# noqa`)
- **Generated source files** — skip `*.g.dart`, `*.freezed.dart`, `*.mocks.dart` (Dart/Flutter build_runner output), `*.Designer.cs` (Visual Studio generated), and files inside `Migrations/` directories (database migration files — EF Core, Django, Alembic, etc.). These files are auto-generated and should never be manually edited.

## False Positives to Avoid

- Apparently incorrect but actually correct code (intentional deviations)
- Pedantic nitpicks
- Linter-catchable issues
- General code quality concerns not tied to project guidelines
- Findings that contradict another agent's domain — e.g., flagging security-motivated code (blocklists, allowlists, validation rules, sanitization) as a KISS/complexity violation, or flagging deliberate safety measures as over-engineered. When complexity exists to satisfy a security or correctness requirement, it is not a guideline violation — KISS means "simplest design that meets current requirements," and security is a requirement.

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

Focus your review on NEW issues only. Do NOT re-flag code that was introduced by a prior fix — those changes are intentional. If you find a genuine NEW issue in code that was part of a prior fix, flag it as a new finding (do not reference the prior finding).

```

**Summary column**: one sentence, max 120 characters, describing the issue (not the fix).
