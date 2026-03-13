---
name: feature-execution
description: |
  Orchestrate feature delivery as team lead: spawn agents by wave,
  manage review cycles (max 3 rounds), commit per wave.

  Use when: "выполни фичу", "do feature", "execute feature", "запусти фичу",
  "выполни все задачи", "execute all tasks"
---

# Feature Execution

Team lead orchestrates feature delivery. You are a dispatcher: spawn agents, track progress, commit code, escalate issues. Delegate all code reading, diff analysis, and report review to spawned agents. Your only inputs are status messages from teammates ("Task complete") and escalation requests.

## Paths Convention

Each feature lives in its own directory. `feature_base` is the full path prefix (e.g. `docs/features/001-feat-add-auth/001-feat-add-auth`):

| Artifact | Path |
|----------|------|
| User spec | `{feature_base}.md` |
| Tech spec | `{feature_base}-tech-spec.md` |
| Task N | `{feature_base}-task-{N}.md` |
| Decisions log | `{feature_base}-decisions.md` |
| Execution plan | `{feature_base}-execution-plan.md` |
| Review report | `{feature_base}-task-{N}-{reviewer}-round{R}.json` |

## Phase 1: Initialization

1. Read `{feature_base}-tech-spec.md` and `{feature_base}.md`
2. Read frontmatter of all task files `{feature_base}-task-*.md` — extract fields:

   | Field | Purpose |
   |-------|---------|
   | `status` | planned → in_progress → done |
   | `wave` | Parallel execution group number |
   | `depends_on` | Task IDs that must be done first |
   | `skills` | Skills the teammate loads |
   | `reviewers` | Reviewer agents to spawn (source of truth) |
   | `teammate_name` | Agent name for team spawning (optional) |
   | `verify` | Verification tool (optional) |

   Build waves: group tasks by `wave` field. Within a wave, all tasks run in parallel.

3. Build execution plan following template at `~/.claude/shared/work-templates/execution-plan.md.template`
4. Save to `{feature_base}-execution-plan.md`
5. Show plan to user, wait for approval
6. Create team via TeamCreate

**Checkpoint:** execution plan approved, team created.

## Phase 2: Execute Wave

