---
name: skill-master
description: |
  Guide for creating/updating skills with specialized knowledge and workflows.

  Use when: "создай скилл", "измени скилл", "гайд по скиллам", "обнови скилл", "улучши скилл"
---

# Skill Creator

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks—they transform Claude from a general-purpose agent into a specialized agent equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

## Skill Types

There are two types of skills based on how they guide Claude's work.

### Procedural Skills

Use when the task requires a strict sequence of steps where order matters. Phase 2 depends on Phase 1 completing correctly. Skipping or reordering steps would break the workflow.

Examples: code-writing (Plan → TDD → Review), project-planning (Interview → Features → Roadmap), tech-spec-planning.

These skills have explicit phases with checkpoints after each phase to verify completion before proceeding.

### Informational Skills

Use when providing methodology, knowledge, or guidelines without a strict execution order. The agent reads relevant sections and applies them to the situation. There's no "Phase 1 must complete before Phase 2" — sections are independent.

Examples: security-auditor (what to check), testing (when to use which test type), company-info (domain knowledge), database-schemas.

These skills organize content into logical sections with decision frameworks (YES if / NO if) to help the agent choose what applies.

## 1. Discovery

For new skills or major changes — run discovery interview:
- What problem does the skill solve?
- What phrases should trigger it?
- What should the skill NOT do?
- Concrete usage examples

## 2. Skill Structure

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

### Frontmatter

**`name`** (required):
- kebab-case (lowercase, hyphens)
- ≤64 characters
- Unique identifier

**`description`** (required):
- Third person ("Analyzes code...", NOT "I analyze...")
- Include both WHAT the skill does AND WHEN to use it
- ≤1024 characters

#### Description Best Practices

Claude uses description to decide when to auto-invoke the skill. Be specific and include key terms.

**Template:**
```yaml
description: |
  [What the skill does — be specific, include key terms]

  Use when: [trigger conditions — specific phrases users say]
```

**Rules:**
1. **Be specific** — Include key terms that match user requests
2. **List trigger phrases** — Real phrases users actually say (5-10 phrases)
3. **Include variations** — "техспек" AND "составь тз" (different ways to say same thing)

**Bad:**
```yaml
description: This skill helps with documents. Use when user wants to work with docs.
```
Why bad: Vague phrases ("work with docs"), no specific triggers.

**Good:**
```yaml
description: |
  Manage .claude/skills/project-knowledge/ docs: create, check, update.

  Use when: "заполни документацию", "создай документацию", "проверь документацию", "обнови документацию"
```
Why good: Specific actions, concrete trigger phrases.

### Body

Every SKILL.md body consists of:
- **Core workflow** — main instructions that are always needed
- **Links to references** — for optional/detailed information
- Keep under 500 lines (otherwise → split to references)

### Bundled Resources

A skill contains only SKILL.md and these three optional directories — nothing else (no README, CHANGELOG, etc.).

#### Scripts (`scripts/`)

Executable code (Python/Bash/etc.) for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Benefits**: Token efficient, deterministic, may be executed without loading into context

#### References (`references/`)

Content needed in some execution paths, not all. If the skill branches (multiple operations, domains, modes) — each branch's details go to a reference. Content needed on every execution stays in SKILL.md.

- **No duplication**: Content lives in either SKILL.md or references, not both

**How to link references in SKILL.md — two patterns, ranked by strength:**

**Pattern A: Action-embedded (strong)** — the workflow step's action IS applying the reference content.

```markdown
3. Write tests following patterns from [testing-guide.md](references/testing-guide.md)
   (test structure, naming, what to skip)

4. Apply audit criteria from [principles.md](references/principles.md) to each file
```

Why it works: "follow patterns from X" or "apply criteria from X" makes the reference part of the action, not a separate read-then-do instruction.

**Pattern B: Condition + contents (basic)** — for optional references needed only in specific scenarios.

```markdown
**For tracked changes**, see [REDLINING.md] — revision marks, accept/reject.
**First time with docx-js?** Read [DOCX-JS.md] — setup, examples, pitfalls.
```

Use Pattern A for references that contain rules/patterns the agent must follow during a step. Use Pattern B for references only relevant in certain branches.

**Anti-pattern: Resource catalog at end of file.** A passive list of references separated from the workflow.

```markdown
❌ Bad — passive catalog (ignored):
## Resources
### references/structure.md
Complete description of all files...

✅ Good — embed each reference into the workflow step where it's needed:
4. Apply audit criteria from [principles.md](references/principles.md) to each file
```

