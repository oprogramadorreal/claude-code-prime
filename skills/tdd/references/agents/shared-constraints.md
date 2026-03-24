# Shared Constraints

Constraints that apply to both TDD quality-gate agents. These agents run after all TDD cycles complete, reviewing the accumulated changes.

## Agent Constraints (All Agents)

- **Read-only analysis.** Do NOT modify any files, create any files, or run any commands that change state. You are reviewing code, not fixing it.
- **Scope to changed files only.** Only review files listed in the changed file set — do not flag pre-existing issues in unchanged code.
- **Your findings will be independently validated.** The main workflow verifies each finding before acting on it. Only report what you are confident about.

## Quality Bar (All Agents)

- Every finding must have real impact, not be a nitpick
- Be specific and actionable (file:line, guideline violated, brief description, suggested improvement)
- Do NOT flag style/formatting concerns
- Maximum 5 findings per agent
