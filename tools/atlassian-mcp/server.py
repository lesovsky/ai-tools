#!/usr/bin/env python3
import os
import httpx
from mcp.server.fastmcp import FastMCP
from dotenv import load_dotenv

load_dotenv()

JIRA_URL = os.environ["JIRA_URL"].rstrip("/")
JIRA_TOKEN = os.environ["JIRA_TOKEN"]

CONFLUENCE_URL = os.environ["CONFLUENCE_URL"].rstrip("/")
CONFLUENCE_TOKEN = os.environ["CONFLUENCE_TOKEN"]

mcp = FastMCP("atlassian")


def _jira_headers() -> dict:
    return {"Authorization": f"Bearer {JIRA_TOKEN}", "Accept": "application/json"}


def _confluence_headers() -> dict:
    return {"Authorization": f"Bearer {CONFLUENCE_TOKEN}", "Accept": "application/json"}


@mcp.tool()
def jira_get_issue(issue_key: str) -> dict:
    """Get Jira issue by key (e.g. DEV-123).

    Returns summary, description, status, assignee, reporter,
    priority, labels, components, issue type, created/updated dates.
    """
    url = f"{JIRA_URL}/rest/api/2/issue/{issue_key}"
    response = httpx.get(url, headers=_jira_headers(), timeout=10)
    response.raise_for_status()

    data = response.json()
    fields = data["fields"]

    return {
        "key": data["key"],
        "summary": fields.get("summary"),
        "description": fields.get("description"),
        "issue_type": (fields.get("issuetype") or {}).get("name"),
        "status": (fields.get("status") or {}).get("name"),
        "priority": (fields.get("priority") or {}).get("name"),
        "assignee": (fields.get("assignee") or {}).get("displayName"),
        "reporter": (fields.get("reporter") or {}).get("displayName"),
        "labels": fields.get("labels", []),
        "components": [c["name"] for c in fields.get("components", [])],
        "created": fields.get("created"),
        "updated": fields.get("updated"),
    }


@mcp.tool()
def confluence_get_page(page_id: str = "", title: str = "", space_key: str = "") -> dict:
    """Get Confluence page content by ID or by title.

    Args:
        page_id:   Numeric page ID (preferred, unambiguous).
        title:     Page title to search for (case-insensitive).
        space_key: Narrow title search to a specific space (optional).

    Returns page title, space, version, URL, and body in HTML storage format.
    When searching by title, returns the first match.
    """
    if not page_id and not title:
        return {"error": "Provide either page_id or title"}

    if not page_id:
        params: dict = {"title": title, "expand": "version,space"}
        if space_key:
            params["spaceKey"] = space_key

        search_response = httpx.get(
            f"{CONFLUENCE_URL}/rest/api/content",
            headers=_confluence_headers(),
            params=params,
            timeout=10,
        )
        search_response.raise_for_status()
        results = search_response.json().get("results", [])

        if not results:
            return {"error": f"Page not found: {title!r}" + (f" in space {space_key!r}" if space_key else "")}

        page_id = results[0]["id"]

    response = httpx.get(
        f"{CONFLUENCE_URL}/rest/api/content/{page_id}",
        headers=_confluence_headers(),
        params={"expand": "body.storage,version,space"},
        timeout=10,
    )
    response.raise_for_status()

    data = response.json()
    return {
        "id": data["id"],
        "title": data["title"],
        "space": (data.get("space") or {}).get("name"),
        "space_key": (data.get("space") or {}).get("key"),
        "version": (data.get("version") or {}).get("number"),
        "url": f"{CONFLUENCE_URL}/pages/viewpage.action?pageId={data['id']}",
        "body": (data.get("body") or {}).get("storage", {}).get("value", ""),
    }


if __name__ == "__main__":
    mcp.run()
