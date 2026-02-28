---
name: deploy-pipeline
description: |
  Sets up CI/CD pipelines, deployment configuration, and automated deploy workflows.
  GitLab CI/CD (.gitlab-ci.yml), platform-specific deploy (VPS/SSH, Docker Registry,
  Railway, Fly.io, AWS), secrets management via GitLab CI/CD Variables.

  Use when: "подготовь деплой", "настрой автодеплой", "настрой CI/CD",
  "setup deploy", "configure deployment", "настрой пайплайн"
---

# Deploy Pipeline

## Gathering Deployment Context

Read project-knowledge to understand the deployment target:
- `.claude/skills/project-knowledge/references/deployment.md`
- `.claude/skills/project-knowledge/references/architecture.md`
- `.claude/skills/project-knowledge/references/patterns.md`

If deployment target is not documented, ask the user:
- Target platform (VPS/SSH, Docker Registry + K8s, Railway, Fly.io, AWS ECS, NPM)
- Environment details (server IPs, registry URLs, project IDs, runner tags)
- Required secrets and where to obtain them

After gathering answers, immediately update `deployment.md` before proceeding with setup.

## CI/CD Convention

Create `.gitlab-ci.yml` following this structure:

```yaml
stages:
  - test
  - deploy

test:
  stage: test
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"
    - changes:
        - "src/**/*"
        - "*.json"
        - "*.toml"
        - "*.lock"
  # setup, install, lint, type-check, test, build

deploy:
  stage: deploy
  needs: [test]
  rules:
    - if: $CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "push"
  # platform-specific deploy
```

Adapt: add language setup, install steps, cache config, platform-specific deploy script.

### Caching

Add `cache:` to speed up installs:

```yaml
cache:
  key:
    files:
      - package-lock.json   # or poetry.lock, Pipfile.lock, go.sum
  paths:
    - node_modules/         # or .venv/, vendor/
```

### Build Artifacts Between Stages

Pass build output from test to deploy stage:

```yaml
test:
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

deploy:
  needs:
    - job: test
      artifacts: true
```

## Platform Selection

| Platform | Choose when |
|----------|------------|
| VPS / SSH | Persistent sessions, custom server config, full control |
| Docker Registry + K8s | Containerized apps, horizontal scaling |
| Railway | Full-stack apps needing managed DB, simple setup |
| Fly.io | Docker containers, global edge |
| AWS ECS | Enterprise, full infrastructure control |
| NPM | Node.js packages or CLI tools |

For VPS deployments: server IPs, SSH key setup, deploy paths go to `deployment.md`.

### VPS/SSH Deploy Example

```yaml
deploy:
  stage: deploy
  before_script:
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | ssh-add -
    - mkdir -p ~/.ssh && ssh-keyscan $SERVER_IP >> ~/.ssh/known_hosts
  script:
    - ssh $SERVER_USER@$SERVER_IP "cd /app && git pull && ./deploy.sh"
```

## Secrets Convention

Store all secrets in GitLab: **Settings → CI/CD → Variables**.

For each secret:
- Mark **Masked** (hidden in logs) for tokens and passwords
- Mark **Protected** (only on protected branches) for production secrets
- Reference in pipeline as `$VARIABLE_NAME`

Document all required variables in `deployment.md`:

| Variable | Where to get | Used in |
|----------|-------------|---------|
| `SSH_PRIVATE_KEY` | Generate locally, add public key to server | deploy job |
| `REGISTRY_PASSWORD` | GitLab Access Tokens | docker login |

Never print secrets to logs (`echo $SECRET_VAR` is prohibited).
Use `CI_JOB_TOKEN` for GitLab Container Registry auth where possible.

## Documentation Updates

After configuring, update project-knowledge references. Append to existing content.

**deployment.md:** deploy target, pipeline overview, required variables table (name + source + job), manual deploy command, rollback steps, environment URLs.

**patterns.md (Git Workflow section):** CI triggers, pipeline stages, skip logic pattern, MR workflow.

## Decision Framework

**Add deploy job?**
YES if: deployment target defined, user requests it, stable main branch.
NO if: early development, manual deploys preferred.

**Use matrix strategy?**
YES if: NPM package, cross-platform library, multiple Node/Python versions.
NO if: single-environment app, internal tool.

**Add staging environment?**
YES if: dev/staging branch exists, multi-developer team.
NO if: solo project + main-only, preview deploys sufficient.

**Use Docker build in CI?**
YES if: project has Dockerfile, deploys to registry or K8s.
NO if: platform handles builds (Railway, Fly.io), or deploying source directly.
