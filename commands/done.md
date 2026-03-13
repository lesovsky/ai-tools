---
description: |
  Finalize a completed feature: read specs and decisions, update project knowledge files,
  update global ADR log and tech debt register, archive feature directory.

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

## Step 5: Update Architecture Decision Log

File: `docs/decisions-log.md`

If file does not exist — create it from template `~/.claude/shared/work-templates/decisions-log.md.template`.

From `{feature_base}-decisions.md` and `{feature_base}-tech-spec.md` extract decisions worth preserving globally:

**What belongs in ADR log (all of these):**
- Architectural choices that affect multiple components or future features
- Technology/library selection with rationale
- Patterns adopted project-wide
- Rejected alternatives worth remembering
- Deviations from the original tech-spec with reason

**What does NOT belong:**
- Implementation details (covered in decisions.md)
- Bug fix mechanics
- Obvious choices with no alternatives

For each qualifying decision, append entry to `docs/decisions-log.md` using the template format.
If a prior ADR is now superseded by this feature — update its **Status** field.

## Step 6: Update Tech Debt Register

File: `docs/tech-debt.md`

If file does not exist — create it from template `~/.claude/shared/work-templates/tech-debt.md.template`.

Scan `{feature_base}-decisions.md` for signals of deferred work:
- **Deviations** entries in task decisions
- Reviewer findings that were deferred (not fixed)
- Explicit shortcuts mentioned in Summary fields
- Any "TODO", "FIXME", "tech debt" mentions in the decisions log

For each item found:
- If it's new debt → append to **Active Debt** section with severity and area
- If an existing debt entry was resolved in this feature → move it to **Resolved Debt**

If no debt found — no changes needed, don't add empty entries.

## Step 7: Archive

Move feature directory `docs/features/{fname}/` → `docs/features/archive/{fname}/`
(create `docs/features/archive/` if it doesn't exist).

## Step 8: Commit & Report

1. Commit all changes (PK updates, ADR log, tech debt register, archive move):
   ```
   docs: finalize {fname} — update PK, ADR log, tech debt register
   ```

2. Report to user:
   - What was done (brief summary from specs)
   - What PK files were updated and what changed
   - ADR entries added/updated (titles only)
   - Tech debt: N items added, M items resolved
   - Feature archived to `docs/features/archive/{fname}/`

## Self-Verification

- [ ] Documentation-writing skill loaded
- [ ] Feature artifacts read and understood
- [ ] Completeness assessed (user warned if incomplete)
- [ ] PK files updated (only affected ones)
- [ ] ADR log updated (docs/decisions-log.md)
- [ ] Tech debt register updated (docs/tech-debt.md)
- [ ] Feature archived to `docs/features/archive/{fname}/`
- [ ] Changes committed
- [ ] Report delivered to user
