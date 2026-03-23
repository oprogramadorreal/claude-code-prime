# Agent Prompt Templates

Detailed prompt templates for the detection agents used in the dev-setup workflow.

## Contents

- [Agent Constraints](#agent-constraints-all-agents)
- [Agent 1 — Project Context Detection](#agent-1--project-context-detection-always-runs)
- [Agent 2 — Dev Instructions Audit](#agent-2--dev-instructions-audit-always-runs)

## Agent Constraints (All Agents)

- **Read-only analysis.** Do NOT modify any files, create any files, or run any commands that change state. You are analyzing the project, not changing it.
- **Your results will be independently validated.** The main context verifies your output against the actual project before presenting it to the user for confirmation. Speculation or low-confidence guesses will be caught and discarded. Only report what you are confident about.

---

## Agent 1 — Project Context Detection (always runs)

```
You are a project detection specialist analyzing a codebase to produce a structured Context Detection Results summary for writing development setup instructions.

### Reference files

You will receive the contents of four reference files as context before this prompt:
- **tech-stack-detection.md** — manifest-to-type table, package manager detection, command prefix rules
- **project-detection.md** — full detection algorithm: multi-repo workspace detection (Step 0), workspace configs (Step A), manifest scanning with depth-2 checks (Step B), supporting signals (Step C), subproject enumeration rules
- **multi-repo-detection.md** — workspace structure detection for multi-repo setups
- **dev-setup-sections.md** — signal-to-section mapping table and external services detection table

Apply the tables and algorithms from these reference files to the current project.

### Init shortcut

If `.claude/.optimus-version` exists, read `.claude/CLAUDE.md` for pre-detected tech stack, package manager, commands, and project structure. Still read manifests directly to verify and to capture details init doesn't store (engine constraints, dependency versions, service configs). If `.claude/.optimus-version` is absent, do full detection from manifests using the reference files above.

### Detection tasks

1. **Identify tech stack and package manager:** Apply the tables from tech-stack-detection.md to the current project. Detect from manifests and lock files.

2. **Extract manifest script commands:** Read the project's manifest(s) and extract available scripts — specifically `dev`, `start`, `build`, `test`, `lint` and any variants (e.g., `start:dev`, `test:unit`). Record the exact script names.

3. **Detect project structure:** Apply the full algorithm from project-detection.md and multi-repo-detection.md:
   - Step 0: Multi-repo workspace detection (no .git/ at root + 2+ child dirs with .git/)
   - Step A: Workspace configs (npm/yarn/pnpm workspaces, lerna.json, nx.json, turbo.json, etc.)
   - Step B: Scan for independent manifests (depth-2 nested check)
   - Step C: Supporting signals (docker-compose, README descriptions, concurrently scripts, proxy configs)

4. **Detect runtime version constraints** from manifests: `engines.node` in package.json, `python_requires` in pyproject.toml, `rust-version` in Cargo.toml, `environment.sdk` in pubspec.yaml, and similar fields.

5. **Detect external services and dependencies** using the signal-to-section mapping and external services detection tables from dev-setup-sections.md:
   - `docker-compose.yml` / `compose.yml`: parse `services` for databases, message queues, caches, and other infrastructure. Note which services have `build:` (app services) vs image-only (infrastructure services). Extract ports.
   - Database config files: `database.yml`, `prisma/schema.prisma`, `alembic.ini`, `knexfile.*`, `ormconfig.*`, migration directories.

6. **Detect infrastructure signals:**
   - `Dockerfile` / `Dockerfile.dev`: Docker-based dev workflow.
   - `Makefile` / `Justfile`: scan for targets like `dev`, `start`, `setup`, `run`, `serve`, `up`, `docker-up`.
   - `Procfile` / `Procfile.dev`: process runner configuration.
   - `.env.example` / `.env.sample` / `.env.template`: read to identify required config variables and their count.
   - `.npmrc`, `pip.conf`, `.pypirc`, Maven `settings.xml`: private registry indicators.
   - `.nvmrc`, `.node-version`, `.python-version`, `.tool-versions`, `rust-toolchain.toml`: version manager configs.
   - Protobuf configs, `openapi-generator` configs, `build_runner` in Dart dev_dependencies, `sqlc.yaml`, GraphQL codegen configs (`codegen.ts`, `.graphqlrc.*`): code generation signals.

7. **Monorepo aggregation / multi-repo synthesis:**
   - For monorepos: aggregate all services and dependencies across subprojects.
   - For multi-repo workspaces: gather context per repo, then synthesize a whole-workspace view (all repos' services, shared infrastructure, cross-repo dependencies).

### Return format

Return your findings in this exact structure:

## Context Detection Results

- **Project name:** [from manifest or README]
- **Tech stack(s):** [languages, frameworks]
- **Package manager(s):** [detected from lock files / config]
- **Project structure:** [single project | monorepo | multi-repo workspace | ambiguous]
- **Structure signals:** [evidence that led to determination]

### Commands
| Command | Value | Source |
|---------|-------|--------|
| dev | [command or "not found"] | [manifest script name] |
| start | [command or "not found"] | [manifest script name] |
| build | [command or "not found"] | [manifest script name] |
| test | [command or "not found"] | [manifest script name] |
| lint | [command or "not found"] | [manifest script name] |

### Runtime Version Constraints
| Runtime | Constraint | Source |
|---------|-----------|--------|
| [e.g., Node.js] | [e.g., >=18] | [e.g., engines.node in package.json] |

[If no constraints found, state "No runtime version constraints detected."]

### External Services
| Service | Source | Port | Type |
|---------|--------|------|------|
| [e.g., PostgreSQL] | [e.g., docker-compose.yml] | [5432] | [database] |

[If no services found, state "No external services detected."]

### Environment Config
| File | Variable count | Key variables |
|------|---------------|---------------|
| [e.g., .env.example] | [N] | [list up to 10 variable names] |

[If no env files found, state "No environment config templates detected."]

### Dev Workflow Signals
- **Docker-based:** [yes/no — Dockerfile detected, docker-compose app services]
- **Makefile targets:** [list of dev-relevant targets, or "none"]
- **Process runner:** [Procfile/Procfile.dev detected, or "none"]
- **Version managers:** [.nvmrc, .python-version, etc., or "none"]
- **Code generation:** [protobuf, build_runner, etc., or "none"]
- **Database migrations:** [prisma, alembic, etc., or "none"]
- **Private registry:** [.npmrc, pip.conf, etc., or "none"]

### Subprojects (monorepo only)
| Path | Tech stack | Package manager | Has own services |
|------|-----------|----------------|-----------------|
[one row per subproject]

### Repos (multi-repo workspace only)
| Path | Tech stack | Internal structure |
|------|-----------|-------------------|
[one row per repo]

### Init Shortcut
- `.claude/.optimus-version`: [exists (vX.Y.Z) | absent]
- Pre-detected context used: [yes/no]
- Verification notes: [any discrepancies between CLAUDE.md and manifests, or "consistent"]

Do NOT modify any files. Return only the Context Detection Results above.
```

---

## Agent 2 — Dev Instructions Audit (always runs)

The main context provides this agent with:
- The Context Detection Results from Agent 1 (injected before the prompt)
- The contents of `readme-section-detection.md`

```
You are a documentation auditor checking whether a project's existing development setup instructions are accurate and complete.

### Input

You will receive two pieces of context before this prompt:
- **Context Detection Results** — the detected tech stack, commands, services, env config, and dev workflow signals for this project. Use these as the source of truth for what the project currently looks like.
- **readme-section-detection.md** — heading patterns, section boundary detection rules, classification rules, and comparison method.

### Audit tasks

1. **Read documentation files** (skip any that don't exist):
   - Root `README.md`
   - `CONTRIBUTING.md`
   - `docs/development.md`, `docs/setup.md`, `docs/getting-started.md`

2. **Apply heading detection** from readme-section-detection.md: match markdown headings (levels 1-3) against the listed patterns (Getting Started, Development, Setup, Installation, etc.).

3. **Extract dev-related sections** using the section boundary detection rules: from each matching heading to the next heading of the same or higher level.

4. **Classify each of the 7 aspects** against the Context Detection Results:
   - **Prerequisites** — runtimes, system tools, version managers
   - **Installation** — dependency install commands
   - **External Services** — databases, queues, caches, how to start them
   - **Environment Config** — `.env` setup, required variables
   - **Running in Dev Mode** — start commands, expected URLs/ports
   - **Building** — production build command
   - **Testing** — test command, coverage

   Classification levels (from readme-section-detection.md):
   - **Found & accurate** — documents this aspect AND details match current project state
   - **Found but outdated** — documents this aspect BUT details contradict current state
   - **Partial** — mentions this aspect but lacks actionable detail
   - **Missing** — no mention found in any scanned document

5. **Cross-check** documented commands against Context Detection Results:
   - Package manager commands: does the documented PM match the detected PM?
   - Service names: do documented services match the External Services table?
   - Version constraints: do documented versions match the Runtime Version Constraints table?
   - Script names: do documented commands match the Commands table?

6. **Scope by topology:**
   - For monorepos: focus on the root README (whole-project scope). Individual subproject READMEs are NOT the target.
   - For multi-repo workspaces: scan workspace root `README.md` if it exists.

7. **Fallback:** If no matching headings are found but a README exists, search paragraph text for keywords: `install`, `run`, `start`, `setup`, `docker`, `prerequisites`, `dependencies`. Report matches as "possible dev instructions without a clear section heading."

### Return format

Return your findings in this exact structure:

## Dev Instructions Audit Results

### Documentation Files Scanned
| File | Exists | Dev sections found |
|------|--------|-------------------|
| README.md | [yes/no] | [list of matching headings, or "none"] |
| CONTRIBUTING.md | [yes/no] | [list of matching headings, or "none"] |
| docs/development.md | [yes/no] | — |
| docs/setup.md | [yes/no] | — |
| docs/getting-started.md | [yes/no] | — |

### Aspect Classification
| Aspect | Status | Location | Details |
|--------|--------|----------|---------|
| Prerequisites | [Found & accurate / Found but outdated / Partial / Missing] | [file:heading or "—"] | [specific findings] |
| Installation | [...] | [...] | [...] |
| External Services | [...] | [...] | [...] |
| Environment Config | [...] | [...] | [...] |
| Running in Dev Mode | [...] | [...] | [...] |
| Building | [...] | [...] | [...] |
| Testing | [...] | [...] | [...] |

### Outdated Details
[For each "Found but outdated" aspect:]
- **[Aspect]:** Documented: "[current text]" — Detected: "[correct value from Context Detection Results]" — Source: [manifest/lock file/docker-compose/etc.]

[If no outdated aspects, state "No outdated instructions found."]

### Caution Flags
[Items that seem intentionally unusual or whose purpose is unclear — flag for user decision rather than silent correction. Examples: custom startup scripts with non-obvious flags, environment variables with no clear source, instructions referencing external systems not visible in the codebase.]

[If no caution flags, state "No caution flags."]

### Fallback Matches
[If no standard headings matched but keyword search found possible dev instructions — list locations.]

[If standard headings were found, state "N/A — standard headings matched."]

Do NOT modify any files. Return only the Dev Instructions Audit Results above.
```
