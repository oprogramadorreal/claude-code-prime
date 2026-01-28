---
name: bootstrap
description: Bootstrap effective documentation following LLM-optimized practices
disable-model-invocation: true
---

# Bootstrap Project Documentation

Create optimized CLAUDE.md and supporting docs using research-backed practices. Unlike `/init`, this generates structured documentation following the WHAT/WHY/HOW framework with progressive disclosure.

## Before You Start

Read `.claude/skills/claude-code-bootstrap/references/claude-md-best-practices.md` and apply throughout:
- Keep CLAUDE.md under 60 lines
- Use file:line references, not code snippets
- Only include universally-applicable instructions

## Step 1: Detect Project Context

**Identify project type** from manifest files:

| Manifest | Type | Package Manager |
|----------|------|-----------------|
| package.json | Node.js | npm, yarn, pnpm, bun |
| Cargo.toml | Rust | cargo |
| pyproject.toml, setup.py, requirements.txt | Python | pip, poetry, uv |
| *.csproj, *.sln | C#/.NET | dotnet |
| pom.xml | Java | maven |
| build.gradle | Java | gradle |
| go.mod | Go | go |
| CMakeLists.txt, Makefile | C/C++ | cmake, make |
| Gemfile | Ruby | bundler |

**Extract**: Project name, tech stack, build system, available scripts.

**Analyze structure** (stay shallow):
- README.md for project purpose and features
- Top-level directories for architecture pattern
- Entry points (main.ts, index.ts, app.module.ts, etc.)

## Step 2: Create Directory Structure

```bash
mkdir -p .claude/docs
```

## Step 3: Create CLAUDE.md

Create `.claude/CLAUDE.md` with living document header:

```markdown
<!-- Keep this file and .claude/docs/ updated when project structure, conventions, or tooling changes -->

# Project Name
```

**Structure content using WHAT/WHY/HOW:**

| Section | Content |
|---------|---------|
| **WHAT** | Project name, purpose (1 line), tech stack summary |
| **WHY** | Essential commands: build, test, lint (from project manifest) |
| **HOW** | Documentation references with task-oriented descriptions |

**Documentation section format:**
```markdown
## Documentation
Read the relevant doc before making changes:
- `coding-guidelines.md` - For new features, refactoring, code structure
- `testing.md` - For writing or modifying tests
- `styling.md` - For UI components, CSS, visual changes
- `architecture.md` - For understanding project structure, data flow
```

Only list docs that were actually created. Keep total file under 60 lines.

## Step 4: Create settings.json

Use template from `.claude/skills/claude-code-bootstrap/templates/settings.json`. Customize allow list based on detected project type:

| Type | Commands to Allow |
|------|-------------------|
| Node.js | `npm run`, `npx`, `yarn`, `pnpm` |
| Rust | `cargo build`, `cargo test`, `cargo run`, `cargo clippy` |
| Python | `pytest`, `pip`, `poetry`, `uv`, `ruff`, `mypy` |
| C#/.NET | `dotnet build`, `dotnet test`, `dotnet run`, `dotnet restore` |
| Java/Maven | `mvn compile`, `mvn test`, `mvn package` |
| Java/Gradle | `gradle build`, `gradle test`, `gradlew` |
| Go | `go build`, `go test`, `go run`, `go vet`, `golangci-lint` |
| C/C++ | `cmake`, `make`, `ctest`, `ninja` |
| Ruby | `bundle`, `rake`, `rspec` |

## Step 5: Create Documentation Files

**Always create:**
- `coding-guidelines.md` - Use template from `.claude/skills/claude-code-bootstrap/templates/docs/coding-guidelines.md` (replace [PROJECT NAME])

**Create if applicable:**

| File | Create When |
|------|-------------|
| `testing.md` | Test framework detected (Jest, Karma, pytest, cargo test, go test, etc.) |
| `styling.md` | Frontend project (Angular, React, Vue, or has CSS/SCSS files) |
| `architecture.md` | Project has meaningful structure worth documenting |

## Step 6: Handle Existing Files

| Scenario | Action |
|----------|--------|
| Root `CLAUDE.md` exists | Read for context, create improved `.claude/CLAUDE.md`, suggest removing root file |
| `.claude/` directory exists | Proceed normally - create/update files as needed |
| No manifest detected | Create generic docs with placeholders, inform user manual customization is recommended |

## Step 7: Verify

List all created files:
```bash
find .claude -type f \( -name "*.md" -o -name "*.json" \)
```
