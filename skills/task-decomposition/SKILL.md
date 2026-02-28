---
name: task-decomposition
description: Разбивает утверждённый tech-spec на атомарные task-файлы с параллельным созданием и валидацией.
---

# Task Decomposition

Decompose tech-spec Implementation Tasks into individual task files with parallel creation and validation.

**Input:** `{feature_base}-tech-spec.md` (status: approved)
**Output:** `{feature_base}-task-NN.md` files (validated)
**Language:** Task files in English, communication in Russian

## Phase 1: Create Tasks

1. Ask user for `feature_base` if not provided (e.g., `docs/features/001-feat-add-auth/001-feat-add-auth`).

2. Read `{feature_base}-tech-spec.md`. Check frontmatter `status: approved`.
   If not approved — stop: "tech-spec не утверждён. Сначала запусти `/tech-spec-planning` и доведи до approved."

3. Read `{feature_base}.md` (user-spec).

4. Note template path: `~/.claude/shared/work-templates/tasks/task.md.template`

5. Read skills/reviewers catalog from `~/.claude/skills/tech-spec-planning/references/skills-and-reviewers.md` — for passing correct skills/reviewers to task-creators.

6. Extract all tasks from Implementation Tasks section. Assign sequential IDs: `01`, `02`, `03`, ...

7. For each task — launch [`dev-task-creator`](~/.claude/agents/dev-task-creator.md) subagent in parallel.
   Pass each subagent:
   - `feature_base` — feature_base
   - `task_id` — zero-padded ID ("01", "02", ...)
   - `task_name` — task name from tech-spec
   - `template_path` — `~/.claude/shared/work-templates/tasks/task.md.template`
   - `files_to_modify` — from tech-spec task entry
   - `files_to_read` — from tech-spec task entry (optional)
   - `depends_on` — task IDs this task depends on (e.g., `["01"]`; default `[]`)
   - `wave` — wave number from tech-spec (default 1)
   - `skills` — skills array from tech-spec task entry
   - `reviewers` — reviewers array from tech-spec task entry
   - `verify` — verify field from tech-spec task entry (optional)

   Each subagent copies template to `{feature_base}-task-{ID}.md`, then edits each section in place.

8. Confirm each subagent returned a file path. Skip reading task content — preserve context budget for validation.

9. Git commit: `draft(tasks): create {N} tasks from tech-spec for {feature_name}`

**Checkpoint:**
- [ ] All `{feature_base}-task-NN.md` files created
- [ ] Each subagent returned file path
- [ ] Draft committed

## Phase 2: Validation (up to 3 iterations)

Tech-spec was already validated. This phase checks: (1) task-creator correctly expanded tasks by template, (2) no mismatches with real code appeared during detailing.

### Validators

Launch both in parallel:

**[`dev-task-validator`](~/.claude/agents/dev-task-validator.md)** — Template Compliance + AC/TDD carry-forward:
- Batch size: 5 tasks per call
- Pass: `feature_base`, `task_ids` (batch of IDs), `report_path`, `iteration`
- `report_path`: `{feature_base}-task-validation-batch{N}.json`

**[`dev-reality-checker`](~/.claude/agents/dev-reality-checker.md)** — Reality & Adequacy:
- Batch size: 3 tasks per call
- Pass: `feature_base`, `task_ids` (batch of IDs), `report_path`
- `report_path`: `{feature_base}-task-reality-batch{N}.json`

### Process

1. Launch both validators in parallel (dev-task-validator in batches of 5, dev-reality-checker in batches of 3).
2. Read JSON reports, collect findings.
3. If issues found — for each task with issues, launch [`dev-task-creator`](~/.claude/agents/dev-task-creator.md) in fix mode:
   - Pass: same inputs as creation + `mode: fix` + `findings` from validators
   - Subagent reads existing task, applies fixes, overwrites file.
4. After each validation round, git commit: `chore(tasks): validation round {N} — {summary}`
5. Re-validate fixed tasks (repeat 1-4). Maximum 3 iterations.
6. If problems remain after 3rd iteration — show user: "Вот что осталось — давай решим вместе."

**Checkpoint:**
- [ ] Both validators: status=approved OR user resolved remaining issues

## Phase 3: Present to User

1. Summary:
   - Task count and waves
   - Dependencies graph (which tasks depend on what)
   - Validation results: iterations, issues found and fixed

2. Wait for user approval.

3. Git commit: `chore(tasks): task decomposition approved for {feature_name}`

4. Suggest next step: use `code-writing` skill to work on individual tasks wave by wave.

**Checkpoint:**
- [ ] Summary presented
- [ ] User approved
- [ ] Approval committed

## Final Check

- [ ] All phases completed (tasks created, validation passed)
- [ ] All tasks match template (frontmatter: status, depends_on, wave, skills, reviewers)
- [ ] Both validators passed or user confirmed remaining issues
- [ ] Commits: draft → validation rounds → approved
