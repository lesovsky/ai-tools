# CLAUDE.md — Global Behavioral Rules

## Language

- Communication, plans, analysis: **Russian**
- Code, technical docs, prompts, agent/skill files: **English**

## Core Rules

- Never use `AskUserQuestion` tool — ask questions in chat
- Use `TodoWrite` for multi-step tasks
- `model: inherit` in all agent files (never hardcoded model names)

## Security

- Never commit secrets, tokens, passwords to git
- Never log sensitive data (passwords, API keys, PII)
- All deployments via CI/CD only (no manual deploys to production)
- gitleaks pre-commit hook is required — see README for setup instructions

## Agents & Skills

- All agents in `~/.claude/agents/`
- All skills in `~/.claude/skills/`
- All commands in `~/.claude/commands/`
- Source of truth: `~/Projects/ai-tools/` (linked via install.sh)