1. Find tasks for current wave: `status: planned`, all `depends_on` tasks are `done`
2. Update frontmatter: `status: planned` → `status: in_progress`
3. For each task, spawn **teammate + reviewers** (if task has reviewers):

   Use `teammate_name` from task frontmatter as the agent name. If not set — pick a descriptive name based on the task.

   **Teammate** — `subagent_type: "general-purpose"`, `model: "opus"`, `team_name: "{team}"`

   Prompt template:

   ```
   You are "{name}" executing task {N}.

   Read task: {feature_base}-task-{N}.md
   Load skills listed in task frontmatter. Follow the loaded skill workflow.

   If the task requires user actions — send the instruction to team lead via SendMessage.
   Team lead will forward to user and return confirmation.

   {reviewers_block}

   After task complete:
   - Write entry to {feature_base}-decisions.md (follow template strictly: ~/.claude/shared/work-templates/decisions.md.template).
     Summary: 1-3 sentences describing what was done and key decisions. Link JSON reports for review details.
     **Deviations field is mandatory:** if any shortcut was taken, any reviewer finding was deferred, or implementation differs from tech-spec — describe it explicitly. Do not write "Нет" unless truly no deviations occurred.
   - Message team lead: "Task {N} complete. decisions.md updated."

   feature_base: {feature_base}
   ```

   **{reviewers_block}** — include only when task has reviewers (not `reviewers: none`):

   ```
   Your reviewers: {reviewer_names} (list of teammate names).

   Review process — after task is complete, follow this review process (overrides review steps from loaded skills):
   1. Run `git diff -- <your files>` and collect the list of changed files + full diff output.
   2. Send each reviewer via SendMessage: list of changed files + full diff output.
   3. Reviewers will perform review, write JSON report to {feature_base}-task-{N}-{reviewer_name}-round{round}.json, and send report path back to you.
   4. Read reports, fix findings. After fixes: send updated diff to reviewers for next round.
   5. Max 3 review rounds. Reason: diminishing returns — if 3 rounds cannot resolve findings, the issue requires human judgment. If unresolved after 3 → message team lead to escalate.

   Commit flow:
   1. After implementation complete (tests pass): git commit `feat|fix: task {N} — {brief description}`
   2. Send diff to reviewers for review.
   3. After each round of fixes (tests pass): git commit `fix: address review round {M} for task {N}`
   4. After all reviews pass (or max 3 rounds): git commit review reports with message `chore: review reports for task {N}`
   ```

   If task has `reviewers: none` — skip reviewer spawning. The teammate works independently, commits code with message `feat|fix: task {N} — {brief description}` (tests pass), and reports completion directly to team lead.

   **Each reviewer** (when present) — `subagent_type: "{reviewer_agent}"`, `model: "sonnet"`, `team_name: "{team}"`

   Prompt template:

   ```
   You are reviewer "{name}" for task {N}.

   Read specs: {feature_base}.md, {feature_base}-tech-spec.md
   Read task: {feature_base}-task-{N}.md

   Wait for a message from teammate "{teammate_name}" with git diff of changes.

   When you receive it:
   1. Perform your review based on the changed files list and diff provided.
      In addition to your standard review criteria, explicitly check for tech debt introduction:
      - Are there shortcuts that should be logged? (hardcoded values, missing error handling, skipped edge cases)
      - Does the implementation worsen any existing fragile areas?
      - Is complexity increasing without justification?
      If tech debt is introduced — mark it as a finding in your report with field `"tech_debt": true` and describe the shortcut and suggested proper fix.
   2. Write JSON report to: {feature_base}-task-{N}-{reviewer_name}-round{round}.json
   3. Send report path to teammate "{teammate_name}" via SendMessage

   The teammate may send updated diffs for subsequent rounds (max 3).
   Review each round the same way. After the final round, shut down.

   feature_base: {feature_base}
   ```

4. All agents work in parallel. Lead waits for teammates to report "Task complete."

**Checkpoint:** all teammates reported "Task complete", decisions.md entries written.

## Phase 3: Wave Transition

1. Verify decisions.md entries exist and match template (`~/.claude/shared/work-templates/decisions.md.template`)
2. Update task frontmatter: `status: in_progress` → `status: done`
3. Git commit: `chore: complete wave {N} — update task statuses and decisions`. Code is already committed by teammates.
4. Next wave → Phase 2

**Checkpoint:** all wave tasks done, committed.

## Phase 4: User Review

All waves done including Final Wave (QA, deploy if applicable, post-deploy verification if applicable).

1. Show results: what was built, key decisions, QA report summary
2. Describe what to check manually (from execution plan "user checks" section)
3. Issues found → fix → review → commit
4. All ok → finalize, shutdown team

## Communication Flow

```
Lead spawns: Teammate + Reviewers (if task has reviewers)
Reviewers: read specs, wait for teammate's message
Teammate works → commits code (tests pass) → sends diff to each Reviewer
Reviewer reviews diff → writes JSON report → SendMessage to Teammate: "Report at [path]"
Teammate reads reports, fixes, commits fixes → sends Reviewers updated diff (next round, max 3)
After reviews pass: Teammate commits review reports
Teammate (no reviewers): works → commits code → reports completion to Lead
Teammate (user action needed): sends instruction to Lead → Lead forwards to user → returns confirmation
Teammate → Lead: "Task {N} complete. decisions.md updated."
Lead commits status updates + decisions.md → next wave
```

## Escalation

Call user when:
- 3 review iterations exhausted with remaining findings
- Teammate reports blocker or ambiguous requirement
- Task depends on unavailable MCP tool or external service

## Self-Verification

- [ ] Execution plan created and approved
- [ ] All tasks executed, reviewed where applicable (max 3 iterations each), decisions.md filled
- [ ] All waves committed (including Final Wave)
- [ ] User reviewed and approved
