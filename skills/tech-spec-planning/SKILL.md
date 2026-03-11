---
name: tech-spec-planning
description: Создаёт tech-spec.md через исследование кода, адаптивное уточнение и мультивалидаторное ревью.
---

# Tech Spec Planning

Code research → adaptive clarification → tech-spec.md → multi-validator review → user approval.

**Input:** `{feature_base}.md` (user-spec) + Project Knowledge + ADR log + Tech Debt register
**Output:** `{feature_base}-tech-spec.md` (approved)
**Language:** Technical documentation in English, communication in Russian

## Phase 1: Load Context

1. Ask user for `feature_base` if not provided (e.g., `docs/features/001-feat-add-auth/001-feat-add-auth`).

2. Read `{feature_base}.md` (user-spec). If missing — ask user to describe the task or create user-spec first (`/spec-writer`).
   Extract `size: S|M|L` from frontmatter — determines testing strategy depth.

3. Read all files in `~/.claude/skills/project-knowledge/references/` (project.md, architecture.md, patterns.md, deployment.md, etc.).
   If directory missing or empty — warn and continue without PK context.

4. Read `docs/decisions-log.md` if it exists. Note ADR entries relevant to this feature's domain — they constrain architectural choices and prevent re-litigating settled decisions. If absent — note it and continue.

5. Read `docs/tech-debt.md` if it exists. Note Active Debt items in areas this feature touches:
   - Tech-spec must not worsen existing debt without explicit justification
   - If the feature can resolve a debt item with little extra effort — propose it to the user in Phase 3
   If absent — note it and continue.

6. user-spec.md is the single input source — all requirements come from there.

**Checkpoint:**
- [ ] user-spec.md read, size extracted
- [ ] Project Knowledge read (or warned that it's missing)
- [ ] decisions-log.md read (relevant ADRs noted, or file absent)
- [ ] tech-debt.md read (relevant debt noted, or file absent)

## Phase 2: Code Research

Launch `dev-code-researcher` subagent (Task tool) with:
- `feature_base`
- `feature_description` from user-spec "Что делаем" section

The agent reads existing `{feature_base}-code-research.md` (from user-spec phase if available) and deepens analysis for implementation.

After subagent completes — read `{feature_base}-code-research.md`. Use in Phase 3 clarification and Phase 4 spec writing.

If during later phases a gap is discovered — launch `dev-code-researcher` again with the specific question.

**Checkpoint:**
- [ ] code-research.md created/updated with implementation-level analysis
- [ ] Research file read

## Phase 3: Clarification (Adaptive)

Analyze if additional information is needed based on user-spec and code research.

- Ask technical questions if gaps exist. No limit on question count — ask as many as needed.
- Focus: technical constraints, integration points, data sources, external dependencies.
- If gaps found in user-spec requirements — discuss with user and update user-spec too.
- If requirements are fundamentally unclear — suggest creating user-spec first.

**External dependency validation rule:**
If the feature depends on a specific external identifier (API field name, endpoint path,
response format, webhook event type, config key, etc.) — verify it against real data
**before** writing the tech-spec. Make a live API call, inspect a real response, or ask
the user to confirm the exact value. If verification is impossible (no access, env not
ready), explicitly mark it as a risk in the tech-spec Risks section with:
"Unverified external dependency: [what] — assumed [value], must be confirmed before
implementation." Do not assume standard values without verification.

**Checkpoint:**
- [ ] All technical gaps clarified (or none existed)
- [ ] External dependencies verified on real data, or marked as risks if unverifiable

## Phase 4: Create Tech Spec

1. Copy template using Write tool:
   Read `~/.claude/shared/work-templates/tech-spec.md.template` → write to `{feature_base}-tech-spec.md`.
   Set `created` to today's date, `status: draft`, copy `size` from user-spec.
   Set `branch`: `dev` (simple change, single component) or `feature/{name}` (multiple components, architectural changes).

2. Edit sections one by one using Edit tool, replacing placeholders with real content.
   The template structure is the spec structure — follow it directly.

3. Fill **Implementation Tasks** by waves. For each task provide:
   Description, Skill, Reviewers, Verify, Files to modify, Files to read.
   Select skill and reviewers from `~/.claude/skills/tech-spec-planning/references/skills-and-reviewers.md`.

   **Task brevity rules:**
   - Tasks are brief scope descriptions (2-3 sentences). Detailed steps, AC, and TDD anchors are created during task-decomposition.
   - Task Description answers WHAT and WHY, not HOW. No step-by-step instructions, no line numbers, no implementation details.
   - All technical decisions belong in the Decisions section, not in task descriptions.

4. The last wave is always **Final Wave**. It contains:
   - **Pre-deploy QA** (skill: `pre-deploy-qa`) — always present. Acceptance testing.
   - **Deploy** (skill: `deploy-pipeline`) — only if deploy is needed for this feature.
   - **Post-deploy verification** (skill: `post-deploy-qa`) — only if MCP verification exists in Agent Verification Plan.

5. Task count check: if >15 tasks — propose splitting into MVP + Extension phases. Wait for user decision.

6. Git commit: `draft(techspec): create tech-spec for {feature_name}`

**Checkpoint:**
- [ ] tech-spec.md created with all sections
- [ ] Implementation Tasks include Description (2-3 sentences), Skill, Reviewers for each task
- [ ] No AC or TDD anchors in tasks
- [ ] Technical decisions are in Decisions section, not in task descriptions
- [ ] Final Wave present with Pre-deploy QA (mandatory)
- [ ] Task count ≤15 (or user approved larger scope)

## Phase 5: Validation

Run 5 validators in parallel (Task tool). Each writes JSON report to `{feature_base}-{suffix}.json`:

| Validator | Agent | Report suffix |
|-----------|-------|---------------|
| Mirage detector | `dev-skeptic` | `-skeptic-techspec.json` |
| Completeness + adequacy | `dev-completeness-validator` | `-completeness.json` |
| Security | `dev-security-auditor` | `-security-audit.json` |
| Template + structure | `dev-tech-spec-validator` | `-techspec-validation.json` |
| Architecture | `dev-architect` | `-arch-review.json` |

Pass to each: `feature_base`, `report_path`.

⚠️ `dev-test-reviewer` (test plan adequacy) — not yet implemented. Omit for now.

### Process findings

Read all 5 reports. For each finding:
- Fix if clearly valid
- Reject with reasoning if disagree
- Discuss with user if controversial

### Iterate if needed (up to 3 iterations)

If fixes were made:
1. Apply targeted fixes to `{feature_base}-tech-spec.md`
2. Git commit: `chore(techspec): validation round {N} — {summary of fixes}`
3. Re-run validators on updated tech-spec
4. Repeat up to 3 iterations

If problems remain after 3 iterations — show user what remains, resolve together.

**Checkpoint:**
- [ ] All 5 validators ran
- [ ] Findings processed (fixed / rejected / discussed)

## Phase 6: User Approval

1. Show `{feature_base}-tech-spec.md` link + validation summary.
2. Wait for explicit approval.
3. If user has comments — fix, re-validate, show again.
4. After approval:
   - Update `status: draft` → `status: approved` in frontmatter
   - Git commit: `chore(techspec): approve tech-spec for {feature_name}`
5. Suggest next step: task decomposition to create task files.

**Checkpoint:**
- [ ] User explicitly approved tech-spec
- [ ] status = approved in frontmatter

## Final Check

- [ ] tech-spec.md created with all sections (tasks are brief scope descriptions)
- [ ] All 5 validators ran, findings processed
- [ ] User approved, status = approved
- [ ] Suggested next step for task decomposition
