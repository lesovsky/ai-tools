---
name: project-planning
description: |
  Plan new projects: adaptive interview, tech decisions,
  fill all project documentation (project-knowledge) in one session.

  Use when: "сделай описание проекта", "запиши описание проекта в документацию",
  "проведи со мной интервью для описания проекта", "заполни документацию проекта",
  "начни планирование проекта", "давай опишем проект", "plan a new project",
  "fill project documentation"
---

# Project Planning

Conduct adaptive interview → make tech decisions → fill all project documentation in one session.

## Output Files

**Project Knowledge** (`.claude/skills/project-knowledge/references/`):
- **project.md** — overview, audience, problem, key features, scope
- **architecture.md** — tech stack, project structure, dependencies, data model
- **patterns.md** — git workflow (code patterns, testing, business rules are filled later during development)
- **deployment.md** — platform, environment, CI/CD, monitoring
- **ux-guidelines.md** — only if project has significant UI

## Phase 1: Project Discovery

### 1.1 Check PK Structure

Verify that `.claude/skills/project-knowledge/references/` exists in the project root.

If missing — create the structure from templates:
```bash
cp -r ~/.claude/shared/templates/new-project/.claude/skills/project-knowledge/ .claude/skills/project-knowledge/
```

If `~/.claude/shared/templates/` is not available (install.sh not yet run), create the files manually using the templates from `~/Projects/ai-tools/shared/templates/new-project/.claude/skills/project-knowledge/`.

### 1.2 Interview

Ask user to describe the project in free form. Let them say as much or as little as they want.

Then ask adaptive questions to cover three areas:

**Project Overview:**
- What the project does (one-line + context)
- Who uses it and why (target audience + use case)
- What problem it solves (core pain point)
- 3-5 key features (high-level only)
- Scope boundaries (explicit exclusions)

**Features & MVP:**
- Key features with descriptions
- What's included in MVP (launch scope)
- What comes later (post-launch ideas) — note these for the backlog
- Priority for each: Critical / Important / Nice-to-have

**Development Approach:**
- All at once or phased?
- If phased: how to group features, what's MVP
- If migration: current system, data migration, risks, rollback plan

**Architectural Boundaries (ask after stack is roughly clear):**
- Are there modules/layers that should never depend on each other? (e.g. "business logic must not import UI code")
- Are there areas of the codebase that are especially fragile or critical? ("red zones")
- Any quality thresholds important to the team? (test coverage, max function complexity)
- Any patterns that must be enforced? (e.g. "always go through service layer, never query DB from controller")

These answers become invariants in Phase 2.5. If user has no strong opinions — propose sensible defaults based on the project type.

### 1.3 Interview Methodology

**One question at a time.** Ask one question, wait for the answer, then form the next question based on the response.

**Build on answers.** If user mentioned a domain — ask domain-relevant follow-ups. If they said something vague — clarify that specific point.

**Confirm understanding.** After 3-5 questions, briefly summarize what you understood. Catches misunderstandings early.

**Help when stuck.** When user says "not sure" or "don't know":
1. Say it's OK
2. Offer 2-3 common approaches for their type of project
3. Ask which is closer
4. If still uncertain and optional — mark TBD, move on
5. If still uncertain and required — break into simpler sub-questions

**Recount on scope changes.** If user suddenly adds many features or reveals unexpected complexity — stop and recount total scope. Show the updated list, confirm you understood correctly.

**If code exists.** Scan the codebase in parallel with the interview to pre-fill technical decisions and ask more targeted questions.

### 1.4 Checkpoint

Move to Phase 2 when you can:
- Write a clear, non-vague project.md
- List key features with priorities and MVP scope
- Describe the development approach

TBD is acceptable for optional aspects.

## Phase 2: Technical Decisions

### 2.1 New Project (no code)

1. **Propose tech stack** based on Phase 1: frontend, backend, database, key dependencies
2. **Verify choices** against current docs (Context7 if available). Update if you find deprecations or better alternatives.
3. **Propose deployment:** platform, CI/CD approach, environments
4. **Present proposal** to user with rationale for each choice. Iterate until user approves.

### 2.2 Existing Code

1. **Extract stack** from the codebase: package files, configs, directory structure
2. **Verify** against current docs (Context7 if available)
3. **Confirm with user:** show what you found, ask about gaps (deployment, missing pieces)
4. Iterate until confirmed.

### 2.3 Architectural Invariants

Based on approved tech stack and architectural boundaries from Phase 1 — propose concrete, enforceable invariants and generate config files.

**Step 1: Select tools based on stack**

| Stack | Dependency rules | Complexity/style | Coverage |
|---|---|---|---|
| Node.js / TypeScript | dependency-cruiser | eslint (complexity, max-lines) | jest --coverage |
| Python | import-linter | pylint / flake8 | pytest-cov |
| Go | go-arch-lint | golangci-lint | go test -cover |
| Java / Kotlin | ArchUnit | checkstyle | jacoco |
| PHP | deptrac | phpmd | phpunit --coverage |
| Rust | — | clippy | cargo tarpaulin |

