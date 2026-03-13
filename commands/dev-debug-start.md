---
description: |
  Start a debug trace session for a feature under manual testing.
  Creates a machine-readable trace file and activates incremental logging protocol.

  Use when: manual testing reveals issues after a wave completes.
  Use when: "начнем сессию отладки", "debug start", "/dev-debug-start"
allowed-tools:
  - Read
  - Write
  - Glob
---

# dev-debug-start — Start Debug Trace Session

## Step 1: Identify Feature

If `feature_base` is provided in the command — use it.
If not — ask: "Укажи feature_base (например, docs/features/001-feat-auth/001-feat-auth)."

Check that `{feature_base}.md` exists. If not — warn and stop.

Check that no open trace already exists: `{feature_base}-trace.yml` with `status: open`.
If found — tell the user: "Найден незакрытый трейс от {started}. Хочешь продолжить его или начать новый?"

## Step 2: Collect Symptom

Ask the user in sequence (one question at a time):
1. "Что должно было произойти? (ожидаемое поведение)"
2. "Что происходит на самом деле? (наблюдаемое поведение)"
3. "На каком окружении воспроизводится? (local / test / staging / production)"

## Step 3: Create Trace File

Create `{feature_base}-trace.yml` from template `~/.claude/shared/work-templates/trace.yml.template`.
Fill in: `feature`, `started` (today's date), `environment`, `symptom.expected`, `symptom.observed`.

## Step 4: Activate Debug Protocol

Confirm to the user that the trace session is open, then explain the protocol:

"Трейс создан: {feature_base}-trace.yml

**Протокол сессии:**
- Я буду предлагать гипотезу и вносить изменения
- После каждого изменения прошу тебя проверить вручную
- После твоей проверки я записываю результат попытки в трейс-файл
- Если сессия прервётся — я смогу продолжить, прочитав трейс
- Когда проблема решена — вызови /dev-debug-end

Опиши, с чего начнём?"

## Active Session Rules

These rules apply for the duration of the debug session:

**After proposing and applying each fix:**
1. Ask the user to test: "Проверь, пожалуйста — что наблюдаешь?"
2. Wait for the user's report
3. Append a new attempt entry to `{feature_base}-trace.yml`:
   - `n`: next sequential number
   - `hypothesis`: what you believed was the cause
   - `action`: list of files changed with brief description
   - `result`: `pass` if the issue is resolved, `fail` otherwise
   - `observed`: what the user reported seeing
4. If `result: fail` — propose the next hypothesis
5. If `result: pass` — remind the user to call `/dev-debug-end`

**If session context is lost (compacting):**
At the start of a new session, read `{feature_base}-trace.yml` to restore full context:
what was the symptom, what was already tried, and what the last observed state was.
