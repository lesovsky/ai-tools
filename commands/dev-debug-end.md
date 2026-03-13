---
description: |
  Close a debug trace session: fill root cause and documentation gap, mark trace as closed.

  Use when: the issue found during manual testing has been resolved.
  Use when: "сессия отладки завершена", "debug end", "/dev-debug-end"
allowed-tools:
  - Read
  - Write
  - Glob
---

# dev-debug-end — Close Debug Trace Session

## Step 1: Find Open Trace

If `feature_base` is provided — use it.
If not — glob for `docs/features/**/*-trace.yml`, filter by `status: open`.
- If one found — use it
- If multiple found — list them and ask the user which to close
- If none found — tell the user: "Нет открытых трейс-сессий."

## Step 2: Read Trace

Read `{feature_base}-trace.yml`. Verify there is at least one attempt with `result: pass`.
If no passing attempt exists — warn: "В трейсе нет успешной попытки. Проблема ещё не решена?"
Wait for user confirmation before proceeding.

## Step 3: Fill Root Cause

Based on the passing attempt's hypothesis and action — write a concise root cause:
- Not a hypothesis — a confirmed explanation
- What was actually broken and why
- Distinct from symptoms (symptom = what user saw; root cause = why it happened)

Update `root_cause` field in the YAML.

## Step 4: Fill Documentation Gap

Analyze all failed attempts and their hypotheses. Ask yourself:
- What in the spec/tech-spec/project-knowledge caused the agent to form wrong hypotheses?
- Was something underspecified? Ambiguous? Missing entirely?
- Was there a correct assumption that was contradicted by documentation?

Fill `documentation_gap`:
- `description`: what was unclear or missing (1-3 sentences, specific)
- `affected_artifacts`: list paths to the actual files that were misleading or incomplete
- `proposed_changes`: brief description of what should change (full analysis → dev-postmortem)

If no documentation gap is identifiable (e.g., pure environment issue) — write:
`description: "No documentation gap identified — issue was environmental."`

## Step 5: Close Trace

Set `status: closed` in the YAML.

## Step 6: Report

Tell the user:
- Root cause (one sentence)
- Documentation gap found (or "none identified")
- "Трейс закрыт. Запусти /done когда будешь готов финализировать фичу — постмортем запустится автоматически."
