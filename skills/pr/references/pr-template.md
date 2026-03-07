# PR/MR Description Template

Shared format for pull request and merge request descriptions. Referenced by `/optimus:pr` and `/optimus:tdd`.

## Title

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<optional scope>): <description>
```

**Rules:**
- Under 72 characters
- Imperative mood ("Add feature" not "Added feature")
- Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`
- Scope is optional — use when the change targets a specific module or area

## Body Sections

### Summary

2-4 sentences explaining what was introduced/changed and why. Follow with a bullet list of key aspects when the change has multiple dimensions:

```markdown
### Summary
Introduces a **Feature Name** that does X. This enables Y and replaces the previous approach of Z.

- Key aspect or capability 1
- Key aspect or capability 2
- Key aspect or capability 3
```

If the change is small (single-purpose fix or tweak), the bullet list is optional — the sentences alone are sufficient.

### Changes

Bullet list of changed files with bold paths and a short description of what changed in each:

```markdown
### Changes
- **`path/to/file.ts`** — Added validation logic for email format
- **`path/to/other.ts`** — Updated handler to use new validator
- **`path/to/test.ts`** — Tests for email validation edge cases
```

**Rules:**
- Cap at 20 entries — if more files changed, group by directory (e.g., "**`src/auth/`** — 8 files: refactored auth flow")
- Order by significance (most important changes first), not alphabetically
- Each entry is one line — keep descriptions concise

### Rationale

Optional — include only when the approach involves non-obvious trade-offs, rejected alternatives, or design decisions that reviewers would question.

```markdown
### Rationale
Chose X over Y because of Z. Alternative A was considered but rejected due to B.
```

Omit this section entirely for straightforward changes.

### Test Plan

Bullet list of verification steps — commands to run, manual checks, edge cases to validate:

```markdown
### Test Plan
- Run `npm test` — all tests pass including new auth tests
- Verify login with uppercase email succeeds
- Confirm rate limiting blocks after 3 attempts
```

Include both automated and manual verification steps where applicable.

## Complete Example

```markdown
### Summary
Introduces **email format validation** to the signup form. Validates email format before the API call to prevent invalid submissions and reduce server-side 400 errors.

- Client-side validation with RFC 5322 regex
- Error message displayed inline below the email field
- Existing server-side validation unchanged as a safety net

### Changes
- **`src/auth/validate.ts`** — New `validateEmail` function with RFC 5322 pattern
- **`src/components/SignupForm.tsx`** — Integrated client-side validation on blur and submit
- **`src/auth/__tests__/validate.test.ts`** — Tests for common invalid formats (missing @, double dots, trailing dots)

### Rationale
Client-side validation chosen over removing server-side checks to maintain defense-in-depth. Regex approach preferred over a validation library to avoid adding a dependency for a single function.

### Test Plan
- Run `npm test` — all tests pass including 12 new validation tests
- Submit signup form with invalid email — error message appears inline
- Submit with valid email — form submits normally
```
