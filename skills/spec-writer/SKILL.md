---
name: spec-writer
description: Создаёт user-spec через адаптивное интервью, исследование кодовой базы и двойную валидацию.
---

# User Spec Planning

Thorough adaptive interview → codebase scan → user-spec.md → dual validation → user approval.

Output: `docs/features/{NNN}-{type}-{name}/{NNN}-{type}-{name}.md` with status `approved`.

## Interview Style

Conduct interview in Russian. Be thorough and opinionated — an engaged co-thinker who
actively proposes solutions and challenges weak answers.

**How to interview:**
- 3-4 questions per batch. Run as many batches as needed until the cycle's items are fully covered.
- Propose solutions based on Project Knowledge (if available) and code findings:
  "В architecture.md описан паттерн X — думаю, здесь нужно Y. Согласен?"
- Challenge with substance — concrete counterexamples, code references, unexplored scenarios:
  "А что если пользователь сделает Z? В коде модуль Q не обрабатывает этот случай."
- Accept the answer after one substantive challenge and move on.
- When user says "не знаю": help think through it (examples, common patterns).
  Optional item → mark TBD. Required item → break into simpler questions.

**Interview depth** depends on feature size (S/M/L):
- S (1-3 files, local fix): focused interview, core behavior
- M (several components): moderate depth, integration questions
- L (new architecture): deep interview, thorough edge cases and risk analysis

## Process

### Phase 0: Init

1. Check for existing interview: Glob `docs/features/*/*-interview.yml`.
   If found with `interview_metadata.status: in_progress` — load, show discussed topics summary, ask to resume or start fresh.
   If multiple found — show list, let user choose.
2. Get task description: "Опиши, что хочешь сделать."
3. Determine `work_type` (feature / bug / refactoring) from description.
4. Find next feature number: Glob `docs/features/[0-9][0-9][0-9]-*/` to list existing feature directories, take max existing NNN + 1.
5. Propose feature name (kebab-case), get user confirmation.
   → `fname = {NNN}-{type}-{name}` (e.g., `001-feat-add-auth`)
   → `feature_base = docs/features/{fname}/{fname}` (e.g., `docs/features/001-feat-add-auth/001-feat-add-auth`)
   → Create directory: `docs/features/{fname}/`
6. Copy `~/.claude/shared/interview-templates/feature.yml` → `{feature_base}-interview.yml` using Write tool.
7. Update `{feature_base}-interview.yml`:
   - `interview_metadata.started`, `interview_metadata.status: in_progress`
   - `interview_metadata.feature_name`, `interview_metadata.feature_base`, `interview_metadata.work_type`

**Checkpoint:** `{feature_base}-interview.yml` exists with status `in_progress`.

### Phase 1: Study Project Knowledge

Read ALL files from `~/.claude/skills/project-knowledge/references/`.
If directory missing or empty — warn user ("Project Knowledge не настроены — интервью пройдёт без контекста проекта. Для настройки используй project-init."), continue.

These files are your context for the entire interview. Reference them when asking questions and proposing solutions.

### Phase 2: Cycle 1 — General Understanding

**Scope:** `phase1_feature_overview` items in `{feature_base}-interview.yml`.

1. Score user's initial description against all items (detailed 80-95%, brief 50-70%, vague 20-40%, not mentioned 0%).
2. Run **Interview Loop** (see below) on `phase1_feature_overview` items.
3. During this cycle — determine feature size S/M/L and agree on testing strategy:
   - S: integration/E2E usually not needed — state why
   - M: propose whether integration tests make sense, explain reasoning
   - L: propose specific integration and E2E scope with justification

### Phase 3: Code Research

Launch `dev-code-researcher` subagent (Task tool) with:
- `feature_base`
- `feature_description` from Cycle 1 (summary of what was learned)

After subagent completes — read `{feature_base}-code-research.md`. Use findings in Cycle 2 questions.

If during later phases a gap is discovered — launch `dev-code-researcher` again with a specific research question.

### Phase 4: Cycle 2 — Code-Informed Refinement

**Scope:** `phase2_user_experience` + `phase3_integration` items.

1. Summarize understanding: "Я понял задачу так: [X]. В коде нашёл: [Y]."
2. Questions based on code findings: "Нашёл модуль X, который делает Y — переиспользуем?"
3. Run **Interview Loop** on `phase2_user_experience` + `phase3_integration` items.

### Phase 5: Cycle 3 — Review & Finalize

**Scope:** ALL items across all phases still below threshold.

Cleanup pass: revisit anything not fully covered in Cycles 1-2.
Deepen edge cases and error scenarios — probe for scenarios user hasn't considered,
even if items formally passed threshold.

