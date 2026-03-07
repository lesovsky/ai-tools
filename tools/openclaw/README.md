# OpenClaw — Docker setup (Linux)

Personal AI assistant running locally in Docker.
Source: https://github.com/openclaw/openclaw

## Quick start

```bash
# 1. Clone OpenClaw repo
git clone https://github.com/openclaw/openclaw.git ~/tools/openclaw
cd ~/tools/openclaw

# 2. Copy env and fill in Claude API key
cp ~/Projects/ai-tools/tools/openclaw/.env.example .env
nano .env  # set CLAUDE_API_KEY

# 3. Run setup (builds image, generates gateway token, runs onboarding)
bash docker-setup.sh

# 4. Connect Telegram bot
docker compose run --rm openclaw-cli channels add --channel telegram --token <YOUR_BOT_TOKEN>
```

## After setup

```bash
# Start gateway
docker compose up -d openclaw-gateway

# View logs
docker compose logs -f openclaw-gateway

# Stop
docker compose down
```

## Integrations

### Telegram bot
1. Create bot via @BotFather → get token
2. Run: `docker compose run --rm openclaw-cli channels add --channel telegram --token <token>`

### Confluence (REST API)
Requires Confluence API token and base URL.
See: skills/confluence/

### Email (IMAP)
Requires IMAP credentials (host, port, user, password).
See: skills/imap/

### Obsidian
Mount your Obsidian vault directory into the container:
Add to docker-compose.yml volumes:
```yaml
- /path/to/your/vault:/home/node/.openclaw/workspace/obsidian
```

## Data locations
- Config: `~/.openclaw/`
- Workspace: `~/.openclaw/workspace/`

## Troubleshooting

**Container can't write to config dir:**
```bash
sudo chown -R 1000:1000 ~/.openclaw
```

**Gateway not reachable:**
Check `OPENCLAW_GATEWAY_BIND=lan` in `.env` and firewall rules.
