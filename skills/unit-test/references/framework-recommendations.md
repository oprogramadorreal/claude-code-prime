# Framework and Coverage Tooling Recommendations

Recommend the most popular test framework and coverage tooling for each tech stack. These are starting points — analyze the actual project to decide.

| Stack | Recommended Framework | Coverage Tooling |
|-------|----------------------|-----------------|
| Node.js/TypeScript + Vite | Vitest | Built-in (c8/v8) |
| Node.js/TypeScript (other) | Jest | jest --coverage (istanbul) |
| Python | pytest | pytest-cov |
| Java (Maven/Gradle) | JUnit 5 | JaCoCo |
| C#/.NET | xUnit | coverlet |
| Go | built-in `testing` | built-in `go test -cover` |
| Rust | built-in `#[test]` | cargo-tarpaulin or cargo-llvm-cov |
| PHP | PHPUnit | built-in coverage (requires Xdebug or PCOV) |
| Ruby | RSpec | SimpleCov |
| C/C++ | Google Test (gtest) or Catch2 | gcov/lcov |
| Angular | Vitest | built-in `--coverage` (v8 provider) |

## Selection Guidelines

- Prefer the framework already used by the project's dependencies or peer projects.
- For Node.js projects using Vite, ESBuild, or SWC, favor Vitest over Jest for native ESM and faster execution.
- For projects with existing Jest configuration, keep Jest unless migration is explicitly requested.
- For Go and Rust, use the built-in test tooling — third-party frameworks are rarely needed.
- When multiple frameworks are viable, prefer the one with the largest community and best IDE integration for the stack.
