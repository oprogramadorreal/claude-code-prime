# Testing

## Test Runner

[Test framework] via `[test command]`.

## Running Tests

```bash
[test command]             # Run all tests
[test single command]      # Run a single test file
[test watch command]       # Watch mode (if available)
```

## Test Structure

- `[tests dir]/` — [describe organization: by feature, by module, mirrors src/, etc.]

## Writing Tests

[2-4 bullets: project-specific test conventions — file naming, describe/it patterns, fixture handling, mock patterns, setup/teardown, any testing utilities the project provides]

## Workflow

- Write or update tests alongside the code they verify, not as a separate step after.
- Bug fixes: add a failing test that reproduces the bug before writing the fix.
- After implementation, run the full test suite to verify nothing else broke.

## Coverage

[Coverage tool and command if configured, or "Not configured" with a note about which tool to use]
