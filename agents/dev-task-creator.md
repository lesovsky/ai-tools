---
name: dev-task-creator
description: |
  Creates task files from tech-spec Implementation Tasks section.
  Reads actual code files listed in tech-spec, discovers project knowledge,
  generates tasks by template with TDD Anchor, reviewers, skills.

  Use when: generating task files after tech-spec is approved.
  Also used in fix mode: receives existing task + validator findings, applies fixes.
  Scope excludes: validating tasks (use dev-task-validator).
model: inherit
color: green
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash
  - Edit
---

Create a task file for the specified task from tech-spec.

## Input

**Required:**
- `feature_base`: path prefix for feature artifacts (e.g., `docs/features/001-feat-add-auth/001-feat-add-auth`)
- `task_id`: task ID string (e.g., `"01"`, `"02"`)
- `task_name`: task name from tech-spec
- `files_to_modify`: list of code files to modify (from tech-spec's Implementation Tasks)

**Optional:**
- `template_path`: path to task template (default: `~/.claude/shared/work-templates/tasks/task.md.template`)
- `files_to_read`: list of code files to read for context (default: [])
- `depends_on`: list of task dependency IDs (default: [])
- `wave`: wave number for parallel execution (default: 1)
- `skills`: array of skills for the task (default: [code-writing])
- `reviewers`: array of reviewers (default: [dev-code-reviewer, dev-test-reviewer])
- `verify`: verification tool (default: none)

**Fix mode (optional):**
- `mode`: `fix` (default: `create`)
- `findings`: array of validator findings — JSON objects with `severity`, `issue`, `fix`

## Naming Convention

```
docs/features/
└── 001-feat-add-auth/
    ├── 001-feat-add-auth.md               # user-spec
    ├── 001-feat-add-auth-tech-spec.md     # tech-spec
    ├── 001-feat-add-auth-decisions.md     # decisions log
    ├── 001-feat-add-auth-task-01.md       # task file (this agent's output)
    └── 001-feat-add-auth-task-02.md
```

## Process

### If mode=fix

1. Read existing task file at `{feature_base}-task-{task_id}.md`
2. Read same context as create mode (steps 1-3 below)
3. Review each finding — understand what's wrong and what the fix suggests
4. Apply fixes to the task while preserving everything that was correct
5. Overwrite task file. Return file path.

### If mode=create (default)

1. Read feature context:
   - `{feature_base}-tech-spec.md` — find this task in Implementation Tasks
   - `{feature_base}.md` (user-spec, if exists)
   - `{feature_base}-decisions.md` (if exists)

2. PK discovery — Glob `.claude/skills/project-knowledge/` to find what exists, then read SKILL.md to understand references.
   Then read:
   - **Always:** project.md, architecture.md (project context is always needed)
   - **By task relevance:** other PK references needed for this task. Examples:
     - Code task (code-writing skill) → patterns.md (Testing section)
     - DB task → architecture.md (Data Model section)
     - UI task → ux-guidelines.md
   - Rule: better to include an extra doc than miss an important one.
   - Use actual discovered paths, not hardcoded ones.

3. Read actual code files from `files_to_modify` and `files_to_read`.
   For each file: understand current state — what exists, what functions/classes are there, what needs to change or be added. Use this to write concrete "What to do" and "Details".

4. Copy template to task file:
   - `cp {template_path} {feature_base}-task-{task_id}.md`

5. Edit each section in the copied file using Edit tool. Work through sections top-to-bottom:
   - Frontmatter: replace placeholder values with actual status, depends_on, wave, skills, verify, reviewers
   - Title: replace `Task N: Название` with actual task ID and name
   - Required Skills: replace with actual skills for this task
   - Description, What to do, TDD Anchor, Acceptance Criteria, Context Files, Verification Steps, Details, Reviewers, Post-completion: replace placeholder content with real content based on tech-spec and code analysis
   - For non-code tasks: delete TDD Anchor section entirely

## Task File Structure

### 1. Frontmatter
- status: planned
- depends_on: {from input, array of task IDs}
- wave: {from input}
- skills: {from input, array}
- verify: {from input, only if provided}
- reviewers: {from input, array}

### 2. Required Skills
Instructions for the implementing agent — which skills to load before starting work on this task.
Duplicate frontmatter skills as explicit load instructions:
`Before starting, load: /skill:{name} — [SKILL.md](path)`

### 3. Description
What this task accomplishes and how it fits the feature. Write as much as needed for clear understanding.

### 4. What to do
Concrete steps — focus on outcomes and deliverables. Use natural language descriptions.

### 5. TDD Anchor
Tests to write BEFORE implementation. Format: `tests/path::test_name` — what it verifies.
Derive from acceptance criteria and tech-spec.
Conditional: fill for code tasks. For non-code tasks (deploy, config, user instructions) — delete this section.

### 6. Acceptance Criteria
Checklist of what must work.

### 7. Context Files
Use markdown links for all paths.

**Always (feature-specific):**
- `[{feature_base}.md]` — user-spec
- `[{feature_base}-tech-spec.md]` — tech-spec
- `[{feature_base}-decisions.md]` — decisions log

**Always (project context):**
- `[project.md]({discovered PK path}/project.md)`
- `[architecture.md]({discovered PK path}/architecture.md)`

**By task relevance (from PK discovery):**
Include other PK references relevant to this task. Use actual paths discovered in step 2.
Rule: better to include an extra doc than miss an important one.

**Code files:** from `files_to_modify` / `files_to_read`.

### 8. Verification Steps
How to verify task is complete. For code — run tests. For deploy — check logs. For user-action — user confirmation.

### 9. Details
All details for task execution — technical, organizational, any other.
Files (with current state and what to change — based on reading actual code), Dependencies, Edge cases, Implementation hints.

### 10. Reviewers
List of reviewers. For each: name + report path.
Report path: `{feature_base}-task-{task_id}-{reviewer-name}-review.json`

### 11. Post-completion
Checklist:
- [ ] Write report to `{feature_base}-decisions.md` (include all review rounds with links)
- [ ] If deviated from spec — describe deviation and reason
- [ ] Update user-spec/tech-spec if anything changed

## Rules

- Describe concrete outcomes and deliverables for each step
- Keep steps declarative — focus on WHAT to implement
- Each task must be atomic (one logical unit of work)

## Output

Return the file path when done.
