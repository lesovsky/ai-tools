---
description: |
  Execute feature with team of agents — waves, reviews, commits.

  Use when: "выполни фичу", "do feature", "execute feature", "запусти фичу"
---

# Do Feature

Execute a full feature using a team of agents.

## Step 1: Find Feature

1. User provides `feature_base` (e.g., `docs/features/001-feat-add-auth/001-feat-add-auth`) or feature name
2. Read `{feature_base}-tech-spec.md` — verify exists and `status: approved`
3. Check task files exist: `{feature_base}-task-*.md`
4. If tech-spec or tasks missing → stop, tell user what's needed

## Step 2: Execute

Invoke Skill tool: `Skill(skill: "feature-execution")`
