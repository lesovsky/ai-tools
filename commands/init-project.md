---
description: Initialize project with template, git, and remote repository (GitHub or GitLab)
allowed-tools:
  - Bash(*)
  - Read
  - Edit
  - TodoWrite
---

# Init Project

## 1. Check Uncommitted Changes

If inside a git repo with uncommitted changes — ask user whether to commit first, continue without commit, or stop.

## 2. Apply Template

Move existing files to `old/` (find next available name: `old`, `old2`, `old3`...):

```bash
OLD_DIR="old"
N=2
while [ -e "$OLD_DIR" ]; do OLD_DIR="old${N}"; ((N++)); done
mkdir "$OLD_DIR"
find . -maxdepth 1 ! -name '.' ! -name '..' ! -name '.git' ! -name "$OLD_DIR" -exec mv {} "$OLD_DIR/" \;
```

Copy template:

```bash
cp -rp ~/.claude/shared/templates/new-project/. .
```

After copy:
- Verify `.claude/skills/project-knowledge/` exists
- Security check: look for sensitive files in `$OLD_DIR/` (`.env*`, `*.key`, `*.pem`, `credentials.json`, `secrets/`) not covered by `.gitignore`. If found — add to `.gitignore` before proceeding.

## 3. Init Git and Remote

Init git if not initialized.

Ask user: **"Where to create the repository? (github / gitlab / skip)"**

### GitHub

1. Verify `gh` CLI is installed and authenticated
2. Ask user for repository name
3. Create repo: `gh repo create {name} --private --source=. --remote=origin`
4. Initial commit and push to current branch
5. Create `dev` branch, push it

### GitLab

1. Verify `glab` CLI is installed: `glab --version`
2. Ask user: **"GitLab hostname (leave blank for gitlab.com):"**
3. Verify authentication:
   - hostname provided: `glab auth status --hostname {hostname}`
   - blank (gitlab.com): `glab auth status`
   - If not authenticated: show `glab auth login --hostname {hostname}` (or without `--hostname` for gitlab.com) and stop
4. Ask user for repository name
5. Create repo:
   - self-hosted: `glab repo create {name} --private --defaultBranch main -h {hostname}`
   - gitlab.com: `glab repo create {name} --private --defaultBranch main`
6. Add remote from URL printed by glab: `git remote add origin {repo_url}`
7. Initial commit and push to current branch
8. Create `dev` branch, push it

### Skip

Init git only, no remote. Inform user to add remote manually later.

## 4. Final Report

Show user:
- Platform and repository URL (or "no remote" if skipped)
- Branches created
- Old files location (`old/`) if any existed
- Next step: run `/init-project-knowledge` to fill project documentation