#### Assets (`assets/`)

Files not intended to be loaded into context, but used within the output Claude produces.

- **When to include**: Templates, images, icons, boilerplate code, fonts, sample documents that get copied or modified

## 3. Writing Guidelines

### Concise is Key

The context window is a public good. Skills share it with everything else Claude needs. Default assumption: Claude is already very smart. Only add context Claude doesn't already have.

### Degrees of Freedom

Match the level of specificity to the task's fragility:

- **High freedom**: Multiple approaches valid, decisions depend on context
- **Medium freedom**: Preferred pattern exists, some variation acceptable
- **Low freedom**: Operations are fragile, consistency is critical

### Progressive Disclosure

Skills use a three-level loading system:

1. **Metadata (name + description)** — Always in context (~100 words)
2. **SKILL.md body** — When skill triggers (<5k words)
3. **Bundled resources** — As needed by Claude

Keep SKILL.md body under 500 lines. Split content into references when approaching this limit.

### Positive over Negative

Claude follows positive instructions better. Negative ("don't do X") often ignored.

**Bad:** "Don't use bullet points. Never include examples. Avoid long explanations."
**Good:** "Write in prose paragraphs. Keep explanations to 2-3 sentences."

### Add Motivation

When Claude understands WHY a rule matters, it follows more reliably.

**Bad:** "Always return JSON format."
**Good:** "Return findings as JSON. Reason: orchestrator parses this automatically. Invalid JSON crashes pipeline."

### Avoid Emphasis Words

Words like CRITICAL, MANDATORY, NEVER, IMPORTANT, MUST are anti-patterns.

- Every instruction in a skill is already important — if it wasn't, it shouldn't be there
- When everything is emphasized — nothing stands out
- Emphasis words signal poorly written instructions that need rewriting, not shouting

**Hard limit:** Maximum one emphasis word per skill. Ideal: zero.

### No Hardcoded Paths

Skills, agents, and commands in ai-tools are portable — they work across different machines and environments. Environment-specific paths (`~/Git/notes/...`, `~/Projects/foo/bar.md`) belong in the target project's own documentation (e.g. `project-knowledge/references/deployment.md`), not in skill instructions. Skills should read paths from project documentation at runtime.

This also applies to config file locations. If a skill uses a tool or script that requires user configuration, the config path must be owned by the script — not embedded in the skill instructions. The skill may document the default convention (e.g. "config is read by the script from its standard location"), but must not hardcode the path itself. The script is the single source of truth for where config lives and how to bootstrap it.

### Delegating Heavy Work

If skill has context-heavy tasks (reviews, research, validation):
- Create separate skills for methodology
- Create agents that preload these skills
- Orchestrator calls agents → they work isolated → return results

**Skill + Agent pattern** — for complex, reusable tasks:
- **Skill** holds methodology (WHAT to do, HOW to analyze)
- **Agent** adds isolation + output format (runs in isolated context)
- Agent reads skill explicitly: `Read ~/.claude/skills/{name}/SKILL.md`

## 4. Validation

### Self-Check Before Running dev-skill-checker

**Universal (all skills):**
- [ ] name in kebab-case, ≤64 chars
- [ ] description < 1024 chars, includes "Use when:" with trigger phrases
- [ ] SKILL.md < 500 lines
- [ ] All referenced files exist
- [ ] No extra docs (README, CHANGELOG)
- [ ] No hardcoded environment-specific paths (home dirs, local vaults, user-specific directories). Project-specific paths belong in the project's own documentation (e.g. project-knowledge), not in portable skills/agents/commands.
- [ ] No hardcoded config file paths — if the skill uses scripts that require user config, the config location is owned by the script, not mentioned as a literal path in SKILL.md.
- [ ] References contain only conditional content (not needed on every execution path)
- [ ] References linked as action steps or with condition + contents (no passive links, no resource catalogs at end of file)
- [ ] Uses positive instructions (not "don't do X")
- [ ] No emphasis words (CRITICAL, MANDATORY, NEVER) — max one allowed

**Identify skill type:** procedural or informational?

**If Procedural:**
- [ ] Has explicit phases with numbered steps
- [ ] Has checkpoints after each phase
- [ ] Has self-verification section at end

**If Informational:**
- [ ] Sections organized by logic, not sequence
- [ ] Decision frameworks present (YES if / NO if) where applicable
- [ ] No forced sequential structure

### Run dev-skill-checker

After self-check — run validation:

```
Use dev-skill-checker agent to validate the skill at {path}.
If issues found → fix them → run dev-skill-checker again.
```