If stack is not in the list — choose the closest equivalent or skip invariant tooling, note the reason.

**Step 2: Propose 3-5 invariants**

Always propose (adapt names to the actual project structure):
1. **Layer dependency rule** — e.g. `core/` must not import from `ui/`, `api/` must not import from `db/` directly
2. **Complexity limit** — cyclomatic complexity ≤ 10 per function; file length ≤ 300 lines
3. **Test coverage floor** — coverage must not drop below agreed threshold (suggest 70-80% for new projects)
4. **Red zone protection** — if user identified fragile areas in Phase 1, name them explicitly as high-attention zones in docs

Optional (propose if relevant):
5. **No direct DB access outside repository layer** — if project has a clear data access pattern
6. **Public API stability** — exported types/interfaces must not change without explicit intent

Present proposed invariants to user. For each: what it enforces and why. User may adjust or drop any.

**Step 3: Generate config files**

For each approved invariant — generate the actual config file in the project root.

Examples:

`.dependency-cruiser.cjs` (Node.js):
```js
module.exports = {
  forbidden: [
    {
      name: "no-core-to-ui",
      from: { path: "^src/core/" },
      to: { path: "^src/ui/" },
      severity: "error"
    }
  ]
};
```

`.import-linter` (Python):
```ini
[importlinter]
root_package = myapp

[importlinter:contract:layers]
name = Enforce layered architecture
type = layers
layers =
    myapp.api
    myapp.services
    myapp.db
```

`pyproject.toml` / `setup.cfg` complexity section (Python):
```ini
[pylint.design]
max-complexity = 10
max-line-length = 120
```

Add invariant checks to the project's lint/test scripts (package.json, Makefile, etc.) so they run automatically.

**Step 4: Document in architecture.md**

Record invariants under "Architectural Invariants" section (filled in Phase 3).

### 2.4 Checkpoint

Move to Phase 3 when:
- Tech stack (frontend, backend, database, key dependencies) approved by user
- Deployment platform and CI/CD approach agreed
- Invariant tools selected and config files generated (or explicitly skipped with reason)
- No open questions on technical choices

## Phase 3: Fill Documentation

Documentation goal: someone opens these files and understands the project without reading code. Describe what exists, what it does, and why. Record decisions, operational details (server addresses, deploy procedures, log locations), high-level component overview. Write in prose, link to source files for code details. Each fact lives in one file only.

Use Edit tool to replace template placeholders with real content. Content language: English.

### 3.1 Project Knowledge Files

**project.md** — from Phase 1 interview:
- Project overview, target audience, core problem
- Key features with priorities and MVP scope
- Post-launch ideas (if discussed)
- Out of scope

**architecture.md** — from Phase 2 decisions + codebase analysis:
- Tech stack with "why" for each choice
- Project structure (directory tree)
- Key dependencies (only critical ones, not everything)
- External integrations
- Data flow
- Data model (fill if known, leave template sections if TBD)
- **Architectural Invariants** — list of enforced rules from Phase 2.3:
  - Each invariant: rule name, what it prevents, which tool enforces it, config file location
  - Red zones: list of fragile/critical modules with explanation why they need special care
  - If no invariants configured — note "not configured" with reason (e.g. "project too early-stage")

**patterns.md** — fill git workflow section:
- Branch structure, branch decision criteria
- Testing requirements per branch
- Security gates (pre-commit, pre-push)
- Leave code patterns, testing methods, and business rules sections minimal — filled during development as patterns emerge

**deployment.md** — from Phase 2 decisions:
- Platform, type, rationale
- Deployment triggers (what deploys where)
- Environments and URLs
- Environment variables (reference .env.example)
- Monitoring: fill if configured, note "not yet configured" if not

**ux-guidelines.md** — only if project has significant UI. Skip entirely for CLIs, APIs, bots without custom UI.

### 3.2 Backlog (if applicable)

If post-launch features were discussed during the interview, offer to save them to a backlog. Ask user where to create the backlog file.

### 3.3 Checkpoint

All output files from "Output Files" section created. No template placeholders remain.

## Phase 4: Review & Commit

### 4.1 Self-Verify

Before presenting to user, verify:
- project.md contains all key features discussed in interview
- architecture.md tech stack matches user-approved decisions from Phase 2
- No template placeholders remain

Fix any issues before proceeding.

### 4.2 Documentation Review

Run `dev-documentation-reviewer` agent (Task tool, sonnet) on the project-knowledge files. Fix critical and major findings. Minor findings — fix or leave at your discretion.

### 4.3 Show Files

Show user the list of created/updated files with links. Include ux-guidelines.md and backlog file if they were created. Ask if everything is correct or needs changes.

### 4.4 Iterate

- Changes requested → edit files → show updated list → repeat
- Questions → answer → continue waiting for approval
- Repeat until user approves

### 4.5 Commit

After approval, ask user if they want to commit. If yes — commit all created documentation files.

Final message: "Документация заполнена! Можно начинать разработку."
