# Dev Setup Section Templates

Section templates and signal-to-content mapping for generating development setup instructions. Referenced by dev-setup (Steps 1 and 4).

## Contents

- [Signal → Section Mapping](#signal--section-mapping)
- [Section Skeletons](#section-skeletons) (Prerequisites, Installation, External Services, Environment Setup, Running in Development, Building, Running Tests, Common Issues)
- [Package Manager Command Forms](#package-manager-command-forms)
- [External Services Detection](#external-services-detection)
- [Multi-Repo Workspace README Template](#multi-repo-workspace-readme-template)

## Signal → Section Mapping

| Signal | Section(s) to Generate |
|--------|----------------------|
| `engines.node`, `python_requires`, `rust-version`, `environment.sdk` | Prerequisites (runtime version) |
| `.nvmrc`, `.node-version`, `.python-version`, `.tool-versions`, `rust-toolchain.toml` | Prerequisites (version manager) |
| `docker-compose.yml` / `compose.yml` with infrastructure services | External Services (docker compose up) |
| `Dockerfile` / `Dockerfile.dev` without local-run scripts | Running in Development (Docker-based primary) |
| `.env.example` / `.env.sample` / `.env.template` | Environment Setup |
| `prisma/schema.prisma`, `alembic.ini`, migration directories | Installation (post-install: migrations) |
| `build_runner` in Dart dev_dependencies, protobuf configs, codegen configs | Installation (post-install: code generation) |
| `.npmrc`, `pip.conf`, `.pypirc`, Maven `settings.xml` | Prerequisites (private registry auth) |
| `Makefile` / `Justfile` with `dev`/`start`/`setup` targets | Running in Development (mention make target) |
| `Procfile` / `Procfile.dev` | Running in Development (process runner) |
| Test framework in dependencies + test script in manifest | Running Tests |

## Section Skeletons

### Prerequisites

```markdown
### Prerequisites

- [Runtime] [version constraint from manifest] ([version manager] recommended if config file detected)
- [Additional runtime for heterogeneous monorepo]
- [Docker](https://www.docker.com/) (if docker-compose detected — for running external services)
- [System tool] (if detected: make, protoc, etc.)
```

### Installation

```markdown
### Installation

Clone the repository:

\`\`\`bash
git clone <repo-url>
cd <project-name>
\`\`\`

Install dependencies:

\`\`\`bash
<package-manager install command>
\`\`\`

[If code generation detected:]

Generate code:

\`\`\`bash
<codegen command>
\`\`\`

[If database migrations detected:]

Run database migrations:

\`\`\`bash
<migration command>
\`\`\`
```

### External Services

```markdown
### External Services

This project requires the following services for local development:

| Service | Port | Purpose |
|---------|------|---------|
| [service name] | [port from compose] | [role: database, cache, queue, etc.] |

Start all services:

\`\`\`bash
docker compose up -d
\`\`\`

Verify services are running:

\`\`\`bash
docker compose ps
\`\`\`

[If no docker-compose: describe manual setup for each required service]
```

### Environment Setup

```markdown
### Environment Setup

Copy the example environment file:

\`\`\`bash
cp .env.example .env
\`\`\`

[List key variables from .env.example with brief descriptions of what they configure. Do not include secret values — only describe what each variable is for.]
```

### Running in Development

```markdown
### Running in Development

\`\`\`bash
<dev command from manifest scripts>
\`\`\`

[Expected result: URL, port, or output to verify it works]

[For monorepos — workspace-level:]

Run everything:

\`\`\`bash
<workspace dev command if available>
\`\`\`

Run a specific subproject:

\`\`\`bash
<per-subproject command, e.g., "pnpm --filter @scope/app dev">
\`\`\`

[For Docker-based primary:]

\`\`\`bash
docker compose up
\`\`\`

[Expected result]
```

### Building

```markdown
### Building

\`\`\`bash
<build command from manifest scripts>
\`\`\`
```

Only include this section if the build command is distinct from the dev command and is useful for developers (not just CI).

### Running Tests

```markdown
### Running Tests

\`\`\`bash
<test command>
\`\`\`

[If coverage command available:]

With coverage:

\`\`\`bash
<coverage command>
\`\`\`
```

### Common Issues

Only include if clear signals exist. Examples:

- `.nvmrc` detected → "Run `nvm use` before installing dependencies to ensure the correct Node.js version."
- Docker services required → "Ensure `docker compose up -d` is running before starting the application."
- Private registry → "Authenticate with the private registry before running install: `<auth command>`."
- Code generation → "If you see missing file errors after pulling, re-run `<codegen command>`."

## Package Manager Command Forms

Use the detected PM from `tech-stack-detection.md`. Common mappings:

| PM | Install | Run script | Run dev | Run tests | Run build |
|----|---------|-----------|---------|-----------|-----------|
| npm | `npm install` | `npm run <script>` | `npm run dev` | `npm test` | `npm run build` |
| pnpm | `pnpm install` | `pnpm run <script>` | `pnpm run dev` | `pnpm test` | `pnpm run build` |
| yarn | `yarn install` | `yarn <script>` | `yarn dev` | `yarn test` | `yarn build` |
| bun | `bun install` | `bun run <script>` | `bun run dev` | `bun test` | `bun run build` |
| pip | `pip install -r requirements.txt` | — | varies | `pytest` | — |
| poetry | `poetry install` | `poetry run <cmd>` | varies | `poetry run pytest` | `poetry build` |
| uv | `uv sync` | `uv run <cmd>` | varies | `uv run pytest` | `uv build` |
| cargo | — | `cargo <cmd>` | `cargo run` | `cargo test` | `cargo build` |
| go | `go mod download` | `go <cmd>` | `go run .` | `go test ./...` | `go build` |
| dotnet | `dotnet restore` | `dotnet <cmd>` | `dotnet run` | `dotnet test` | `dotnet build` |
| flutter | `flutter pub get` | `flutter <cmd>` | `flutter run` | `flutter test` | `flutter build` |
| dart | `dart pub get` | `dart run <cmd>` | `dart run` | `dart test` | `dart compile` |
| bundler | `bundle install` | `bundle exec <cmd>` | varies | `bundle exec rspec` | — |

Use the actual script names from the project's manifest (e.g., `pnpm run start:dev` not `pnpm run dev` if the script is named `start:dev`).

## External Services Detection

Common docker-compose image patterns → human-readable names:

| Image pattern | Service name |
|---------------|-------------|
| `postgres`, `postgis` | PostgreSQL |
| `mysql`, `mariadb` | MySQL/MariaDB |
| `mongo` | MongoDB |
| `redis` | Redis |
| `elasticsearch`, `opensearch` | Elasticsearch/OpenSearch |
| `rabbitmq` | RabbitMQ |
| `kafka`, `confluentinc` | Kafka |
| `memcached` | Memcached |
| `minio` | MinIO (S3-compatible storage) |
| `localstack` | LocalStack (AWS services) |
| `mailhog`, `mailpit` | Mail server (dev) |
| `keycloak` | Keycloak (auth) |
| `nginx`, `traefik`, `caddy` | Reverse proxy |

## Multi-Repo Workspace README Template

For workspace root (not version-controlled):

```markdown
# [Workspace Name] — Development Setup

## Repositories

| Repo | Path | Purpose |
|------|------|---------|
| [name] | `./[dir]` | [brief purpose] |

## Prerequisites

[Aggregated from all repos]

## Clone All Repos

\`\`\`bash
[clone commands for each repo]
\`\`\`

## Setup

[Per-repo install commands, or a setup script if one exists]

## External Services

[Shared infrastructure from docker-compose across repos]

## Running Everything

[How to start all services/apps together]
```
