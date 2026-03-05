# ai-tools

Personal Claude Code toolkit: agents, skills, commands.

## Structure

```
ai-tools/
├── agents/          # Specialized subprocesses (subagents)
├── skills/          # Procedural skill instructions
├── commands/        # Slash-commands (user-facing entry points)
├── shared/          # Shared templates
│   └── work-templates/
├── scripts/
│   └── install.sh   # Deploy to a new machine
└── CLAUDE.md        # Global behavioral rules
```

## Domain prefixes

Skills and agents use domain prefixes:
- `dev-*` — software development
- `mgmt-*` — team management
- `comm-*` — communication, conflict resolution
- `event-*` — workshops, talks, events

## Install

```bash
./scripts/install.sh
```

Creates symlinks from `~/.claude/` into this repository.

---

## How to use

### Three-layer architecture

```
User types /command
     ↓
Command (commands/*.md) — thin wrapper, entry point
     ↓
Skill (skills/*/SKILL.md) — workflow with steps, decisions, loops
     ↓
Agents (agents/dev-*.md) — specialized subagents spawned via Task tool
```

**The user only interacts with `/commands`.** Skills and agents work automatically.

---

### Workflow

#### New project

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `/init-project` | Copy template, init git, create remote repository |
| 2 | `project-planning` skill | Adaptive interview → fill project documentation |

#### Adding a feature

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `/new-user-spec` | Adaptive interview → user specification |
| 2 | `/new-tech-spec` | Code research + validators → technical specification |
| 3 | `/decompose-tech-spec` | Split tech-spec into task files |
| 4 | `/do-feature` | Execute all tasks by waves with reviews and commits |
| ↳ | `/do-task` | Alternative: execute tasks one by one |
| 5 | `/done` | Update project knowledge, archive feature |

#### Ad-hoc changes (bug fixes, small tweaks, refactoring)

| Command | What it does |
|---------|--------------|
| `/write-code` | TDD + reviews without feature management overhead |

Use when the change is too small to warrant a spec and decomposition: fixing a bug, adding a utility, small refactor, spike.

---

### File naming convention

All feature artifacts share a common `feature_base` prefix:

```
docs/features/
└── 001-feat-add-auth/
    ├── 001-feat-add-auth.md                   # user-spec
    ├── 001-feat-add-auth-tech-spec.md          # tech-spec
    ├── 001-feat-add-auth-decisions.md          # decisions log
    ├── 001-feat-add-auth-task-01.md            # task file
    ├── 001-feat-add-auth-task-02.md
    └── 001-feat-add-auth-task-01-dev-code-reviewer-review.json
```

`feature_base` = `docs/features/001-feat-add-auth/001-feat-add-auth`

---

### Skills reference

Skills are not called directly by the user — they are invoked by commands. Listed here for reference:

| Skill | Called by | What it does |
|-------|-----------|--------------|
| `spec-writer` | `/new-user-spec` | Adaptive interview to capture requirements |
| `tech-spec-planning` | `/new-tech-spec` | Code research, architecture decisions, multi-validator review |
| `task-decomposition` | `/decompose-tech-spec` | Split tech-spec into atomic task files |
| `feature-execution` | `/do-feature` | Orchestrate waves, spawn reviewers, manage review cycles |
| `code-writing` | `/write-code`, `/do-task` | TDD cycle: test → implement → review |
| `documentation-writing` | `/done` | Update project knowledge files |
| `project-planning` | Manually (after `/init-project`) | Fill initial project documentation |
| `deploy-pipeline` | Manually or via task | Configure CI/CD pipelines |
| `infrastructure-setup` | Manually or via task | Setup dev infrastructure |
| `prompt-master` | Manually | Write/improve LLM prompts |
| `skill-master` | Manually | Create or update skills and agents |

---

### Agent reviewers

Agents are spawned automatically by skills during execution. They are not called by the user directly.

| Agent | Triggered by | What it checks |
|-------|-------------|----------------|
| `dev-code-reviewer` | `code-writing` skill | Code quality: structure, patterns, naming, complexity |
| `dev-security-auditor` | `code-writing` skill | OWASP Top 10, injections, auth, secrets |
| `dev-test-reviewer` | `code-writing` skill | Test quality: coverage, assertions, test pyramid |
| `dev-task-creator` | `task-decomposition` skill | Creates individual task files |
| `dev-task-validator` | `task-decomposition` skill | Validates task files against template |
| `dev-tech-spec-validator` | `tech-spec-planning` skill | Validates tech spec completeness |
| `dev-userspec-quality-validator` | `spec-writer` skill | Checks user spec quality |
| `dev-prompt-reviewer` | `code-writing` skill (prompt tasks) | Prompt quality |
| `dev-skill-checker` | `skill-master` skill | Skill file compliance |
| `dev-infrastructure-reviewer` | `infrastructure-setup` skill | Docker, pre-commit, folder structure |
| `dev-deploy-reviewer` | `deploy-pipeline` skill | CI/CD pipeline quality |
