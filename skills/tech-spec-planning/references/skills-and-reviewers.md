# Skills and Reviewers Catalog

Single source of truth for selecting skills and reviewers in Implementation Tasks.
Used by: tech-spec-planning (Phase 4), task-decomposition (Phase 1).

## Execution Skills

| Skill | What it's for | Typical tasks |
|-------|--------------|---------------|
| `code-writing` | Writing/modifying code, TDD cycle | API endpoints, models, services, components, migrations, tests |
| `infrastructure-setup` | Framework init, folder structure, Docker, pre-commit hooks, testing setup | Dockerfile, pre-commit hooks, folder structure, .gitignore, smoke tests |
| `deploy-pipeline` | CI/CD pipelines, deployment config, automated deploy | GitHub Actions, deploy scripts, platform config, secrets management |
| `documentation-writing` | Documentation, Project Knowledge updates | Architecture docs, API docs, conventions, patterns |
| `skill-master` | Creating/updating skills and agents | New skills, skill modifications |
| `pre-deploy-qa` | Acceptance testing before deploy (tests + acceptance criteria) | QA task in Final Wave |
| `post-deploy-qa` | Live environment verification after deploy via MCP tools | Post-deploy task in Final Wave |
| `prompt-master` | Writing/improving LLM prompts, prompt engineering | System prompts, user prompt templates, few-shot examples, prompt optimization |

Tasks without skill (user instructions) — skill not specified, description is in the task itself. Example: "ask user to register a bot in BotFather".

Prompt tasks (LLM system prompts, user templates) use `prompt-master` skill — they are NOT code-writing tasks. TDD Anchor is replaced by manual verification on sample data.

## Reviewer Agents

| Agent | What it checks | Model |
|-------|---------------|-------|
| `dev-code-reviewer` | Code quality: structure, patterns, naming, complexity, error handling | sonnet |
| `dev-security-auditor` | OWASP Top 10, injection, XSS, auth, input validation, secrets | sonnet |
| `dev-test-reviewer` | Test quality: coverage, meaningful assertions, test pyramid balance | sonnet |
| `dev-skill-checker` | Skill compliance: frontmatter, structure, skill-master guidelines | sonnet |
| `dev-prompt-reviewer` | Prompt quality: clarity, positive framing, examples over rules, compression, XML structure, success criteria | sonnet |
| `dev-infrastructure-reviewer` | Infrastructure setup quality: folder structure, pre-commit, Docker, .gitignore, testing | sonnet |
| `dev-deploy-reviewer` | CI/CD pipeline and deployment config quality: workflows, secrets, platform config | sonnet |

## Skill → Reviewers Mapping

| Skill | Default reviewers |
|-------|------------------|
| `code-writing` | `dev-code-reviewer`, `dev-security-auditor`, `dev-test-reviewer` |
| `infrastructure-setup` | `dev-code-reviewer`, `dev-security-auditor`, `dev-infrastructure-reviewer` |
| `deploy-pipeline` | `dev-code-reviewer`, `dev-security-auditor`, `dev-deploy-reviewer` |
| `documentation-writing` | `dev-code-reviewer` |
| `skill-master` | `dev-skill-checker` |
| `pre-deploy-qa` | none — QA is its own verification |
| `post-deploy-qa` | none — verification result is the review |
| `prompt-master` | `dev-prompt-reviewer` |

When `reviewers` field is empty in a task — fall back to the default set for that skill.

## Examples

### Code task (most common)
```yaml
skills: [code-writing]
reviewers: [dev-code-reviewer, dev-security-auditor, dev-test-reviewer]
```

### Infrastructure setup task
```yaml
skills: [infrastructure-setup]
reviewers: [dev-code-reviewer, dev-security-auditor, dev-infrastructure-reviewer]
```

### Deploy pipeline task
```yaml
skills: [deploy-pipeline]
reviewers: [dev-code-reviewer, dev-security-auditor, dev-deploy-reviewer]
```

### Task handling user input or auth
```yaml
skills: [code-writing]
reviewers: [dev-code-reviewer, dev-security-auditor, dev-test-reviewer]
```
Security-auditor is already in the default set for code-writing. No extra action needed.

### Documentation task
```yaml
skills: [documentation-writing]
reviewers: [dev-code-reviewer]
```

### QA task (Final Wave)
```yaml
skills: [pre-deploy-qa]
reviewers: []
```

### Post-deploy verification (Final Wave)
```yaml
skills: [post-deploy-qa]
reviewers: []
```

### Prompt task
```yaml
skills: [prompt-master]
reviewers: [dev-prompt-reviewer]
```
