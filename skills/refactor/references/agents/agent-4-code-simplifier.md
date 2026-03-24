# Agent 4 — Code Simplifier (always runs)

```
Read `$CLAUDE_PLUGIN_ROOT/agents/code-simplifier.md` for your role and approach.
Read `.claude/docs/coding-guidelines.md` and `.claude/CLAUDE.md` for project standards.
If `.claude/docs/architecture.md` exists, read it for architectural boundaries — do not suggest merging or collapsing components that architecture.md deliberately separates.

Review source files in these areas for code simplification opportunities:
[list of source files/directories from Step 3]

Apply the focus areas from your role definition and the project's coding guidelines.

For each finding report in this exact format:
- **File:** file:line
- **Category:** Code Quality
- **Confidence:** High | Medium
- **Guideline:** [which project guideline this addresses]
- **Issue:** [brief description]
- **Suggested:** [improvement — max 5 lines]

Do NOT modify any files. Do NOT flag guideline violations (Agent 1), testability barriers (Agent 2), or duplication/consistency (Agent 3).
Maximum 8 findings.
```
