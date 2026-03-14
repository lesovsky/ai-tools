---
description: |
  Audit accumulated technical debt: analyze tech-debt.md, scan codebase for new debt,
  prioritize cleanup, propose a resolution plan.

  Use when: "проверь техдолг", "аудит техдолга", "что накопилось", "debt review", "разбери техдолг"
---

# Debt Review

## Step 1: Load Context

1. Read `docs/tech-debt.md`. If missing — inform user: "Реестр техдолга не найден. Запусти /done после первой фичи, чтобы он создался. Продолжу со сканированием кодовой базы."

2. Read `docs/decisions-log.md` if exists — look for ADR entries with "Tech debt introduced" sections.

3. Read `~/.claude/skills/project-knowledge/references/architecture.md` if exists — understand the codebase structure.

## Step 2: Scan Codebase for Unregistered Debt

Search for signals of unregistered technical debt:

- `Glob` + `Grep` for: `TODO`, `FIXME`, `HACK`, `XXX`, `tech.?debt` (case insensitive) across source files
- `Grep` for: `// temporary`, `# temporary`, `workaround`, `quick fix` patterns
- Scan recently changed files (last 30 commits via `git log --oneline -30`) for patterns above

For each signal found:
- Check if it's already in `docs/tech-debt.md`
- If not — add to "findings" list for Step 3

## Step 3: Analyze & Prioritize

Combine registered debt (from tech-debt.md) + findings from scan.

For each item, assess:
- **Severity** (High / Medium / Low): impact on correctness, maintainability, security
- **Effort** (S / M / L): rough estimate of fix complexity
- **Risk of ignoring**: what breaks or degrades over time

Build priority list:
1. High severity + Low/Medium effort (quick wins)
2. High severity + High effort (plan carefully)
3. Medium severity items
4. Low severity items

## Step 4: Update tech-debt.md

Add any newly discovered items to `docs/tech-debt.md` Active Debt section that aren't already there.
Do NOT remove existing items — only the feature that fixes them should move them to Resolved.

If items were added: git commit `chore: update tech-debt register after audit`

## Step 5: Report to User

Present:

**Summary:** N items in register (H high / M medium / L low severity). N new items found in scan.

**Top priorities:**
1. [Item title] — Severity: High, Effort: S — [one-line why it matters]
2. ...

**Recommended next actions:**
- Items that can be fixed in the next feature as a side effect
- Items worth a dedicated cleanup task
- Items that need architectural discussion first

**Question:** "Хочешь создать фичу для выплаты конкретных долгов? Или включить их в план следующей фичи?"

## Self-Verification

- [ ] tech-debt.md read (or noted as absent)
- [ ] Codebase scanned for TODO/FIXME/HACK patterns
- [ ] New unregistered items added to tech-debt.md
- [ ] Priority list built with severity + effort assessment
- [ ] Report delivered with recommended next actions
