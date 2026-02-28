---
description: |
  Execute task from {feature_base}-task-NN.md with quality gates.

  Use when: "выполни задачу", "сделай таску", "do task", "execute task", "запусти задачу"
---

# Do Task

Execute a spec-driven task with validation and status tracking.

## Step 1: Read Task

1. Read task file (user provides path like `docs/features/001-feat-add-auth/001-feat-add-auth-task-01.md`)
   - If user didn't specify → ask: "Which task to execute? Provide path to task file."
2. Derive `feature_base` from task file path: strip `-task-NN.md` suffix
   (e.g., `docs/features/001-feat-add-auth/001-feat-add-auth-task-01.md` → `docs/features/001-feat-add-auth/001-feat-add-auth`)
3. Verify task status is `planned` (if not → ask user before proceeding)
4. Update task frontmatter: `status: planned` → `status: in_progress`
5. Read every file listed in the task's "Context Files" section

## Step 2: Execute

1. Load each skill listed in the task (frontmatter `skills: [...]` and "Required Skills" section)
   - If a skill is not found → warn user, continue with remaining skills
   - If task has no skill (frontmatter `skills: []` or absent) → read the task, execute "What to do" and "Verification Steps" directly.
     For tasks with user instructions → show the instruction to user, wait for confirmation.
2. Follow loaded skill workflow
3. Git commit implementation (code + tests pass): `feat|fix|refactor: task {N} — {brief description}`
4. For each reviewer from the task's "Reviewers" section (if present):
   1. Spawn subagent via Task tool (subagent_type = reviewer name, e.g. `dev-code-reviewer`)
   2. Pass: git diff of changes, path to task file, path to `{feature_base}-tech-spec.md`, path to `{feature_base}.md`
   3. Report is written to the path specified in the task's "Reviewers" section
   4. Read report. If findings exist → fix, re-run tests, git commit: `fix: address review round {R} for task {N}`, repeat (max 3 rounds)

## Step 3: Verify

1. Check each acceptance criterion from task file
2. If task has `verify: <tool>` in frontmatter → use specified tool for verification
3. If task has "Verification Steps" → execute each:
   - Pass → document results
   - Fail → fix → re-run tests → re-run reviewers (new round) → re-verify
   - After 3 failed rounds → stop, report failures to user, keep status `in_progress`
   - Tool unavailable → document, suggest manual check

## Step 4: Complete

1. Read template `~/.claude/shared/work-templates/decisions.md.template` and write a concise execution report to `{feature_base}-decisions.md`. Follow template format strictly — no extra sections.
2. Update task frontmatter: `status: in_progress` → `status: done`
3. Update tech-spec `{feature_base}-tech-spec.md`: `- [ ] Task N` → `- [x] Task N`
4. Git commit: `chore: complete task {N} — update status and decisions`

## Self-Verification

- [ ] Task status is `done`
- [ ] Tech-spec checkbox updated
- [ ] `{feature_base}-decisions.md` entry written with reviews and verification results
- [ ] Git commit created with task reference
- [ ] Every acceptance criterion from task file is met