Run **Interview Loop** on remaining gaps.

### Phase 6: Completeness Check

Launch `dev-interview-completeness-checker` subagent (Task tool) with `feature_base`.

- `needs_more` → ask the suggested questions, then re-run the checker
- `complete` → proceed to Phase 7

### Phase 7: Create User Spec

1. Copy template to working file using Write tool:
   Read `~/.claude/shared/work-templates/user-spec.md.template` → write to `{feature_base}.md`
   Replace `[DATE]` with today's date, set correct `type` and `size` in frontmatter.
2. Edit sections one by one using Edit tool, replacing placeholders with interview data.
   **Content rules:**
   - "Что делаем" — self-contained, understandable without the interview
   - "Зачем" — concrete user value, not "улучшить UX"
   - Acceptance criteria — testable, no "работает корректно"
   - Every discussed topic from interview must appear in the spec
3. If feature seems large (>10 criteria, >3 user flows, >5 integrations) — suggest splitting.
4. Update `{feature_base}-interview.yml`: set `phase4_completion.userspec_file`, `phase4_completion.status: created`.

Git commit: `draft(userspec): create user-spec for {feature_name}`

### Phase 8: Validation

Run 2 validators in parallel (Task tool):
- `dev-userspec-quality-validator` — document structure, template compliance, formal completeness.
  Pass: `feature_base`, `report_path: {feature_base}-quality-review.json`, `interview_path: {feature_base}-interview.yml`
- `dev-userspec-adequacy-validator` — feasibility, over/underengineering, alternatives.
  Pass: `feature_base`, `report_path: {feature_base}-adequacy-review.json`

**Handling findings:**
- Obvious issue → fix silently
- Borderline → discuss with user
- Disagree with finding → reject with reasoning
- Conflict between validators → `dev-userspec-adequacy-validator` takes priority (substance over form)

After each validation round (validators wrote reports + you applied fixes):
git commit: `chore(userspec): validation round {N} — {summary of fixes}`.
Re-run validators. Max 3 iterations, then show remaining issues to user.

### Phase 9: User Approval

Show `{feature_base}.md` link + validation summary (pass/fail per check).
If changes requested — edit and show again.

When approved:
1. Set `{feature_base}.md` frontmatter `status: approved`
2. Set `{feature_base}-interview.yml` `interview_metadata.status: completed`,
   `phase4_completion.status: approved`
3. Git commit: `chore(userspec): approve user-spec for {feature_name}`
4. Suggest next step: `/plan-writer` or describe how to start tech planning.

## Interview Loop

Runs inside each cycle. Repeats until the cycle's scope is fully covered.

```
1. Find gaps: required items in current scope with score < 85%. Lowest score first.
2. Ask 3-4 questions about different gaps. Reference PK and code findings.
3. User responds.
4. Update {feature_base}-interview.yml:
   - conversation_history: add full Q&A entry
   - Item: score, value, gaps, status
   - interview_metadata: last_updated, current_question_num
   - Save immediately (Write tool)
5. Check stop criteria (BOTH must be true):
   a) All required items in scope score >= 85%
   b) Structural: every required item has non-empty value,
      no TBD in value, gaps empty or only conscious limitations
6. Not done → step 1. Done → exit cycle.
```

Scoring: detailed answer 80-95%, brief 50-70%, vague 20-40%, not mentioned 0%.

Optional items: cover when user mentions relevant context or when naturally connected to required items.

## Work Type Adaptations

All three cycles apply to any work_type, but focus shifts:

**Bug:** Cycle 1 → reproduction steps, expected vs actual, severity, when it broke.
Code research → find bug location and root cause.
Cycle 2 → fix approach, regression risks.

**Refactoring:** Cycle 1 → current problems, target architecture, stability guarantees.
Code research → current structure, dependencies, test coverage.
Cycle 2 → migration path, backward compatibility.

## Scope Changes

If understanding changes significantly during interview:
- Update affected scores downward, add new gaps
- Reassess feature size (S/M/L)
- If work_type changes (was feature, actually bug) — pivot items accordingly
- Note the change in `{feature_base}-interview.yml` notes section

## Self-Verification

- [ ] All cycles completed, completeness checker passed
- [ ] `{feature_base}.md` filled with real content (no placeholders)
- [ ] Both validators passed (or issues resolved with user)
- [ ] User approved, frontmatter `status: approved`
- [ ] `{feature_base}-interview.yml` `interview_metadata.status: completed`
- [ ] Suggested next step for tech planning
