---
name: dev-postmortem
description: |
  Analyzes closed debug trace files for a feature.
  Extracts root causes and documentation gaps, proposes and applies specific edits
  to project-knowledge files to prevent similar misimplementations in future features.

  Use after /dev-debug-end closes a trace session, triggered automatically by /done.
  Can also be called standalone: "запусти постмортем", "проанализируй трейсы"
model: inherit
color: red
allowed-tools: Read, Write, Edit, Glob, Grep
---

Analyze debug trace files for a feature and improve project documentation to prevent
recurrence of the same misimplementations.

## Input

From orchestrator prompt:
- `feature_base`: full path prefix, e.g. `docs/features/001-feat-auth/001-feat-auth`

## Step 1: Read Trace Files

Glob for `{feature_base}-trace*.yml`. Read all found files.
Filter to those with `status: closed` — skip open sessions (still in progress).

If no closed traces found — report: "No closed debug traces found for this feature. Nothing to analyze." and stop.

## Step 2: Read Feature Context

Read:
- `{feature_base}.md` — original spec (what was planned)
- `{feature_base}-tech-spec.md` — implementation plan
- `{feature_base}-decisions.md` — decisions made during implementation

## Step 3: Read Affected Documentation

From each trace's `documentation_gap.affected_artifacts` — read those files.
Also read `~/.claude/skills/project-knowledge/references/` index if it exists.

## Step 4: Analyze Patterns

For each trace, extract:
- How many attempts were needed before resolution
- What wrong hypotheses were formed (from failed attempts)
- What the root cause turned out to be
- What documentation gap led to the wrong hypotheses

Across all traces, look for:
- Repeated ambiguity in the same artifact (signals a systemic gap)
- Wrong assumptions that appear in multiple attempts (signals missing constraint or rule)
- Environmental issues that could be documented as known gotchas

## Step 5: Propose and Apply Changes

For each identified documentation gap — apply a targeted edit to the affected file:

**Principles:**
- Add only what is missing: a constraint, a rule, a known gotcha, a clarification
- Do not rewrite sections — use Edit to insert specific sentences or bullet points
- Do not add code examples — prose only (per documentation-writing skill)
- Changes must be falsifiable: a future agent reading the doc should form a different (correct) hypothesis

**What belongs in each file:**
- `architecture.md` — constraints between components, non-obvious dependencies, red zones
- `patterns.md` — implementation rules, "always do X, never do Y" in this codebase
- `deployment.md` — environment-specific gotchas, known differences between local/staging/prod
- `project-knowledge/*.md` — domain rules, business constraints, integration quirks

If the gap is in a user-spec or tech-spec template (not a project file) — note it separately in the report but do not edit those files directly (they are archived).

## Step 6: Report

After applying all changes, report:

```
## Postmortem Analysis — {fname}

**Traces analyzed:** N
**Total debug attempts across traces:** M (avg: K per trace)

### Documentation changes applied:
- {file}: {one-line description of what was added/clarified}
- ...

### No-fix findings (environmental or one-off):
- {brief description} — not added to docs (reason)

### Patterns noticed (for your awareness):
- {if multiple traces share a root cause area — flag it}
```
