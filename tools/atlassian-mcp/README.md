# atlassian-mcp

Minimal MCP server for self-hosted Jira and Confluence (Server / Data Center).

## Tools

| Tool | Description |
|------|-------------|
| `jira_get_issue` | Get issue by key (e.g. `DEV-123`) — summary, description, status, assignee, priority, labels |
| `confluence_get_page` | Get page by ID or title — content (HTML storage format), space, version, URL |

## Setup

```bash
cd tools/atlassian-mcp
cp .env.example .env
# fill in JIRA_URL, JIRA_TOKEN, CONFLUENCE_URL, CONFLUENCE_TOKEN

python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Claude Code config (~/.claude.json)

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "/absolute/path/to/tools/atlassian-mcp/.venv/bin/python",
      "args": ["/absolute/path/to/tools/atlassian-mcp/server.py"],
      "env": {
        "JIRA_URL": "https://jira.example.com",
        "JIRA_TOKEN": "your_token",
        "CONFLUENCE_URL": "https://confluence.example.com",
        "CONFLUENCE_TOKEN": "your_token"
      }
    }
  }
}
```

> Passing env vars directly in the config avoids the need for a `.env` file at runtime.

## Authentication

Uses Personal Access Token (PAT) via `Authorization: Bearer <token>` header.
Supported by Jira Server 8.14+ and Confluence Server 7.9+.
