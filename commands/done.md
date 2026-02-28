---
description: |
  Finalize a completed feature: read specs and decisions, update project knowledge files,
  archive feature directory to docs/features/archive/.

  Use when: "фича готова", "заверши фичу", "done", "финализация", "закрой фичу", "перенеси в архив"
---

# Done — Finalize Feature

## Step 1: Load Documentation Skill

Use Skill tool: `documentation-writing`

## Step 2: Identify Feature

User provides `feature_base` or feature name (e.g., `/done docs/features/001-feat-add-auth/001-feat-add-auth`).
- If provided → use it
- If not → ask: "Which feature to finalize? Provide feature_base (e.g., docs/features/001-feat-add-auth/001-feat-add-auth)."

Derive `fname` from `feature_base`: last component of the directory part
(e.g., `docs/features/001-feat-add-auth/001-feat-add-auth` → `fname = 001-feat-add-auth`, directory = `docs/features/001-feat-add-auth/`)

## Step 3: Read Feature Artifacts

Read these files from the feature:
1. `{feature_base}.md` — what was planned (user-spec)
2. `{feature_base}-tech-spec.md` — how it was implemented
3. `{feature_base}-decisions.md` — what decisions were made during implementation

If `{feature_base}-decisions.md` is missing or sparse, use `git log --oneline` for feature-related commits to understand what changed.

**Completeness check:** If the feature looks incomplete (tasks not marked done in tech-spec, missing implementation, failing tests) — warn the user: "Feature appears incomplete: {reason}. Continue with finalization anyway?"

## Step 4: Update Project Knowledge

If `.claude/skills/project-knowledge/references/` does not exist or is empty — skip this step, inform the user that project knowledge has not been initialized.

Otherwise, read current PK files and update only those affected by the feature:
- `architecture.md` — new components, changed structure, data model / schema changes
- `patterns.md` — new project-specific patterns, testing approaches, business rules
- `deployment.md` — deployment or monitoring changes
- If the feature status needs updating in the project backlog (features.md / roadmap.md), note it for the user

Apply quality principles from documentation-writing skill: no code examples, no obvious content, only project-specific information.

## Step 5: Archive

Move feature directory `docs/features/{fname}/` → `docs/features/archive/{fname}/`
(create `docs/features/archive/` if it doesn't exist).

## Step 6: Commit & Report

1. Commit PK file changes and feature archive move:
   ```
   docs: update project knowledge after {fname}
   ```

2. Report to user:
   - What was done (brief summary from specs)
   - What PK files were updated and what changed
   - Feature archived to `docs/features/archive/{fname}/`

## Self-Verification

- [ ] Documentation-writing skill loaded
- [ ] Feature artifacts read and understood
- [ ] Completeness assessed (user warned if incomplete)
- [ ] PK files updated (only affected ones)
- [ ] Feature archived to `docs/features/archive/{fname}/`
- [ ] Changes committed
- [ ] Report delivered to user
