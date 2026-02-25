# ai-tools

Personal Claude Code toolkit: agents, skills, commands.

## Structure

```
ai-tools/
├── agents/          # Specialized subprocesses (subagents)
├── skills/          # Procedural skill instructions
├── commands/        # Slash-commands
├── shared/          # Shared templates
│   └── work-templates/
├── scripts/
│   └── install.sh   # Deploy to a new machine
└── CLAUDE.md        # Global behavioral rules
```

## Domain prefixes

Skills and agents use domain prefixes:
- `dev-*` — software development
- `mgmt-*` — team management
- `comm-*` — communication, conflict resolution
- `event-*` — workshops, talks, events

## Install

```bash
./scripts/install.sh
```

Creates symlinks from `~/.claude/` into this repository.
