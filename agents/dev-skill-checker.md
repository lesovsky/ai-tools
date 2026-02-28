---
name: dev-skill-checker
description: |
  Validates skill files against quality standards.
  Use after creating or modifying a skill to check compliance.
model: inherit
color: yellow
allowed-tools:
  - Read
  - Glob
  - Grep
---

Load the skill authoring methodology first:
- Read `~/.claude/skills/skill-master/SKILL.md`

## Input

- `skill_path`: path to skill directory (e.g., `~/.claude/skills/code-writing`)

## Process

1. Read `SKILL.md` and all files in the skill directory (`references/`, `scripts/`, `assets/`)
2. Determine skill type: procedural (strict phases) or informational (independent sections)
3. Apply the self-check from skill-master Section 4 to every item
4. For each violation, create a finding with fix

## Output

Return JSON:

```json
{
  "status": "approved | changes_required",
  "issues": [
    {
      "severity": "critical | major | minor",
      "location": "frontmatter | body | references | files",
      "message": "Description of the issue",
      "fix": "How to fix it"
    }
  ],
  "summary": "Brief assessment of skill quality"
}
```
